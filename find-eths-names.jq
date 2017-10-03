#!/usr/bin/jq -rf

# lshw -json | $0 | column -t

def find_eths:

  def mark($m): if type == "object" then .[$m] = true else . end;

  # class network has no children
  def find_and_mark($m):
    if type == "object" then
      if has("children") then .children
      elif has("class") and .class == "network" then walk(mark($m))
      else . end
    else . end;

  def get_marked($m):
    if type == "object" then
      if has($m) then .
      else empty end
    else . end;

  "stone" as $m
    | walk(find_and_mark($m))
    | walk(get_marked($m))
    | flatten[];


def select_attr:
  find_eths
    | .capabilities as $cap
    | { logicalname, serial, description, product, vendor }
      + { driver: .configuration.driver }
      + (.capabilities | keys[] | select(startswith("10")) | { (.): $cap[.] });

"net ARP",
(select_attr | @text "\(.logicalname) \(.serial)")

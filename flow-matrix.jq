#!/usr/local/bin/jq -f

import "Set" as Set;
import "flow-matrix-data" as $data;

def ips: $data::data[0][0].list;
def groups: $data::data[0][1].by_groups;

def group($group): groups[$group] | unique;
def net($net): ips[$net].name | unique;

def data:
  def inter(a; b): Set::intersection(group(a); group(b));
  [
   [group("bastion"), net("admin2"),    [ "ssh" ]],
   [net("admin2"),    group("backups"), [ "ssh" ]],
   [net("admin2"),    group("log"),     [ "log" ]],

   [inter("prod";    "front"), inter("prod";    "nfs"), [ "nfs" ]],
   [inter("preprod"; "front"), inter("preprod"; "nfs"), [ "nfs" ]]
  ];

def index:
  def triplet: [. as $in | $in[0][] as $source | $in[1][] as $dest | $in[2][] as $proto | [ $source, $dest, $proto ]];
  def merge: reduce .[] as $t ({}; . + { ($t[0]): (.[$t[0]] + { ($t[1]): (.[$t[0]][$t[1]] + [$t[2]]) }) });
  [.[] | triplet] | flatten(1) | merge;

def flow_matrix(lines; cols):
  def txt: { empty: ".", space: " " };
  ([ txt.empty ] + cols,
  lines[] as $line
  | [ $line ] + [ cols[] as $col | .[$line][$col] // [ txt.empty ] | join(txt.space) ])
  | @tsv;

data | index
  | flow_matrix(group("front"); group("nfs")),
    flow_matrix(group("prod"); group("admin") + group("backups"))

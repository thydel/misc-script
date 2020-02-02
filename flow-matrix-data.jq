#!/usr/local/bin/jq -f

import "Set" as Set;
import "flow-matrix" as fmat;
import "data" as $data;

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

def txt: { empty: ".", space: " " };

data
  | fmat::index
  | fmat::table(group("front"); group("nfs"); txt + { title: "front-nfs" }; @tsv),
    fmat::table(group("prod"); group("admin") + group("backups"); txt; @tsv)


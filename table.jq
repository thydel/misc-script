#!/usr/local/bin/jq -f

import "Set" as Set;
import "table" as $data;

def ips: $data::data[0][0].list;
def groups: $data::data[0][1].by_groups;

def group($group): groups[$group] | unique;
def net($net): ips[$net].name | unique;

def data:
  [
   [[ "bastion" ], net("admin2"), [ "ssh" ]],
   [
    Set::intersection(group("prod"); group("front")),
    Set::intersection(group("prod"); group("nfs")),
    [ "NFS" ]
    ],
   [
    Set::intersection(group("prod"); group("front")),
    Set::intersection(group("prod"); group("nfs")),
    [ "FOO" ]
    ]
   ];

def triplet: [. as $in | $in[0][] as $source | $in[1][] as $dest | $in[2][] as $proto | [ $source, $dest, $proto ]];

def merge: reduce .[] as $t ({}; . + { ($t[0]): (.[$t[0]] + { ($t[1]): (.[$t[0]][$t[1]] + [$t[2]]) }) });

def step1: [data[] | triplet] | flatten(1) | merge;

group("prod") | . as $l | $l[] as $c | [ $c, $l ]

#step1

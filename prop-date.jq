#!/usr/bin/env -S jq -nrf --args

# Typical input
# find $dir -type f | xargs stat | jc --stat-s | jq '[ .file, .modify_time_epoch ]'

# Input is a stream of pairs of path and Unix time < ["tmp/foo", 1666529720]
# output is object tree whose leaves are path date > {"tmp": {"foo": 1666529720}}
def tree:

  def star: reduce .[] as $i ({}; . * $i);

  def path:
    def path: split("/") | if .[0] == "" then .[0] |= "/" else . end;
  [(.[0] | path), .[1]];

  def branch:
    . as [$p, $t] |
    def branch: if . == [] then $t else { (.[0]): (.[1:] | branch) } end;
    $p | branch;

  map(path | branch) | star;

# Input is output of tree
# Ouput is input augmented with latest date propagated from leaves to roots
# > {"tmp":{"foo":1666529720,"time":1666529720},"time":1666529720}
def time:
  def time: 
    if type == "number" then . else map(time) | sort[-1] end;
  walk(if type == "object" then . + { time: time } else . end);

# Input is ouput of time
# Ouput is a list of pair of path and Unix time for all non leaf input > [["tmp",1666529720]]
def dir:
  def path:
    if .[0] == "/" then .[1:] | join("/") | "/" + . else join("/") end;
  ([path(.. | .time?)] | map(select(length > 1))) as $p
  | [($p | map(.[:-1] | path)), [getpath($p[])]] | transpose;

# Input is ouput of dir
# Ouput is a sh script for setting the propagated time > touch -d @1666529720 tmp
def sh: .[] | "touch -d @\(.[1]) \(.[0])";

# Input is ouput of dir
# Ouput is a sh script for setting the propagated time
# > import os
# > os.utime('tmp', times=(1666529720, 1666529720))
def python:
  [ "import os" ] + map(. as [ $p, $t ] | "os.utime('\($p)', times=(\($t), \($t)))") | join("\n");

# Input is ouput of dir
# Ouput is a perl script for setting the propagated time > utime 1666529720, 1666529720, 'tmp';
def perl: map(. as [ $p, $t ] | "utime \($t), \($t), '\($p)';") | join("\n");

# Check args and setup pipeline
def touch:
  (null | { sh, python, perl } | keys) as $o
  | def check($a):
      def help($e): ($o | join("|")) as $a | "error: \($e)\nprop-date [\($a)]\n";
      if $a == [] then .
      elif $a | length > 1 then help("too many args") | halt_error
      elif $a[0] | IN($o[]) | not then help("bad arg") | halt_error
      else . end;
  def nop: null;
  def run($a):
    if $a == "python" then python
    elif $a == "perl" then perl
    else sh end;
  $ARGS.positional as $a | check($a) | run($a[0]);
def nop: null;

[inputs] | tree | time | dir | touch

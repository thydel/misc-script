# Typical input
# with-time dir | exclude some
# with-time () { find ${1:?} -type f -print0 | xargs -0 stat -c '["%n",%Y]'; }
# exclude () { grep -Ev -e '.ansible|.git' -e "${1:?}"; }

# Input is a stream of pairs of path and Unix time < ["tmp/foo", 1666529720]
# Output is object tree whose leaves are path date > {"tmp": {"foo": 1666529720}}

def tree: reduce inputs as $i (null; . + setpath($i[0] / "/"; $i[1] ));

# Input is output of tree
# Output is input augmented with latest date propagated from leaves to roots
# > {"tmp":{"foo":1666529720,"time":1666529720},"time":1666529720}
def time:
  def time: if type == "number" then . else map(time) | sort[-1] end;
  walk(if type == "object" then . + { "time/": time } else . end);

# Input is ouput of time
# Output is a stream of pair of path and Unix time for all non leaf input > [["tmp",1666529720]]

def dir: . as $i | path(..) | select(.[-1] == "time/" and length > 1) as $p | [ ($p[:-1] | join("/")), ($i | getpath($p)) ];

# Input is output of dir
# Output is a sh script for setting the propagated time > touch -d @1666529720 tmp
def sh: [ "touch", "-d", "@\(last)", first ] | @sh;

# Input is output of dir
# Output is a python script for setting the propagated time
# > import os
# > os.utime('tmp', times=(1666529720, 1666529720))
def python: . as [ $p, $t ] | "os.utime('\($p)', times=(\($t), \($t)))";

# Input is output of dir
# Output is a perl script for setting the propagated time > utime 1666529720, 1666529720, 'tmp';
def perl: . as [ $p, $t ] | "utime \($t), \($t), '\($p)';";

def main: tree | time | dir;

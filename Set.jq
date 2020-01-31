# https://rosettacode.org/wiki/Set#jq

def is_set:
  . as $in
  | type == "array" and
    reduce range(0;length-1) as $i
      (true; if . then $in[$i] < $in[$i+1] else false end);

# If A and B are sets, then intersection(A;B) emits their intersection:
def intersection($A;$B):
  def pop:
    .[0] as $i
    | .[1] as $j
    | if $i == ($A|length) or $j == ($B|length) then empty
      elif $A[$i] == $B[$j] then $A[$i], ([$i+1, $j+1] | pop)
      elif $A[$i] <  $B[$j] then [$i+1, $j] | pop
      else [$i, $j+1] | pop
      end;
  [[0,0] | pop];

# If A and B are sets, then A-B is emitted
def difference(A;B):
  (A|length) as $al
  | (B|length) as $bl
  | if $al == 0 then [] elif $bl == 0 then A
    else 
      reduce range(0; $al + $bl) as $k
        ( [0, 0, []];
          .[0] as $i | .[1] as $j
          | if $i < $al and $j < $bl then
              if A[$i] == B[$j] then [ $i+1, $j+1,  .[2] ]
              elif  A[$i] < B[$j] then [ $i+1, $j, .[2] + [A[$i]] ]
              else [ $i , $j+1, .[2] ]
              end
            elif $i < $al then [ $i+1, $j,  .[2] + [A[$i]] ]
            else .
            end
         ) | .[2]
    end;

# merge input array with array x by comparing the heads of the arrays in turn;
# if both arrays are sorted, the result will be sorted:
def merge(x):
  length as $length
  | (x|length) as $xl
  | if $length == 0 then x
    elif $xl == 0 then .
    else 
      . as $in
      | reduce range(0; $xl + $length) as $z
         # state [ix, xix, ans]
         ( [0, 0, []];
           if .[0] < $length and ((.[1] < $xl and $in[.[0]] <= x[.[1]]) or .[1] == $xl)
           then [(.[0] + 1), .[1], (.[2] + [$in[.[0]]]) ]
           else [.[0], (.[1] + 1), (.[2] + [x[.[1]]]) ]
           end
         ) | .[2]
    end ;
 
def union(A;B):
  A|merge(B)
  | reduce .[] as $m ([]; if length == 0 or .[length-1] != $m then . + [$m] else . end);

def subset(A;B):
  # TCO
  def _subset:
    if .[0]|length == 0 then true
    elif .[1]|length == 0 then false
    elif .[0][0] == .[1][0] then [.[0][1:], .[1][1:]] | _subset
    elif .[0][0] < .[1][0] then false
    else [ .[0], .[1][1:] ] | _subset
    end;
  [A,B] | _subset;

def intersect:
 .[0] as $A  | .[1] as $B
 | ($A|length) as $al
  | ($B|length) as $bl
  | if $al == 0 or $bl == 0 then false
    else
      ($B | bsearch($A[0])) as $b
      | if $b >= 0 then true
        else [$A[1:], $B[- (1 + $b) :]] | intersect
        end
    end;

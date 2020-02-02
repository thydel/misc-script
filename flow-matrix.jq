def index:
  def triplet:
    . as $in
    | $in[0][] as $source | $in[1][] as $dest | $in[2][] as $attr | [ $source, $dest, $attr ];
  def merge:
    reduce .[] as $t
    ({}; . + { ($t[0]): (.[$t[0]] + { ($t[1]): (.[$t[0]][$t[1]] + [$t[2]]) }) });
  [.[] | [triplet]] | flatten(1) | merge;

def table(lines; cols; txt; fmt):
  def table:
    [ txt.empty ] + cols,
    lines[] as $line
    | [ $line ] + [ cols[] as $col | .[$line][$col] // [ txt.empty ] | join(txt.space) ];
  "#" + txt.title, (table | fmt);

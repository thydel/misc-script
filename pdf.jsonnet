#!/usr/bin/env jsonnet

local templates = {
  phony: |||
    %(name)s:; @%(cmd)s
    .PHONY: %(name)s
  |||,
  pattern: |||
    %(name)ss := $(%(from)ss:%%.%(from)s=%(pat)s)
    %(pat)s: %%.%(from)s %(pipe)s %(dir)s; %(cmd)s
    %(dir)s:; mkdir $@
    %(name)ss: $(%(name)ss)
    .PHONY: %(name)ss
  |||,
};

local rules = {
  phony(args): templates.phony % args,
  pattern(args): {
    local more = {
      dir: "." + args.name,
      pat: "%s/%%.%s" % [ self.dir, args.to ],
      pipe: "|",
    },
    make: templates.pattern % (args + more),
  }.make
};

local chars = {
  ascii: {
    space: " ",
    quote: "\\'",
  },
  unicode: {
    nbsp: "\u00a0",
    rsquo: "\u2019"
  },
};

local jqs = {
  rename(subs): 'select(test("%(from)s")) | [., sub("%(from)s"; "%(to)s"; "g")] | "mv \\(@sh)"' % subs,
  pdfinfo(file): '[inputs] | map(split(": +"; "g") | { (.[0]): .[1] }) | add | . + { Filename: %s }' % file,
};

local cmds = {
  local var(v) = '"$%s"' % v,
  local io = { src: var("<"), dst: var("@") },
  local jq_on_files = "ls | jq -Rr $'%s'",

  rename(subs): std.escapeStringDollars(jq_on_files) % jqs.rename(subs),

  pdftotext: {
    local cmd = "pdftotext -q -nopgbrk %(src)s - | (grep -v -e '^Délivré à' -e '^$' || test $? = 1) > %(dst)s",
    fmt: std.escapeStringDollars(cmd) % io,
    }.fmt,

  pdfinfo: {
    local cmd = "pdfinfo -isodates %(src)s 2> /dev/null | jq -Rn '%(jq)s' > %(dst)s",
    local args = io + { jq: jqs.pdfinfo(io.src) },
    fmt: cmd % args,
  }.fmt,
};

local withEntries(o) = std.map(function(k) { k: k, v: o[k] }, std.objectFields(o));

local renames = {
  local data = [
    [ "no-space", chars.ascii.space, chars.unicode.nbsp ],
    [ "no-quote", chars.ascii.quote, chars.unicode.rsquo ],
    [ "rename", "@PresseFr", "" ],
  ],
  local func(t) = rules.phony({ name: t[0], cmd: cmds.rename( { from: t[1], to: t[2] } )}),
  make: std.map(func, data),
}.make;

local patterns = {
  local data = [
    [ "txt", "pdf", "txt", "pdftotext" ],
    [ "pdfinfo", "pdf", "json", "pdfinfo" ],
  ],
  local func(t) = rules.pattern({ name: t[0], from: t[1], to: t[2], cmd: cmds[t[3]] }),
  make: std.map(func, data),
}.make;


local head = |||
  #!/usr/bin/make -f
  
  MAKEFLAGS += -Rr --warn-undefined-variables
  SHELL != which bash
  .SHELLFLAGS := -euo pipefail -c
  
  top:; @date

  pdfs := $(wildcard *.pdf)
|||;

local more = |||
  norm: no-space no-quote
  .PHOMY: norm
|||;

[ head ] + renames + patterns + [ more ]



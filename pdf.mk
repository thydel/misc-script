#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:

top:; @date

vartar :=

-include .pdf.mk
conf.mvs ?= { dummy: [] }
conf.rename ?= []
conf.rename2 ?= []
conf.not-txt ?= dummy

patterns.rename := $(conf.rename)
patterns.rename2 := $(conf.rename2)
jq.files := .[] | .filename
jq.pdfs := $(jq.files) | select(test("[.]pdf$$"))
jq.mv := "mv \(@sh)"
ascii.space := " "
ascii.quote := "\u0027"
unicode.nbsp := "\u00a0"
unicode.rsquo := "\u2019"

~ := mv
$~: mvs := $(conf.mvs)
$~: jq  = $(mvs) as $$m
$~: jq += | ( $$m | keys[] as $$d | [ "mkdir", "-p", $$d ] | "\(@sh)")
$~: jq += , ( $(jq.pdfs) | . as $$f | $$m | keys[] as $$d | $$m[$$d][] as $$p | $$f | select(test($$p; "i"))
$~: jq +=     | [[ "mv", $$f, $$d ], [ "rm", "-f", ".pdfinfo/" + ($$f | sub("pdf"; "json")) ]][] | "\(@sh)")
$~:; @jc ls | jq -r '$(jq)'
.PHONY: $~

# Propagate date of most recent file to dir
~ := pdate
$~: func = $1 () { $($(strip $1)); };
$~: funcs = $(strip $(foreach _, $1, $(call func, $_)))
$~: map := while read; do "$$@" $$REPLY; done
$~: dirs := find -mindepth 1 -maxdepth 1 -type d
$~: file := ls -t $${1:?} | sed -n 1p | xargs -i touch -r "$$1/{}" "$$1"
$~: $~ := $(call funcs, map dirs file)
$~: $~ += dirs | map file
$~:; @$($@)
.PHONY: $~

~ := no-space
$~: from := $(ascii.space)
$~: to := $(unicode.nbsp)
~ := no-quote
$~: from := $(ascii.quote)
$~: to := $(unicode.rsquo)
~ := no-space no-quote
$~: jq := $(jq.files) | select(test($(from))) | [., sub($(from); $(to); "g")] | $(jq.mv)
$~:; @jc ls | jq -r '$(jq)'
.PHONY: $~
- := $~
~ := norm
$~: $-;
.PHONY: $~

~ := rename
$~: patterns := $(patterns.rename)
$~: jq := $(jq.files) | . as $$i | $(patterns)[] as $$p | $$i | select(test($$p; "i")) | [$$i, sub($$p; ""; "i")] | $(jq.mv)
$~:; @jc ls | jq -r '$(jq)'
.PHONY: $~

~ := rename2
$~: patterns := $(patterns.rename2)
$~: jq := $(jq.files) | . as $$i | $(patterns)[] as $$p
$~: jq += | $$p | .[0] as $$f | .[1] as $$t
$~: jq += | $$i | select(test($$f; "i")) | [$$i, sub($$f; $$t)] | $(jq.mv)
$~:; @jc ls | jq -r '$(jq)'
.PHONY: $~

~ := scan
$~ned:; mkdir $@
$~: pattern := "\\.txt$$"
$~: select := select(.size == 0 and (.filename | test($(pattern)))).filename
$~: do = if length > 0 then $1 else empty end
$~: move = map($(select) | sub("txt"; "pdf")) | $(call do, "mv -t $| \(. | @sh)")
$~: clean := map($(select)) | map(".txt/" + .) | $(call do, "rm \(. | @sh)")
$~: files := jc ls -l .txt
$~: $~  = $(files) | jq -r '$(move)';
$~: $~ += $(files) | jq -r '$(clean)'
$~: txts | $~ned; @$($@)
.PHONY: $~

pdfs := $(wildcard *.pdf)

~ := txt
$~.pat := .$~/%.txt
$~.dir := $(dir $($~.pat))
$~s := $(pdfs:%.pdf=$($~.pat))
$($~.pat): elist := $(conf.not-txt)
$($~.pat): exclude = $(elist:%=-e '%')
$($~.pat): cmd = pdftotext -q -nopgbrk "$<" - | (grep -v $(exclude) || test $$? = 1) > "$@"
$($~.pat): %.pdf | $($~.dir); $(cmd)
$($~.dir):; mkdir $@
$~s: $($~s)
.PHONY: $~s

~ := pdfinfo
$~.pat := .$~/%.json
$~.dir := $(dir $($~.pat))
$~s := $(pdfs:%.pdf=$($~.pat))
$($~.pat): self := $~
$($~.pat): jq := [inputs] | map(split(": +";"g") | { (.[0]): .[1] }) | add
$($~.pat): cmd  = ($(self) -isodates "$<" 2> /dev/null;
$($~.pat): cmd +=  echo -n 'FileDate:  '; date  +"%Y-%m-%dT%H:%M:%S%z" -r "$<";
$($~.pat): cmd +=  echo 'FileName:  ' "$<") |
$($~.pat): cmd += jq -Rn '$(jq)' > "$@"
$($~.pat): %.pdf | $($~.dir); $(cmd)
$($~.dir):; mkdir $@
$~s: $($~s)
.PHONY: $~s

~ := redate
ifeq ($(filter $~, $(MAKECMDGOALS)),$~)
order := MC
creation := order := CM
vartar += creation
endif
$~: scan := "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}"
$~: c := .CreationDate
$~: m := .ModDate
$~: MC := $m // $c
$~: CM := $c // $m
$~: jq  = . + { AnyDate: ($($(order)) // .FileDate) }
$~: jq += | select(.AnyDate | scan($(scan)) + "Z" | fromdate | strftime("%Y-%m-%d") != "1999-12-31")
$~: jq += | "touch -d \(.AnyDate) \"\(.FileName)\""
$~: $~  = find $(dir $|) -name '*.json' -newer $| -print0 | xargs -0i jq -r '$(jq)' {} | sort -k 3,3r;
$~: pdfinfos | .pdfinfo/.stone; @$($@)
.PHONY: $~

.pdfinfo/.stone:; @touch -d '1 days ago' $@
stone: .pdfinfo/.stone; @touch $<
.PHONY: stone

# Remove all .pdfinfo/%.json without a matching %.pdf
pdfinfos := $(wildcard .pdfinfo/*.json)
~ := pdfinfos.clean
$~ := $(pdfinfos:%=%.clean)
$($~): .pdfinfo/%.json.clean : .pdfinfo/%.json; @test -f "$*.pdf" || echo rm '"$<"'
$~: $($~)
.PHONY: $~

# Move all pdf whose Creator field match creator/% in % dir
~ := creator/%
$~: jq = select(.Creator // empty | test("$*"; "i")).FileName
$~: $~  = mkdir -p $*;
$~: $~ += move () { mv $$1.pdf $*; rm .pdfinfo/$$1.json; }; export -f move;
$~: $~ += cat .pdfinfo/*.json | jq -r '$(jq)' |
$~: $~ += xargs -r basename -s .pdf | xargs -ri echo move {} $* | $(DO)
$~: pdfinfos; @$($(@D)/%)

~ := dirdate
$~: d := $${1:?}
$~: $~ := f () { touch -r "$d/$$(ls -t $d | head -1)" "$d"; };
$~: $~ += find -mindepth 1 -maxdepth 1 -type d
$~: $~ += | { declare -f f; xargs -i echo f {}; } | bash
$~:; @$($@)
.PHONY: $~

clean:; rm *.txt
.PHONY: clean

DO := cat
do := DO := bash

vartar += do

$(vartar):; @: $(eval $($@))

#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

top:; @date

patterns.rename := [ "@PresseFr", "_UserUpload_Net", "_-Unlocked" ]
jq.files := .[] | .filename
jq.mv := "mv \(@sh)"
ascii.space := " "
ascii.quote := "\u0027"
unicode.nbsp := "\u00a0"
unicode.rsquo := "\u2019"

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
$~: jq := $(jq.files) | . as $$i | $(patterns)[] as $$p | $$i | select(test($$p)) | [$$i, sub($$p; "")] | $(jq.mv)
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
$($~.pat): elist := ^Délivré à
$($~.pat): elist += french-bookys.org$$
$($~.pat): elist += ^Powered by TCPDF
$($~.pat): elist += ^$$
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
$~: scan := "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}"
$~: jq := . + { AnyDate: (.ModDate // .CreationDate // .FileDate) }
$~: jq += | select(.AnyDate | scan($(scan)) + "Z" | fromdate | strftime("%Y-%m-%d") != "1999-12-31")
$~: jq += | "touch -d \(.AnyDate) \"\(.FileName)\""
$~: pdfinfos; @ls .pdfinfo/*.json | xargs -i jq -r '$(jq)' {}
.PHONY: $~

ifdef NEVER
~ := date
$~.pat := .$~/%.date
$~.dep := .pdfinfo/%.json
$~.dir := $(dir $($~.pat))
$~s := $(pdfs:%.pdf=$($~.pat))
$($~.pat): cmd = jq .CreationDate $< | xargs -i echo touch -d '"{}"' $@
$($~.pat): $($~.dep) | $($~.dir); @$(cmd)
$($~.dir):; @mkdir $@
$~s: $($~s)
.PHONY: $~s

pdfdates: $(pdfs); @echo $^ | xargs basename -a -s .pdf | xargs -i echo touch -r .date/{}.date {}.pdf
endif

clean:; rm *.txt
.PHONY: clean

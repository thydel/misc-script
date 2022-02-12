#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:

top:; @date

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
~ := lcase-mp4
$~: from := "MP4$$"
$~: to := "mp4"
~ := no-space no-quote lcase-mp4
$~: jq := $(jq.files) | select(test($(from))) | [., sub($(from); $(to); "g")] | $(jq.mv)
$~:; @jc ls | jq -r '$(jq)'
.PHONY: $~
- := $~
~ := norm
$~: $-;
.PHONY: $~

suffixes := mp4 mkv avi

# https://ourcodeworld.com/articles/read/1484/how-to-get-the-information-and-metadata-of-a-media-file-audio-or-video-in-json-format-with-ffprobe
~ := json
%.$~: %; ffprobe -loglevel 0 -print_format json -show_format -show_streams '$<' > '$@' && touch -r '$<' '$@'
$~: $(foreach _, $(suffixes), $(eval $_ := $(wildcard *.$_))$($_:%=%.json))
.PHONY: $~

tmp := tmp

~ := all
] := $(tmp)/$~.json
$]: quote = $(foreach _, $1, '$_')
$]: jq := def group: select(length > 0) | { (.[0][0]): map(.[1]) | unique };
$]: jq +=   { name: .format.filename, streams: .streams | map([.codec_type, .tags.language] | select(.[1] // empty)) | group_by(.[0]) | map(group) | add }
$]: jq += | select(.streams)
$]: $] := jq -r '$(jq)'
$]: $(wildcard *.json) | $(tmp); @cat $(call quote, $(sort $^)) | $($@) > $@
$~: $]
.PHONY: $~
#
~ := vo-en-st-en
[ := $]
$~: jq :=   select(.streams | .audio and .subtitle)
$~: jq += | select(.streams | (.audio | any(. == "eng")) and (.subtitle | any(. == "eng")))
$~: jq += | .name
$~: $~ := jq -r '$(jq)'
$~: $[; @ < $< $($@) | xargs -i echo mv "'{}'" ../$@
.PHONY: $~
~ := st-en
[ := $]
$~: jq :=   select(.streams.subtitle)
$~: jq += | select(.streams.subtitle | any(. == "eng"))
$~: jq += | .name
$~: $~ := jq -r '$(jq)'
$~: $[; @ < $< $($@) | xargs -i echo mv "'{}'" ../$@
.PHONY: $~

$(tmp):; mkdir -p $@

~ := clean
$~:; find -type f -name '*.json' | xargs -r rm
.PHONY: $~

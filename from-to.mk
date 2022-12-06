#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables

f ?= pdf
t ?= txt
$f=$(wildcard *.$f)
$t=$($f:%.$f=%.$t)
main: $($t)
%.txt: %.pdf; pdftotext $<
%.lst: %.pdf; pdfimages -list $<
convert = convert $< $@
%.png: %.jpg; $(convert)

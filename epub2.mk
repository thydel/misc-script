#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony

self := $(lastword $(MAKEFILE_LIST))
$(self):;

epubs := $(shell find -name '*.epub' | sort | tr ' ' \?)
mobis := $(epubs:%.epub=%.mobi)
pdfs  := $(epubs:%.epub=%.pdf)

_  :=
__ := $_ $_
<_  = $(subst ?,$(__),$<)
@_  = $(subst ?,$(__),$@)

nice := nice -n 19 ionice -c 3

mobi.dep := epub
mobi.cmd  = $(nice) ebook-convert "$(<_)" "$(@_)"

pdf.dep := $(mobi.dep)
pdf.cmd  = $(mobi.cmd)

rules   := mobi pdf
targets := $(rules:%=%s)

rule = $(eval %.$1: %.$$($1.dep); $$($1.cmd))

$(foreach _,$(rules),$(call rule,$_))

$(epubs):;
main: $(targets);

.SECONDEXPANSION:

$(targets): $$($$@);

#!/usr/bin/env -S make -Orecurse --no-print-directory -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony
.DEFAULT_GOAL := main

self := $(lastword $(MAKEFILE_LIST))
$(self):;

dict := /usr/share/dict/american-english
dir := tmp/wordle
$(dir):; mkdir -p $@
$(dir)/five-letters: $(dict) | $(dir); < $< sed -e "s/'s$$//" | grep '^.....$$' | tr '[:upper:]' '[:lower:]' | sort -u > $@
$(dir)/five-unique-letters: $(dir)/five-letters; < $< grep -Ev '(.).*\1' > $@
first: $(dir)/five-unique-letters phony; < $< shuf -n1
look: $(dir)/five-letters phony; < $< grep $g $(if $e, | grep -v [$e]) $(if $w, | grep '.*[$w].*')
main: phony $(dir)/five-unique-letters

# Local Variables:
# indent-tabs-mode: nil
# End:

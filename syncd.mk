#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony
_WS := $(or) $(or)
_comma := ,
.RECIPEPREFIX := $(_WS)
.DEFAULT_GOAL := main

self := $(lastword $(MAKEFILE_LIST))
$(self):;

pwd != pwd

include .syncd.mk
$(if $(and $(dirs), $(rem)),, $(error needs dirs and rem))
syncs := $(dirs:%=%.sync)
cleans := $(dirs:%=%.clean)
sts :=

~ := $(syncs)
$~: cpal = proot -w $* cp -al . ../$*.cpal
$~: . = ssh $(rem) proot -w $(pwd) $(cpal);
$~: . += $(cpal);
$~: . += rsync -avzH $(DRY) $(DEL) $*{,.cpal} $(rem):$(pwd)
$~: %.sync: phony; $(strip $.)
sts += sync

~ := $(cleans)
$~: .  = find $*.cpal -maxdepth 1 -type f -links +2 |
$~: . += xargs -r echo rm
$~: %.clean: phony; @$(strip $.)
sts += clean

DRY := -n
DEL :=

run := DRY :=
del := DEL := --delete

vartar := run del

$(vartar):; @: $(eval $($@))

seq = {$(subst $(_WS),$(_comma),$(strip $1))}

help: phony; echo [$(call seq, $(vartar))] $(call seq, $(dirs)).$(call seq, $(sts))
main: phony help

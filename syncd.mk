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

~ := $(syncs)
$~: cpal = cp -al $* $*.cpal
$~: . = ssh $(rem) proot -w $(pwd) $(cpal);
$~: . += $(cpal);
$~: . += rsync -avzH $(DRY) $(DEL) $*{,.cpal} $(rem):$(pwd)
$~: %.sync: phony; $(strip $.)

DRY := -n
DEL :=

run := DRY :=
del := DEL := --delete

vartar := run del

$(vartar):; @: $(eval $($@))

help: phony; @echo "[$(vartar)] $(syncs)"
main: phony help

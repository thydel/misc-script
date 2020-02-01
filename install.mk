#!/usr/bin/make -f

MAKEFLAGS += -Rr 
MAKEFLAGS += --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:

.RECIPEPREFIX :=
.RECIPEPREFIX +=

.DEFAULT_GOAL := install

MIN_VERSION := 4.1
VERSION_ERROR :=  make $(MAKE_VERSION) < $(MIN_VERSION)
$(and $(or $(filter $(MIN_VERSION),$(firstword $(sort $(MAKE_VERSION) $(MIN_VERSION)))),$(error $(VERSION_ERROR))),)

self := $(lastword $(MAKEFILE_LIST))
$(self):;

$(and $(or $(filter $(MAKECMDGOALS),staff),$(filter staff,$(shell groups)),$(error $(USER) not in group staff ($(self) staff -n))),)

install := install
$(and $(or $(filter $(suffix $(self)),.$(install)),$(error ln -s install.mk file.$(install))),)

basename := $(basename $(self))
suffixes := .sh .awk .mk .py .pl .jq
suffixp := $(filter $(suffix $(basename)),$(suffixes))
name := $(if $(suffixp),$(basename $(basename)),$(basename))
suffix := $(if $(suffixp),$(suffix $(basename)))

installed := /usr/local/bin/$(name)
install: $(installed);
.PHONY: install
$(installed): $(name)$(suffix); install $< $@

# newgrp does « execl(shell, shell, (char *)0); »
# So, we can't automate the sequence « newgrp staff; newgrp »

staff := getent group staff > /dev/null || sudo adduser $(USER) staff;
staff += groups | grep staff > /dev/null || echo -e "source <(echo exec newgrp staff)\nsource <(echo exec newgrp)";
staff:; @$($@)
.PHONY: staff

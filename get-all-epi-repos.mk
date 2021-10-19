#!/usr/bin/make -f

MAKEFLAGS += -Rr --warn-undefined-variables
SHELL != which bash
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony
_WS := $(or ) $(or )
_comma := ,
.RECIPEPREFIX := $(_WS)
.DEFAULT_GOAL := main

self := $(lastword $(MAKEFILE_LIST))
$(self):;

push = $(eval _~ := $~ $(_~))
pop = $(eval ~ := $(firstword $(_~)))$(eval _~ := $(wordlist 2, $(words $(_~)), $(_~)))

dirs :=
tmp := tmp
dirs += $(tmp)
$(dirs):; mkdir -p $@

~ := shell
$~.auth := pass github/tokens/thyepi/gh | gh auth login -h github.com --with-token
$(push)
~ := $~.list-repos.fields
$~ := createdAt description diskUsage forkCount hasWikiEnabled id isArchived isEmpty isFork
$~ += isInOrganization isPrivate latestRelease name nameWithOwner owner parent
$~ += projects pushedAt sshUrl updatedAt url viewerCanAdminister viewerPermission watchers
$~ := $(subst $(_WS),$(_comma),$($~))
$(pop)
$~.list-repos := gh repo list --json $($~.list-repos.fields) -L 999 Epiconcept-Paris

shells := auth list-repos

$(foreach _, $(shells), $(eval $_.sh := $_ () { $(shell.$_); }))

~ := $(tmp)/repos.json
$~: funcs := $(list-repos.sh)
$~: $~ = $(funcs); list-repos $(basename $@)
$~: | $(tmp); $($(@)) | jq > $@
repos: phony $~

auth: phony; $(auth.sh); auth

github.accounts := forchard slgevens

jq.github.accounts := [ $(subst $(_WS),$(_comma),$(foreach _,$(github.accounts),"$_")) ]
~ := jq.select-repos
$~.fork := ((.isFork | not) or (.isFork and ([ .parent.owner.login ] - $(jq.github.accounts) == [])))
$~.public := (.isPrivate | not)
$~.private := .isPrivate
jq.select-public-repos := select($($~.fork) and $($~.public))
jq.select-private-repos := select($($~.private))

public.jq := map($(jq.select-public-repos))
private.jq := map($(jq.select-private-repos))

~ := $(tmp)/%.json
$~: cmd = jq '$($*.jq)'
$~: $(tmp)/repos.json $(self); < $< $(cmd) > $@

sets := public private
makes := $(sets:%=$(tmp)/%.mk)

-include $(makes)

$(makes): $(tmp)/%.mk : $(tmp)/%.json; jq -r '"$*s := \(map(.name) | join(" "))"' $< > $@

export GIT_SSH_COMMAND := ssh -i ~/.ssh/t.delamare@epiconcept.fr -F /dev/null

set.rule = $1/%: | $1; cd $1; gh repo clone Epiconcept-Paris/$$*
$(foreach set,$(sets),$(eval $(call set.rule,$(set))))
$(sets):; mkdir -p $@

$(foreach set,$(sets),$(eval $(set)s: phony $$($(set)s:%=$(set)/%)))
sets: phony $(sets:%=%s)

main: phony sets

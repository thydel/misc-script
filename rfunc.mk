MAKEFLAGS += -Rr
MAKEFLAGS += --warn-undefined-variables
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony

.RECIPEPREFIX :=
.RECIPEPREFIX +=

top:; @date

space :=
space +=

in-emacs := $(and $(INSIDE_EMACS),$$$(space))

func = $1 () { $(subst €,$$,$($(strip $1))); }
import = $(foreach _,$1,$(call func,$_);)

args = $(foreach _,$1,$_="€{1:?}"; shift;)

run  = $(call args, node conn func)
run += $(if $(VERB),echo : €node €func "€@";)
run += (declare -f €func; echo €func "€@") | €conn €node

ssh := command ssh €1 bash
cat := command cat

foo := hostname; id -un; date; echo -€1-
bar := cat /etc/passwd | wc -l

define zor
test -f /etc/€{1:?} || { echo €1 is not a file >&2; exit 1; }
cat /etc/€1 > /tmp/1
wc -l /tmp/1
rm /tmp/1
endef

lfuncs := run ssh cat
rfuncs := foo bar zor
funcs := $(lfuncs) $(rfuncs)

funcs: phony; @$(call import, $(funcs)) declare -f $(funcs)

targ = $(foreach _, $(join $(1:%=%:=), $(subst /,$(space),$@)), $(eval $_))

nodes := make tdeltd.wato

targets := $(foreach node, $(nodes), $(foreach func, $(rfuncs), $(node)/$(func)/%))

#$(nodes:%=%/zor/%): phony
$(targets): phony
 @$(call import, $(funcs))
 $(call targ, node func arg)
 run $(node) $(RUN) $(func) $(arg)

RUN := ssh
dry := RUN := cat

VERB :=
verb := VERB := T

vartar := dry verb

$(vartar):; @: $(eval $($@))

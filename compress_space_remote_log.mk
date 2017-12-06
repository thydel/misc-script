#!/usr/bin/make -f

top:; @date
.PHONY: top

self    := $(lastword $(MAKEFILE_LIST))
sdir    := $(dir $(abspath $(self)))
$(self) := $(basename $(self))
name    := $(notdir $($(self)))
$(self):;

USER ?= unknown

staff := staff
$(if $(shell getent group $(staff) | grep -q $(USER) || test $(USER) = root || date),$(error $(USER) not in group $(staff)))

b := /space/remote_logs

n ?= 8
y := $(shell date -d '$n days ago' +%Y)
m := $(shell date -d '$n days ago' +%m)
d := $(shell date -d '$n days ago' +%d)
p := [a-z]*/$y/$m/$d

test  := [ "$$(echo $p)" != "$p" ]
find  := (cd $b; $(test) && find $p -maxdepth 0 -type d | sort)
tgz   := $(find) | xargs -i echo tar czf $b/{}.tgz -C $b {}
clean := $(find) | xargs -i echo test -s $b/{}.tgz -a -d $b/{} '&&' rm -r $b/{}

trgts := tgz clean
tgz clean:; @$(strip $($@)) | $(RUN)
.PHONY: $(trgts)

ifeq ($(dir $(self)),./)
install_dir  := /usr/local/bin
install_list := $(self)
$(install_dir)/%: %; install $< $@; $(if $($*),(cd $(@D); $(strip $(foreach _, $($*), ln -sf $* $_;))))
install: $(install_list:%=$(install_dir)/%);
endif

RUN  := cat
runv := RUN := dash -v
run  := RUN := dash

vartar := run runv
$(vartar):; @: $(eval $($@))

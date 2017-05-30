#!/usr/bin/make -f

SHELL := $(shell which bash)

top:; @date
.PHONY: top

self    := $(lastword $(MAKEFILE_LIST))
sdir    := $(dir $(abspath $(self)))
$(self) := $(basename $(self))
name    := $(notdir $($(self)))
$(self):;

staff := staff
$(if $(shell getent group $(staff) | grep -q $(USER) || date),$(error $(USER) not in group $(staff)))

N     := 10
S     := 1
seq   := $(or $n, $N)
sleep := $(or $s, $S)
lynx  := lynx -dump -width 1024 http://127.0.0.1/server-status
awk   := /^ +[0-9]+-[0-9]+ / && $$4 == "W" && $$11 != "127.0.0.1" { print $$11, $$12, $$14 }
loop  := seq $(seq) | xargs -i echo $$'sleep $(sleep); $(lynx) | awk \'$(awk)\''

date := $(shell date +%s)
dir  := $(HOME)/$(name).d

$(dir)/.stone:; mkdir -p $(@D); touch $@
$(dir)/$(date)-0-run: $(dir)/.stone; @echo $(name) n=$(seq) s=$(sleep) > $@
$(dir)/$(date)-1-status: $(dir)/$(date)-0-run; $(loop) | dash | column -t > $@

sortn = sort | uniq -c | sort -nr

2-ips    := $$1
3-vhosts := $$2
4-urls   := $$2,$$3

2sort  := 2-ips 3-vhosts 4-urls
sorted := $(2sort:%=$(dir)/$(date)-%)

$(sorted): $(dir)/$(date)-% : $(dir)/$(date)-1-status; awk '{print $($*)}' $< | $(sortn) > $@

main: $(sorted);
.PHONY: main

ifeq ($(dir $(self)),./)
install_dir  := /usr/local/bin
install_list := $(self)
$(install_dir)/%: %; install $< $@; $(if $($*),(cd $(@D); $(strip $(foreach _, $($*), ln -sf $* $_;))))
install: $(install_list:%=$(install_dir)/%);
endif

help:
	@echo 'make -f $(name).mk install # invoking user must be in group staff'
	@echo '$(name) help';
	@echo '$(name) main n=$$n s=$$s # concatenate and sort $$n server-status invocations with $$s second sleep between'
	@echo '# number of iteration defaut to $N'
	@echo '# sleep time between server-status invocations defaut to $S'
	@echo '# server status is filtered to keep only "Sending Reply" workers'
	@echo '# only IP, vhost and Request path are kept'
	@echo '# after loop on server-status, IPs, vhosts and URLs are sorted and counted'
	@echo '# output files are wroten in $(dir), created if missing'

.PHONY: help
.DEFAULT_GOAL := help

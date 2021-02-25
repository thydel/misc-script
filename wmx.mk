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

targets :=

rofi.lines := 42
rofi.width := 95

~ := all
$~: $~ = $(windows.show) | $(window.go)
$~: phony; @$($@)
targets += $~

~ := cur
$~: desktops := wmctrl -d
$~: current.awk := $$2 == "*" { print ++$$1; }
$~: desktop.current := $(desktops) | awk '$(current.awk)'
$~: desktop.select := $$2 == desktop
$~: desktop.show := awk -v desktop=$$($(desktop.current)) '$(desktop.select)'
$~: rofi.lines := $$(($(rofi.lines) / 2))
$~: $~ = $(windows.show) | $(desktop.show) | $(window.go)
$~: phony; @$($@)
targets += $~

~ := $(targets)
$~: windows.list := wmctrl -l | sed 's/\xEF\xBB\xBF//'
$~: windows.select := $$2 >= 0 { $$2 += 1; print; }
$~: windows.sort := sort -k 2,2n -k 3,3 -k 4.4
$~: windows.show := $(windows.list) | awk '$(windows.select)' | $(windows.sort)
$~: window.select = (rofi -width $(rofi.width) -lines $(rofi.lines) -dmenu || cat)
$~: window.switch := fmt -1 | head -1 | xargs -r wmctrl -i -a
$~: window.go = $(if $(TXT), cat, $(window.select) | $(window.switch))

tools := wmctrl rofi
$(tools): %: phony /usr/bin/%
/usr/bin/%:; sudo aptitude install $(@F)

$(targets): $(tools)

main: phony; @echo $(targets)

TXT :=
txt := TXT := txt
vartar := txt
$(vartar):; @: $(eval $($@))

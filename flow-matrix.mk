#!/usr/bin/make -f

top:; @date

data := /usr/local/etc/epi/data/oxa

flow-matrix-data.json: $(data)/ips.json $(data)/groups.json; jq -s . $^ > $@
main: flow-matrix.jq flow-matrix-data.json; jq -f $< -nr | column -t

.PHONY: main

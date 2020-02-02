#!/usr/bin/make -f

top:; @date

flow-matrix.mk:;

data := /usr/local/etc/epi/data/oxa

data.json: $(data)/ips.json $(data)/groups.json; jq -s . $^ > $@

flow-matrix.tsv: data.json Set.jq flow-matrix.jq flow-matrix-data.jq flow-matrix.mk
	flow-matrix-data.jq -nr | column -t | tee $@

main: flow-matrix.tsv

.PHONY: main

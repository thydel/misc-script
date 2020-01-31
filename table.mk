top:; @date

data := /usr/local/etc/epi/data/oxa

table.json: $(data)/ips.json $(data)/groups.json; jq -s . $^ > $@

main: table.json
.PHONY: main

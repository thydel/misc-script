top:; @date

data := /usr/local/etc/epi/data/oxa

table.json: $(data)/ips.json $(data)/groups.json; jq -s . $^ > $@
main: table.jq table.json; jq -f $< -nr | column -t

.PHONY: main

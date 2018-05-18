#!/usr/bin/awk -f

# This script make a table from lines of "vhost user-agent hit-count
# page-count" extracted from awststa(1) data

# Those User-Agent are not OK for TLS 1.2
# UA-by-vhost-to-csv.awk -v ual="firefox11.0 firefox12.0 firefox17.0 msie7.0 msie8.0 msie9.0 msie10.0"

BEGIN { split(ual, ua) }
{ v[$1]++; t[$1][$2][0] = $3; t[$1][$2][1] = $4 }
END { head(); lines() }

function head() { print "vhosts", ual }

function lines() {
    for (i in v) {
	l = i
	for (j in ua) {
	    h = t[i][ua[j]][0]; p = t[i][ua[j]][1]
	    l = l FS (h ? h : 0) "/" (p ? p : 0)
	}
	print l
    }
}

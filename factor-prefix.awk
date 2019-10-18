#!/usr/bin/gawk -f

BEGIN {
    m = (filter == "" ? "." : filter);
    o = " ";
    s = " ";
    c = "";
    if (fmt == 1) {
	o = " {";
	s = ",";
	c = "}";
    }
}

function nxt() { i = 0; p1 = $1; p2 = $2; next }

function prt() {
    if (squeeze == 1) {
	if (i > 1) {
	    printf p1 o n[i - 1];
	} else {
	    printf p1 o n[0];
	}
    } else {
	printf p1 o n[0];
	for (j = 1; j < i; ++j) { printf s n[j] }
    }
    printf c "\n"
}

$1 ~ m && NR == 1 { nxt() }

$1 ~ m && $1 == p1 { n[i++] = p2; p2 = $2 }

($1 !~ m || $1 ~ m && $1 != p1) && !i { print p1 " " p2; nxt() }

$1 !~ m || $1 ~ m && $1 != p1 {
    n[i++] = p2;
    prt()
    nxt()
}


END { if (!i) { print p1 " " p2 } else { n[i++] = p2; prt() } }

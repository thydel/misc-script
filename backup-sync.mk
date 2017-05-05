top:; @date

SHELL := $(shell which bash)

remote := backup.somewhere.tld

base := abase
node := anode
part := apart
path := $(base)/$(node)/$(part)

DRY     := -n
bwlimit := 512k

find   = cd $(base);
find  +=   find $1 -type f -printf '%T@\t%p\n'
find  += | sort -n | cut -f2

rsync  = rsync -avP $(DRY)
rsync +=       --bwlimit=$(bwlimit)
rsync +=       --files-from=<($(find))
rsync +=       $(base) $(remote):$(base)

parts := $(shell cd $(base); ls -d */* | cut -f2 -d/ | sort -u)

$(parts:%=\%/%):; $(strip $(call rsync, $@))

run    := DRY :=
vartar := run
$(vartar):; @: $(eval $($@))

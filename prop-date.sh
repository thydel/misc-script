#!/bin/bash                                                                                                          

# git clone git@thydel.github.com:thydel/misc-script.git
# (cd misc-script; ls *.install | dash)

touchr() { test "$1" -nt "$2" && echo touch -r "$1" "$2"; }; export -f touchr
exclude() { grep -v /.git; }; export -f exclude

reset_dir_date() { find $1 -type d | exclude | xargs touch -d @0; }
propagate_date() { find $1 -depth -type d | exclude | xargs -i echo 'ls -t {} | echo touchr {}/$(head -n1) {}' | dash | bash; }

reset_prop_date() { reset_dir_date $1; propagate_date $1; }

case $(basename $0) in
    reset-dir-date) reset_dir_date ${1:?};;
    prop-date) propagate_date ${1:?} | ${RUN:-cat};;
    reset-prop-date) reset_prop_date ${1:?} | ${RUN:-cat};;
esac

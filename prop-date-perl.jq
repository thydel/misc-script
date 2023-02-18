#!/usr/bin/env -S jq -nrf --args

include "prop-date-lib" { search: "/usr/local/lib" };

main | perl

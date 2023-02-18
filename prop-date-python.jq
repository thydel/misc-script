#!/usr/bin/env -S jq -nrf --args

include "prop-date-lib" { search: "/usr/local/lib" };

"import os", (main | python)

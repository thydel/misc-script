#!/usr/bin/env bash

find ${1:?} -type f -print0 | xargs -0 stat | jc --stat-s | jq '[ .file, .modify_time_epoch ]'

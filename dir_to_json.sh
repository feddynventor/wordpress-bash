#!/bin/bash

function load_sublevel {
  find "$1" -maxdepth 1 -type d | while read DIR; do
    if [ "$DIR" = "$1" ]; then continue; fi

    KEY=$( echo "$DIR" | sed "s/\.\///" )
    SUB_DIR="$( echo "$KEY" | sed 's/\(.*\)\//\1\n/' | tail -n1 )"

    SUB=$( load_sublevel "$DIR" | jq --compact-output --slurp )

    cat "$DIR"/* 2>/dev/null \
    | jq '.[] | select(.!=null)' \
    | jq --compact-output --slurp 'sort_by(.date)' \
    | jq --compact-output --arg k "$SUB_DIR" --argjson v "$SUB" '{$k:[$v[],.[]]}'

    
  done
}

cd $1
load_sublevel "./" | jq --slurp

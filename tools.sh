declare -A jq
jq+=(lineinfile '[inputs] | .[], map({(.): null}) | add | if has($line) then empty else $line end')
lineinfile () { : ${2:?}; < $2 jq --arg line $1 "${jq[${FUNCNAME[0]}]}" -Rrn | sponge $2; }

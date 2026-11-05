#!/bin/bash
# uso: run.sh <A|B|C> <pi|oc> <modelo> <rodada>   (acrescenta uma linha em results.tsv)
B=$(cd "$(dirname "$0")" && pwd); t=$1; rt=$2; m=$3; r=$4
tag=$(echo "$t-$rt-$m-r$r" | tr '/:' '__')
d=$(mktemp -d "$CLAUDE_JOB_DIR/tmp/b-$tag-XXXX"); cp "$B"/tasks/$t/*.py "$d"/; cd "$d"
case $t in A) echo 21 ;; B) echo 13 ;; C) echo 17 ;; esac > expected_total
md5sum test_*.py $( [ $t = B ] && echo rates.py ) > protected.md5
P=$(cat "$B/tasks/$t/PROMPT.txt")
s=$(date +%s)
if [ $rt = pi ]; then timeout -k 10 600 pi -p --no-session --model "$m" "$P" < /dev/null > out.txt 2>&1
else timeout -k 10 600 opencode run --standalone -m "$m" "$P" < /dev/null > out.txt 2>&1; fi
rc=$?; secs=$(( $(date +%s)-s ))
res=$("$B/check.sh" "$d" $t)
# erro de provider: padrões de 429/overloaded/etc. no log
prov=$(grep -ciE '\b429\b|overloaded|rate[ -]?limit|too many requests|ResourceExhausted|temporarily|service unavailable|\b50[234]\b|finish_reason: error' out.txt)
hang=0; [ $rc = 124 ] || [ $rc = 137 ] && hang=1
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\tprov=%s\thang=%s\t%s\n' "$(date +%H:%M:%S)" "$t" "$rt:$m" "r$r" "rc=$rc" "${secs}s" "$res" "$prov" "$hang" "$d" >> "$B/results.tsv"
tail -1 "$B/results.tsv"

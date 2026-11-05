#!/bin/bash
# uso: task.sh <runtime pi|oc> <modelo>
rt=$1; m=$2; tag=$(echo "$rt-$m" | tr '/:' '__')
d=$(mktemp -d $CLAUDE_JOB_DIR/tmp/t-$tag-XXXX); cd $d
P='Crie soma.py com a função soma(a, b) que retorna a+b, e test_soma.py com testes unittest (pelo menos 3 casos) para ela. Rode "python3 -m unittest -v" e confirme que passa. Responda só: feito.'
run(){ if [ $rt = pi ]; then timeout $2 pi -p --no-session --model "$m" "$1" < /dev/null; else timeout $2 opencode run --standalone -m "$m" "$1" < /dev/null; fi; }
s=$(date +%s); o=$(run 'responda só: ok' 90 2>&1); rc=$?; t1=$(( $(date +%s)-s ))
echo "[$rt $m] PROBE rc=$rc ${t1}s: $(echo "$o" | tail -c 150 | tr '\n' ' ')"
if [ $rc -eq 0 ]; then
  s=$(date +%s); run "$P" 300 >out.txt 2>&1; rc=$?; t2=$(( $(date +%s)-s ))
  python3 -m unittest 2>&1 | tail -3 > ver.txt; v=$(grep -c '^OK' ver.txt)
  echo "[$rt $m] TASK rc=$rc ${t2}s files=$(ls | tr '\n' ,) unittest_ok=$v dir=$d"
fi

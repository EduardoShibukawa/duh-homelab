#!/usr/bin/env bash
# uso: run-plan.sh <dir do PLAN>  -> roda TASKs em ordem de depends_on; imprime JSON por TASK
D=$1; declare -A ST; for p in ${PASSED:-}; do ST[$p]=pass; done
for f in $(ls $D/TASK-*.md | sort); do
  b=$(basename $f .md)
  deps=$(sed -n '2,/^---$/p' $f | grep -m1 '^depends_on:' | grep -o 'TASK-[0-9]*-[a-z0-9-]*')
  skip=""; for d in $deps; do [ "${ST[$d]:-}" = pass ] || skip=$d; done
  if [ -n "$skip" ]; then ST[$b]=blocked; echo "$(date +%F) ${b:0:7} blocked (dep: $skip)" >>$D/log.md
    echo "{\"task\":\"$b\",\"status\":\"blocked (dep)\",\"model\":null,\"attempts\":0}"; continue; fi
  [ "${ST[$b]:-}" = pass ] && continue
  out=$(/home/shibuka/Projetos/duh-homelab/.ginga/bin/dispatch-task.sh $f | tail -1); echo "$out"
  echo "$out" | grep -q '"status":"pass"' && ST[$b]=pass || ST[$b]=blocked
done

#!/bin/bash
# uso: lane.sh <nome> <rodada> <modelo>...   (modelos no formato rt:modelo; roda A,B,C de cada um em sequência)
B=$(cd "$(dirname "$0")" && pwd); name=$1; r=$2; shift 2
cnt=0
orleft(){ K=$(pi auth print-api-key --provider openrouter 2>/dev/null); curl -s -H "Authorization: Bearer $K" https://openrouter.ai/api/v1/key | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['free_model_daily_requests']['remaining'])"; }
for spec in "$@"; do
  rt=${spec%%:*}; m=${spec#*:}
  for t in A B C; do
    case $m in *openrouter*) left=$(orleft); if [ "${left:-0}" -lt 300 ]; then echo "$name: OR restante=$left <300, parando" >> $B/lane-$name.log; exit 3; fi ;; esac
    line=$($B/run.sh $t $rt "$m" $r)
    echo "$line" >> $B/lane-$name.log
    p=$(echo "$line" | grep -o 'prov=[0-9]*' | cut -d= -f2); ok=$(echo "$line" | grep -o 'ok=[01]' | head -1)
    if [ "${p:-0}" -gt 0 ] && [ "$ok" = ok=0 ]; then cnt=$((cnt+1)); else cnt=0; fi
    if [ $cnt -ge 2 ]; then echo "$name: 2 erros de provider seguidos, pausa 300s" >> $B/lane-$name.log; sleep 300; cnt=0; fi
  done
done
echo "$name: rodada $r fim" >> $B/lane-$name.log

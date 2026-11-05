#!/usr/bin/env bash
# uso: pipeline.sh <prompt-do-operador.md> [modelo]
# Três processos separados (design/ginga-revamp/02):
#   1. operador LLM (opencode run): despacha o executor + pinga verify e grava plans/<P>/ready/<repo>.json {"branch"}; NÃO mergeia
#   2. judge-run.sh: Codex read-only, um processo por PLAN×repo
#   3. merge-gate.sh: determinístico (veredito, receipts, suíte, revert)
# Se a main de algum repo andar durante o passo 1, aborta e avisa (CRÍTICO).
set -u
DUH=/home/shibuka/Projetos/duh-homelab; G=$DUH/.ginga; B=$G/bin
prompt=$(readlink -f "$1"); [ -s "$prompt" ] || { echo "prompt vazio ou ausente: $1"; exit 2; }; model=${2:-opencode-go/beam-free}; REPOS="manda p-inga ginga"
say(){ /home/shibuka/Projetos/duh-homelab/.ginga/bin/notify.sh "$1"; }
before=$(for r in $REPOS; do echo "$r $(git -C $DUH/$r rev-parse main)"; done)
log=$G/handoffs/$(basename "$prompt" .md).log
name=$(basename "$prompt" .md)
(cd $DUH && timeout 10800 opencode run --standalone --auto -m "$model" --title "$name" "$(cat "$prompt")" > "$log" 2>&1) & op=$!
# vigia infra_stuck (SPEC-0003): sem CPU nova e sem log novo por STUCK_S -> mata e avisa
cpu(){ pgrep -f -- "--title $name" | xargs -r ps -o times= -p | awk '{s+=$1} END{print s+0}'; }
last=$(cpu); idle=0; STUCK_S=${STUCK_S:-900}
while kill -0 $op 2>/dev/null; do
  sleep 60; now=$(cpu); age=$(( $(date +%s) - $(stat -c %Y "$log") ))
  if [ "$now" != "$last" ] || [ $age -lt 60 ]; then idle=0; last=$now; else idle=$((idle+60)); fi
  [ $idle -ge $STUCK_S ] && { pkill -f -- "--title $name"; say "infra_stuck: operador $name sem CPU e sem log por ${idle}s, morto"; break; }
done; wait $op 2>/dev/null
after=$(for r in $REPOS; do echo "$r $(git -C $DUH/$r rev-parse main)"; done)
[ "$before" = "$after" ] || { say "CRÍTICO: o operador alterou a main sem gate. Antes: $(echo $before) | Depois: $(echo $after). Gate não rodou."; exit 20; }
summary=""
for f in "$G"/plans/*/ready/*.json; do
  [ -f "$f" ] || continue
  P=$(dirname "$(dirname "$f")"); repo=$(basename "$f" .json)
  br=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["branch"])' "$f")
  j=$("$B/judge-run.sh" "$P" "$repo" "$br"); jx=$?
  if [ $jx -ne 0 ]; then summary+="$(basename "$P") $repo: judge falhou ($j)\n"; continue; fi
  g=$("$B/merge-gate.sh" "$P" "$repo" "$br"); gx=$?
  summary+="$(basename "$P") $repo: gate $gx\n"
  [ $gx -eq 0 ] && mkdir -p "$P/ready/done" && mv "$f" "$P/ready/done/"
done
say "Pipeline $(basename "$prompt" .md): $(printf "$summary" | tr '\n' ';')"

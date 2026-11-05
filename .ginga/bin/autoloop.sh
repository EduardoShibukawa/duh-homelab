#!/usr/bin/env bash
# uso: autoloop.sh [rodadas=4]  -> várias rodadas de pipeline.sh, com o prompt gerado do estado (sem LLM no laço)
# Cada rodada recebe as regras fixas (prompts/op-base.md), os achados reprovados do judge para cada ready/*.json
# (gate barrou) e o backlog (prompts/backlog.md). Para quando não sobra ready nem backlog, ou quando a rodada não muda nenhuma branch.
set -u
DUH=/home/shibuka/Projetos/duh-homelab; G=$DUH/.ginga; N=${1:-4}
say(){ /home/shibuka/Projetos/duh-homelab/.ginga/bin/notify.sh "$1"; }
heads(){ for f in "$G"/plans/*/ready/*.json; do [ -f "$f" ] || continue; P=$(dirname "$(dirname "$f")"); r=$(basename "$f" .json)
  b=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["branch"])' "$f"); echo "$r $b $(git -C $DUH/$r rev-parse "$b" 2>/dev/null)"; done
  for w in $(sed -nE 's/^- worktree: *([^ ]+).*/\1/p' "$G/prompts/backlog.md"); do echo "$w $(git -C $DUH/$w rev-parse HEAD 2>/dev/null)"; done; }
for i in $(seq 1 "$N"); do
  p=$G/prompts/auto-$(date +%Y%m%d-%H%M)-r$i.md
  { cat "$G/prompts/op-base.md"; echo; echo "## Rodada automática $i: corrija os achados do judge (o gate barrou)"
    for f in "$G"/plans/*/ready/*.json; do [ -f "$f" ] || continue; P=$(dirname "$(dirname "$f")"); r=$(basename "$f" .json)
      echo; echo "### $(basename "$P") ($r, branch $(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["branch"])' "$f"))"
      tail -1 "$P/log.md" | sed 's/^/- gate: /'
      [ -f "$P/judge/$r.json" ] && python3 -c '
import json,sys
for i in json.load(open(sys.argv[1]))["judge"]["items"]:
    if not i["ok"]: print("- [%s]%s %s" % (i["ref"], " REGRESSÃO" if i.get("regression") else "", i["evidence"]))' "$P/judge/$r.json"
    done
    echo; echo "## Backlog"; cat "$G/prompts/backlog.md"; } > "$p"
  has=$(ls "$G"/plans/*/ready/*.json 2>/dev/null | wc -l); bl=$(grep -c '^- \[ \]' "$G/prompts/backlog.md")
  [ "$has" -eq 0 ] && [ "$bl" -eq 0 ] && { say "autoloop: nada pendente na rodada $i"; exit 0; }
  say "autoloop: rodada $i/$N começando: $has PLAN(s) com achado do judge, $bl item(ns) no backlog"
  before=$(heads); "$G/bin/pipeline.sh" "$p" >> "$G/handoffs/autoloop.out" 2>&1; px=$?
  [ $px -eq 20 ] && { say "autoloop: abortado na rodada $i (main alterada fora do gate)"; exit 20; }
  after=$(heads)
  [ "$before" = "$after" ] && [ "$(ls "$G"/plans/*/ready/*.json 2>/dev/null | wc -l)" -eq "$has" ] && { say "autoloop: rodada $i sem progresso (nenhuma branch mudou). Parado."; exit 3; }
done
say "autoloop: $N rodadas concluídas. Pendentes: $(ls "$G"/plans/*/ready/*.json 2>/dev/null | xargs -r -n1 dirname | xargs -r -n1 dirname | xargs -r -n1 basename | tr '\n' ' ')"

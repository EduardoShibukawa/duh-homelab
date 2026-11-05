#!/usr/bin/env bash
# uso: lane.sh <repo> [rodadas=6]  -> um laço autônomo por repo; as lanes rodam em paralelo sem se atrapalhar
# Rodada: prompt gerado do estado (op-base + achados do judge de plans/*/ready/<repo>.json + backlog-<repo>.md)
#   → operador LLM (só executor + verify) → judge-run.sh (processo próprio) → merge-gate.sh (determinístico)
# Aborta se a main do <repo> andar durante o operador. Para sem pendência ou sem progresso.
set -u
DUH=/home/shibuka/Projetos/duh-homelab; G=$DUH/.ginga; B=$G/bin; R=${1:?repo}; N=${2:-6}; OP_MODELS=${OP_MODELS//,/ }; OPM=(${OP_MODELS:-opencode/glm-5.3-flash-free opencode-go/deepseek-v4.1-flash opencode-go/qwen3.8-flash}); unset MODELS; [ -n "${EXEC_MODELS:-}" ] && export MODELS=${EXEC_MODELS//,/ };  # lane.env: listas separadas por vírgula (o vigia passa cada linha como um --setenv)
mi=0  # índice na escada OPM; precisa ser código, não comentário (set -u quebrava a lane com 'mi: unbound variable')
BL=$G/prompts/backlog-$R.md; touch "$BL"
source "$B/guard-env.sh"  # PLAN-0033: guard de segredos (padrão ligado; GINGA_GUARD=off desliga)
guard_require || { echo "[$R] guard ausente: lane não inicia" >&2; "$B/notify.sh" "[$R] guard ausente: lane não inicia" >> "$G/handoffs/lanes.events" 2>&1; exit 6; }
say(){ "$B/notify.sh" "[$R] $1" >> "$G/handoffs/lanes.events" 2>&1; }
readys(){ ls "$G"/plans/*/ready/$R.json 2>/dev/null; }
br_of(){ python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["branch"])' "$1"; }
state(){ for f in $(readys); do echo "$f $(git -C $DUH/$R rev-parse "$(br_of "$f")" 2>/dev/null)"; done
  for w in $(sed -nE 's/^- worktree: *([^ ]+).*/\1/p' "$BL"); do echo "$w $(git -C $DUH/$w rev-parse HEAD 2>/dev/null)"; done; md5sum < "$BL"; }
for i in $(seq 1 "$N"); do
  has=$(readys | wc -l); bl=$(grep -c '^- \[ \]' "$BL")
  [ "$has" -eq 0 ] && [ "$bl" -eq 0 ] && { say "lane: nada pendente; encerrada"; exit 0; }
  name=lane-$R-$(date +%Y%m%d-%H%M)-r$i; p=$G/prompts/$name.md
  { cat "$G/prompts/op-base.md"; echo; echo "## Lane $R, rodada $i: só o repo \`$R\`. Achados do judge primeiro (o gate barrou), depois o backlog."
    for f in $(readys); do P=$(dirname "$(dirname "$f")"); echo; echo "### $(basename "$P") (branch $(br_of "$f"))"
      tail -1 "$P/log.md" | sed 's/^/- gate: /'
      [ -f "$P/judge/$R.json" ] && python3 -c '
import json,sys
for i in json.load(open(sys.argv[1]))["judge"]["items"]:
    if not i["ok"]: print("- [%s]%s %s" % (i["ref"], " REGRESSÃO" if i.get("regression") else "", i["evidence"]))' "$P/judge/$R.json"
    done
    echo; echo "## Backlog ($BL; marque - [x] no que concluir)"; cat "$BL"; } > "$p"
  say "rodada $i/$N começando: $has com achado do judge, $bl no backlog"
  main0=$(git -C $DUH/$R rev-parse main); before=$(state); log=$G/handoffs/$name.log
  rt=0
  exec 9>"$G/handoffs/.op.lock"; flock -w 3600 9 || { say "operador ocupado há 60 min por outra lane: esta lane para (Nvidia free tem RPM baixo)"; exit 5; }
  while :; do  # laço interno: 429/rate limit re-tenta o MESMO modelo; cota esgotada troca de degrau — sem consumir rodada
  guard_export "$name"
  case ${OPM[$mi]} in
    claude/*) (cd $DUH && timeout 7200 claude -p --model "${OPM[$mi]#claude/}" --permission-mode auto --output-format stream-json --verbose --append-system-prompt "lane:$name" "$(cat "$p")" > "$log" 2>&1) & op=$!;;
    pi:*) (cd $DUH && timeout 7200 pi -p $(guard_pi_args) --model "${OPM[$mi]#pi:}" --append-system-prompt "lane:$name" "$(cat "$p")" < /dev/null > "$log" 2>&1) & op=$!;;  # dono 2026-10-29: NVIDIA free pelo Pi como operador
    *) (cd $DUH && env $(guard_opencode_env) timeout 7200 opencode run --standalone --auto -m "${OPM[$mi]}" --title "$name" "$(cat "$p")" > "$log" 2>&1) & op=$!;;
  esac
  # vigia infra_stuck (SPEC-0003): progresso = arquivo novo/alterado nas worktrees do repo ou saída real no log
  # (as linhas "> build" sozinhas não contam). 45 min sem progresso (NVIDIA free tem TTFT alto): mata o operador e troca de modelo na rodada seguinte
  prog(){ grep -v '^> build' "$log" 2>/dev/null | wc -c; }
  lastp=$(prog); idle=0; stuck=0
  while kill -0 $op 2>/dev/null; do sleep 60; nowp=$(prog)
    fresh=$(find $DUH/$R $DUH/$R-* -newermt '-60 seconds' -type f -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -1)
    if [ "$nowp" != "$lastp" ] || [ -n "$fresh" ]; then idle=0; lastp=$nowp; else idle=$((idle+60)); fi
    [ $idle -ge 2700 ] && { pkill -f -- "--title $name"; pkill -f -- "lane:$name"; stuck=1; mi=$(( (mi+1) % ${#OPM[@]} )); say "infra_stuck: operador sem progresso por ${idle}s, morto; próximo modelo ${OPM[$mi]}"; break; }
  done; wait $op 2>/dev/null
  if [ "$(wc -c <"$log")" -lt 6000 ] && grep -qiE '"status":[[:space:]]*429|too many requests|rate limit' "$log" && [ $rt -lt 3 ]; then
    rt=$((rt+1)); say "429/rate limit em ${OPM[$mi]}: nova tentativa $rt/3 no mesmo modelo em 60s"; sleep 60; continue; fi
  if [ "$(wc -c <"$log")" -lt 6000 ] && grep -qiE 'free usage limit|usage limit (reached|exceeded)|quota (exceeded|reached)' "$log"; then  # só erro curto: log grande é trabalho real que pode citar o texto
    mi=$((mi+1)); [ $mi -ge ${#OPM[@]} ] && { touch "$G/handoffs/.free-esgotado"; say "todos os modelos sem cota: lane pausada; o vigia tenta de novo em 1 h"; exit 4; }
    say "sem cota em ${OPM[$((mi-1))]}: rodada repetida com ${OPM[$mi]}"; continue; fi
  exec 9>&- 2>/dev/null; break; done
  [ "$(git -C $DUH/$R rev-parse main)" = "$main0" ] || { say "CRÍTICO: a main de $R mudou durante o operador (fora do gate). Lane parada."; exit 20; }
  sum=""
  for f in $(readys); do P=$(dirname "$(dirname "$f")"); br=$(br_of "$f")
    j=$("$B/judge-run.sh" "$P" "$R" "$br"); [ $? -ne 0 ] && { sum+="$(basename "$P"): judge falhou; "; continue; }
    g=$("$B/merge-gate.sh" "$P" "$R" "$br"); gx=$?
    sum+="$(basename "$P"): gate $gx; "
    [ $gx -eq 0 ] && mkdir -p "$P/ready/done" && mv "$f" "$P/ready/done/$R-$(date +%H%M).json"
  done
  say "rodada $i: ${sum:-nenhum ready}"
  [ "$before" = "$(state)" ] && [ $stuck -eq 0 ] && { say "rodada $i sem progresso (nada mudou). Lane parada."; exit 3; }
done
say "lane: $N rodadas concluídas"

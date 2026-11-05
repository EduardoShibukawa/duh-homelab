#!/usr/bin/env bash
# uso: dispatch-task.sh <TASK.md>  -> imprime 1 linha JSON no fim
# Zen free primeiro; esgotado → opencode-go (assinatura do dono, Extra Usage off). Pago = opencode/deepseek-v4-pro:
# máx. 2 tentativas e US$0,50 por TASK, US$2,00 no total (arquivo paid-spend.tsv).
# Teto checado ANTES de cada tentativa paga: folga >= estimativa (maior custo pago já visto, mín. US$0,15).
# Rollback = snapshot da árvore INTEIRA no início da TASK (preserva o trabalho de TASKs anteriores, não commitado).
set -u
DUH=/home/shibuka/Projetos/duh-homelab
T=$(readlink -f "$1"); TN=$(basename "$T" .md); TID=${TN%%-[a-z]*}   # TASK-01
fm(){ sed -n '2,/^---$/p' "$T" | grep -m1 "^$1:" | sed "s/^$1:[[:space:]]*//; s/^\"//; s/\"$//"; }
repo=$(fm repo); plan=$(fm plan); tier=$(fm tier); pt=$(fm pinga_task)
PN=$(echo "$plan" | sed -E 's/PLAN-([0-9]+).*/\1/'); PID=PLAN-$PN
WT=$DUH/$repo-plan-$PN; PD=$DUH/.ginga/plans/$plan; mkdir -p "$PD/runs"
PAID=opencode/deepseek-v4-pro
G=$DUH/.ginga; source "$G/bin/guard-env.sh"  # PLAN-0033: guard de segredos (padrão ligado; GINGA_GUARD=off desliga)
guard_require || { echo "{\"task\":\"$TN\",\"status\":\"blocked\",\"reason\":\"guard ausente (GINGA_GUARD=off desliga)\",\"attempts\":0}"; exit 6; }
export PYTHONDONTWRITEBYTECODE=1  # 16 de 36 falhas eram scope_drift por __pycache__ (eficiência 29/10)
SPEND=${SPEND_FILE:-$DUH/.ginga/plans/paid-spend.tsv}; touch "$SPEND"
TASK_CAP=0.50; TOTAL_CAP=${TOTAL_CAP:-2.00}
ATT_TIMEOUT=${ATT_TIMEOUT:-1200}   # s por tentativa; --standalone evita o serviço compartilhado (porta 49374) que travou os clientes
# PLAN-0018: done_when em bwrap (sem rede, sem ~) nos repos cuja suíte passa na sandbox; p-inga entra após a TASK-03
SANDBOX_REPOS=${SANDBOX_REPOS:-"ginga manda p-inga"}
case " $SANDBOX_REPOS " in *" $repo "*) export PINGA_EXEC_WRAPPER=$DUH/.ginga/bin/sandbox-done-when.sh;; esac
# ROUTING 2026-10-28 + PLAN-0019: só free; sem nemotron (0/42); Zen pago só com ALLOW_PAID=1 (saldo do dono baixo); strong nunca é automático
FREE="opencode/glm-5.3-flash-free opencode/deepseek-v4.1-flash-free opencode-go/deepseek-v4.1-flash opencode-go/qwen3.8-flash"  # dono 23:4x: Zen free esgotado → Go (assinatura, Extra Usage off)
case $tier in
 free|light|medium) M=${MODELS:-$FREE};;
 strong) [ "${ALLOW_PAID:-0}" = 1 ] && M="$PAID" || { echo "{\"task\":\"$TN\",\"status\":\"blocked\",\"reason\":\"strong exige ALLOW_PAID=1 (dono)\",\"attempts\":0}"; exit 0; };;
 *) echo "{\"task\":\"$TN\",\"status\":\"blocked\",\"model\":null,\"attempts\":0}"; exit 0;;
esac
spent_task(){ awk -v p="$PID" -v t="$TID" '$2==p && $3==t {s+=$5} END{printf "%.6f", s+0}' "$SPEND"; }
est_attempt(){ awk '{if($5>m)m=$5} END{if(m<0.15)m=0.15; printf "%.4f", m}' "$SPEND"; }
spent_total(){ awk '{s+=$5} END{printf "%.6f", s+0}' "$SPEND"; }
sess_cost(){ ( cd "$WT" && opencode session export "$1" 2>/dev/null | jq -r '.info.cost // 0' 2>/dev/null ) || echo 0; }
is_quota(){ # $1=log json?  quota/rate limit de qualquer provider (erro curto, não texto do modelo)
  local f=$1
  if [ "$(wc -c <"$f")" -lt 6000 ] || grep -q '"type": *"error"' "$f"; then
    grep -E -i -q 'usage limit exceeded|free usage limit|rate.?limit (exceeded|reached)|quota (exceeded|reached)|too many requests|insufficient (credits|balance|funds)|credit balance|"status(Code)?": *429|status code:? *429|\b429\b.*(rate|limit|quota)' "$f"
  else return 1; fi
}
BASE=$(sed -n '/^---8<---$/,$p' "$DUH/.ginga/prompts/executor.md" | tail -n +2)
cd "$WT" || exit 1
SNAP=$(mktemp -d); tar cf "$SNAP/keep.tar" --exclude=./.git --exclude=./node_modules --exclude=./runs . 2>/dev/null || { echo "snapshot falhou"; exit 1; }
prev=""; n=0; tries=0; status=blocked; usedm=""; paid_cost=0; paid_tries=0
restore(){ [ "$(pwd)" = "$WT" ] || return 1; find . -mindepth 1 -maxdepth 1 ! -name .git ! -name node_modules ! -name runs -exec rm -rf {} +; tar xf "$SNAP/keep.tar"; }
for m in $M; do for k in 1 2; do
  ispaid=0; case $m in opencode/*-free) ;; opencode/*) ispaid=1;; esac  # Zen sem -free = pago
  [ $ispaid = 1 ] && [ "${ALLOW_PAID:-0}" != 1 ] && { echo "$(date +%F) $TID $m pago pulado (sem ALLOW_PAID=1)" >>"$PD/log.md"; continue; }
  if [ $ispaid = 1 ]; then
    st=$(spent_task); tt=$(spent_total)
    room=$(awk -v a=$TASK_CAP -v s=$st -v b=$TOTAL_CAP -v t=$tt 'BEGIN{r=a-s; q=b-t; if(q<r)r=q; printf "%.4f", r}')
    est=$(est_attempt)
    if [ "$paid_tries" -ge 2 ] || awk -v r=$room -v e=$est 'BEGIN{exit !(r<e)}'; then
      echo "$(date +%F) $TID $m pago NÃO tentado (paid_tries=$paid_tries, estimativa=$est, gasto TASK=$st, total=$tt, folga=$room)" >>"$PD/log.md"; break; fi
    paid_tries=$((paid_tries+1))
  fi
  n=$((n+1)); usedm=$m; LOG=$PD/runs/$TN-$n.log
  guard_export "$PID-$TID"
  if [ $ispaid = 1 ]; then
    env $(guard_opencode_env) timeout -k 30 "$ATT_TIMEOUT" opencode run --standalone --auto --format json -m "$m" --title "$PID $TID" -f "$T" "$BASE $prev" >"$LOG" 2>&1 &
    pid=$!; killed=0; sid=""
    while kill -0 $pid 2>/dev/null; do
      sleep 10
      [ -z "$sid" ] && sid=$(grep -o -m1 '"sessionID":"ses_[A-Za-z0-9]*"' "$LOG" | head -1 | cut -d'"' -f4)
      if [ -n "$sid" ]; then c=$(sess_cost "$sid"); if awk -v c="${c:-0}" -v r=$room 'BEGIN{exit !(c>r)}'; then kill $pid 2>/dev/null; killed=1; break; fi; fi
    done
    wait $pid 2>/dev/null
    [ -z "$sid" ] && sid=$(grep -o -m1 '"sessionID":"ses_[A-Za-z0-9]*"' "$LOG" | head -1 | cut -d'"' -f4)
    if [ -n "$sid" ]; then c=$(sess_cost "$sid"); else c=""; fi
    if [ -z "$c" ]; then c=$room; cnote="custo NÃO medido (assumido=folga $room)"; else cnote="custo medido"; fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$(date +%F)" "$PID" "$TID" "$m" "$c" >>"$SPEND"
    paid_cost=$(awk -v a=$paid_cost -v b=$c 'BEGIN{printf "%.6f", a+b}')
    echo "$(date +%F) $TID $m tentativa paga $paid_tries: US\$$c ($cnote; sessão ${sid:-?}; TASK acumulado US\$$(spent_task); total das TASKs US\$$(spent_total))$([ $killed = 1 ] && echo '; abortada: estourou o teto')" >>"$PD/log.md"
    # texto do modelo p/ os greps (BLOCKED:, learning:)
    jq -r 'select(.type=="text").part.text // empty' "$LOG" >"$SNAP/txt" 2>/dev/null; cat "$SNAP/txt" >>"$LOG"
    [ $killed = 1 ] && { restore; prev="Falha anterior: a tentativa paga foi abortada por estourar o teto de custo; seja mais direto."; continue; }
  else
    case $m in  # pi:<provider/modelo> = free pelo Pi (NVIDIA, dono 2026-10-29); stdin fechado senão o pi -p espera
      pi:*) timeout -k 30 "$ATT_TIMEOUT" pi -p $(guard_pi_args) --model "${m#pi:}" "@$T" "$BASE $prev" </dev/null >"$LOG" 2>&1;;
      *) env $(guard_opencode_env) timeout -k 30 "$ATT_TIMEOUT" opencode run --standalone --auto -m "$m" --title "$PID $TID" -f "$T" "$BASE $prev" </dev/null >"$LOG" 2>&1;;
    esac
  fi
  if is_quota "$LOG"; then
    echo "$(date +%F) $TID $m quota/rate limit ($(grep -E -i -o -m1 'usage limit exceeded|free usage limit|rate.?limit[a-z ]*|quota[a-z ]*|too many requests|insufficient [a-z]*|429' "$LOG" | head -1)); pula para o próximo modelo, não conta como tentativa" >>"$PD/log.md"
    status="blocked(quota)"; restore; break
  fi
  tries=$((tries+1))
  VOUT=$(pinga verify "tasks/$pt/PLAN.md" 2>&1); rc=$?
  echo "$VOUT" >>"$LOG"
  d=$(date +%F)
  if [ $rc -eq 0 ]; then
    echo "$d $TID $m tentativa $tries pass" >>"$PD/log.md"
    L=$(sed 's/\x1b\[[0-9;]*m//g' "$LOG" | grep -i -m1 'learning:' | sed 's/^.*[Ll]earning:[[:space:]]*//')
    case "$L" in ""|nenhum*|\"nenhum*) ;; *) echo "- $TID ($m): $L" >>"$PD/LEARNINGS.md";; esac
    status=pass; break 2
  fi
  status=blocked
  reason=$(echo "$VOUT" | sed "s/\x1b\[[0-9;]*m//g" | grep -o "\"reason_code\":\"[a-z_]*\"" | head -1)
  grep -q 'BLOCKED:' "$LOG" && reason="BLOCKED $(grep -m1 -o 'BLOCKED:.*' "$LOG" | cut -c1-100)"
  echo "$d $TID $m tentativa $tries fail $reason" >>"$PD/log.md"
  prev="Falha anterior: $(echo "$VOUT" | sed 's/\x1b\[[0-9;]*m//g' | tail -30)"
  restore
done; done
rm -rf "$SNAP"
echo "{\"task\":\"$TN\",\"status\":\"$status\",\"model\":\"$usedm\",\"attempts\":$tries,\"paid_cost_usd\":$paid_cost}"

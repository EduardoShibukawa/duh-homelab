#!/usr/bin/env bash
# pi-run.sh — teto rígido de custo para o Pi pago (PLAN-0018, INTENT-0008)
# uso: pi-run.sh <teto_usd> <pi args...>
#   roda `pi --mode json <args...>`, soma message.usage.cost.total do stream
#   (dedupe por responseId, como o manda) e mata o processo quando a soma
#   passa do teto (exit 124).
#   grava a linha em .ginga/plans/paid-spend.tsv: data\tPLAN\tTASK\tmodelo\tcusto
#   PLAN/TASK vêm de PI_PLAN/PI_TASK (padrão "ops"); PI_SPEND sobrescreve o tsv.
set -u
DUH=/home/shibuka/Projetos/duh-homelab
SPEND="${PI_SPEND:-$DUH/.ginga/plans/paid-spend.tsv}"; touch "$SPEND"

CAP="${1:-}"; shift || true
case "$CAP" in ''|*[!0-9.]*) echo "pi-run: teto inválido: '$CAP'" >&2; exit 2;; esac

PLAN="${PI_PLAN:-ops}"; TASK="${PI_TASK:-ops}"
MODEL=""; prev=""
for a in "$@"; do
  case "$prev" in --model) MODEL="$a";; esac
  case "$a" in --model=*) MODEL="${a#--model=}";; esac
  prev="$a"
done

tmp=$(mktemp -d); fifo="$tmp/out"; mkfifo "$fifo"
pi --no-session --mode json "$@" >"$fifo" 2>"$tmp/err" &
pid=$!
sum=0; killed=0; declare -A seen
while IFS= read -r line; do
  [ -z "$line" ] && continue
  # custo do message_end/turn_end (dedupe por responseId, como parsePiRunnerOutput)
  row=$(printf '%s' "$line" | jq -r 'select(.type=="message_end" or .type=="turn_end") | select(.message.role != "user") | [.message.responseId // .message.response_id // .message.id // .message.messageId // .message.timestamp // "", (.message.usage.cost.total // 0)] | @tsv' 2>/dev/null)
  [ -z "$row" ] && continue
  key=$(printf '%s' "$row" | cut -f1); val=$(printf '%s' "$row" | cut -f2)
  if [ -n "$key" ]; then [ -n "${seen[$key]:-}" ] && continue; seen[$key]=1; fi
  sum=$(awk -v a="$sum" -v b="${val:-0}" 'BEGIN{printf "%.8f", a+b}')
  if awk -v s="$sum" -v c="$CAP" 'BEGIN{exit !(s>c)}'; then
    kill "$pid" 2>/dev/null; killed=1; break
  fi
done <"$fifo"
wait "$pid" 2>/dev/null; rc=$?
rm -rf "$tmp"

printf '%s\t%s\t%s\t%s\t%s\n' "$(date +%F)" "$PLAN" "$TASK" "$MODEL" "$sum" >>"$SPEND"
if [ "$killed" = 1 ]; then
  echo "pi-run: teto US\$$CAP atingido (custo US\$$sum); processo abortado" >&2
  exit 124
fi
echo "pi-run: custo US\$$sum (modelo $MODEL)"
exit "$rc"

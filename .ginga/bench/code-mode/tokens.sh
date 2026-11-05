#!/usr/bin/env bash
# tokens.sh <sessionID> — imprime JSON {in,out,cache,cost,turns,reasoning} de uma sessão opencode.
#
# Requer: opencode (mise) e jq.
# A sessão precisa ter sido criada com `opencode run --standalone`; o export usa
# `--standalone` também, senão o serviço de fundo devolve vazio.
#
# Uso:
#   SESSION_ID=$(head -1 run.jsonl | jq -r .sessionID)
#   tokens.sh "$SESSION_ID"
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "uso: tokens.sh <sessionID>" >&2
  exit 2
fi

SESSION_ID="$1"

# Exporta para um arquivo temporário (o JSON pode ser grande).
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if ! opencode session export --standalone "$SESSION_ID" > "$TMP" 2>/dev/null; then
  echo '{"error":"session export falhou"}' >&2
  exit 1
fi

if [ ! -s "$TMP" ]; then
  echo '{"error":"session export vazio (a sessão foi criada com --standalone?)"}' >&2
  exit 1
fi

jq -c '{
  in: .info.tokens.input,
  out: .info.tokens.output,
  cache: .info.tokens.cache.read,
  cost: .info.cost,
  turns: ([.messages[] | select(.type == "assistant")] | length),
  reasoning: .info.tokens.reasoning
}' "$TMP"

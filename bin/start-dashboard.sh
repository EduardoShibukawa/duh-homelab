#!/usr/bin/env bash
set -euo pipefail

PID_FILE="/tmp/pinga-dashboard.pid"

ACTIVE_PID=$(pgrep -f "bun.*web/server\.ts" 2>/dev/null | head -n 1 || true)
if [ -n "$ACTIVE_PID" ]; then
    echo "$ACTIVE_PID" > "$PID_FILE"
    echo "P-Ingá Dashboard já está rodando (PID: $ACTIVE_PID)."
    echo "Acesse em: http://localhost:4242"
    exit 0
fi

BUN="${BUN:-/home/shibuka/.local/share/mise/installs/bun/latest/bin/bun}"
if [ ! -x "$BUN" ] && command -v bun >/dev/null 2>&1; then
    BUN=$(command -v bun)
fi

cd /home/shibuka/Projetos/duh-homelab/p-inga
nohup setsid "$BUN" run web/server.ts < /dev/null > /tmp/pinga-dashboard.log 2>&1 &
PID=$!
sleep 1
if [ -f "$PID_FILE" ]; then
    REAL_PID=$(pgrep -f "bun.*web/server\.ts" 2>/dev/null | head -n 1 || echo "$PID")
    echo "$REAL_PID" > "$PID_FILE"
    PID="$REAL_PID"
fi
echo "P-Ingá Dashboard iniciado com sucesso (PID: $PID)."
echo "Acesse em: http://localhost:4242"

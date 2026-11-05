#!/usr/bin/env bash
PID_FILE="/tmp/pinga-dashboard.pid"
KILLED=0

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null || true
        echo "P-Ingá Dashboard (PID: $PID) finalizado."
        KILLED=1
    fi
    rm -f "$PID_FILE"
fi

PIDS=$(pgrep -f "bun.*web/server\.ts" 2>/dev/null || true)
if [ -n "$PIDS" ]; then
    for p in $PIDS; do
        kill "$p" 2>/dev/null || true
        echo "Processo residual finalizado (PID: $p)."
        KILLED=1
    done
fi

if [ "$KILLED" -eq 0 ]; then
    echo "P-Ingá Dashboard não estava rodando."
fi

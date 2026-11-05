#!/usr/bin/env bash
# ==============================================================================
# HOMELAB WORKSPACE — Inicialização do Layout de Produção no TUIOS
# Configura o cockpit em 4 painéis com Centro de Controle Interativo
# ==============================================================================
set -euo pipefail

SESSION="homelab"
DUH_ROOT="/home/shibuka/Projetos/duh-homelab"
CTL_SCRIPT="$DUH_ROOT/bin/tuios-control-center.sh"

echo "Inicializando sessão de produção TUIOS: $SESSION"

# Inicia nova sessão desacoplada se não existir
if ! tuios has-session -s "$SESSION" 2>/dev/null; then
    tuios new-session -s "$SESSION" -d -n "code-editor"
fi

# 1. Configura Pane 1 (Editor/Código)
PANE_EDITOR=$(tuios list-windows -s "$SESSION" --json 2>/dev/null | jq -r '.[0].id // empty')
if [ -n "$PANE_EDITOR" ]; then
    tuios rename-window -s "$SESSION" -w "$PANE_EDITOR" "code-editor" 2>/dev/null || true
    tuios send-text -s "$SESSION" -w "$PANE_EDITOR" "cd $DUH_ROOT/p-inga && clear && echo '=== HOMELAB WORKSPACE PRONTO ===' && echo 'Dica: Pressione [Alt+M] a qualquer momento para abrir o Centro de Controle Flutuante'\n" 2>/dev/null || true
fi

# 2. Divide verticalmente para criar o Pane 2 (Logs do Runner P-Ingá)
PANE_RUNNER=$(tuios split-window vertical -s "$SESSION" -w "${PANE_EDITOR:-1}" --name "pinga-runner" --json 2>/dev/null | jq -r '.window_id // empty' || echo "")
if [ -n "$PANE_RUNNER" ]; then
    tuios send-text -s "$SESSION" -w "$PANE_RUNNER" "cd $DUH_ROOT/p-inga && echo '=== P-INGÁ VERIFIER READY ===' && clear\n" 2>/dev/null || true
    tuios set-agent-state idle -s "$SESSION" -w "$PANE_RUNNER" --harness p-inga -m "Pronto para despacho" 2>/dev/null || true
fi

# 3. Divide horizontalmente no Pane 2 para criar o Pane 3 (AST Viewer Gira-G)
if [ -n "$PANE_RUNNER" ]; then
    PANE_GIRA=$(tuios split-window horizontal -s "$SESSION" -w "$PANE_RUNNER" --name "gira-ast" --json 2>/dev/null | jq -r '.window_id // empty' || echo "")
    if [ -n "$PANE_GIRA" ]; then
        tuios send-text -s "$SESSION" -w "$PANE_GIRA" "cd $DUH_ROOT && gira locate '' 2>/dev/null | head -n 30 || true\n" 2>/dev/null || true
        tuios set-agent-state idle -s "$SESSION" -w "$PANE_GIRA" --harness gira -m "Índice AST carregado" 2>/dev/null || true
    fi
fi

# 4. Divide horizontalmente no Pane 1 para criar o Pane 4 (Centro de Controle Interativo)
if [ -n "$PANE_EDITOR" ]; then
    PANE_CTL=$(tuios split-window horizontal -s "$SESSION" -w "$PANE_EDITOR" --name "control-center" --json 2>/dev/null | jq -r '.window_id // empty' || echo "")
    if [ -n "$PANE_CTL" ]; then
        tuios send-text -s "$SESSION" -w "$PANE_CTL" "$CTL_SCRIPT\n" 2>/dev/null || true
        tuios set-agent-state idle -s "$SESSION" -w "$PANE_CTL" --harness control-center -m "Centro de Controle Ativo" 2>/dev/null || true
    fi
fi

# Emite notificação HUD OSC 7501
if command -v tuios >/dev/null 2>&1; then
    tuios status working --app homelab --msg "Workspace Homelab Ativo | Alt+M para Centro de Controle Flutuante" 2>/dev/null || true
fi

echo "Workspace Homelab configurado com sucesso no TUIOS (4 painéis ativos)."

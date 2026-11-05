#!/usr/bin/env bash
# ==============================================================================
# TUIOS Fleet Launcher — P-Ingá & Multi-Agent Homelab Orchestrator
# Sets up a 4-quadrant operational workspace in TUIOS:
#   [ Pane 1 (Top-Left)  ]: Maestro Hermes (g-inga profile)
#   [ Pane 2 (Bottom-Left) ]: P-Ingá Scoreboard & Ledger Watch
#   [ Pane 3 (Top-Right) ]: Worker Agent (Claude Code / OpenCode / Pi)
#   [ Pane 4 (Bottom-Right)]: Gira-G Architecture & Context Map
# ==============================================================================
set -euo pipefail

HOMELAB_DIR="/home/shibuka/Projetos/duh-homelab"
PINGA_BIN="${HOMELAB_DIR}/p-inga/.pinga/pinga-stable"

echo "=== TUIOS Multi-Agent Fleet Setup ==="

# Check tuios availability
if ! command -v tuios &>/dev/null; then
    echo "Erro: tuios não encontrado no PATH."
    exit 1
fi

echo "Verificando integrações do TUIOS..."
tuios integration status | grep -E "(claude-code|codex|opencode|pi|hermes|antigravity)" || true

echo ""
echo "Comandos para operar a frota no TUIOS:"
echo "1. Iniciar TUIOS:               tuios"
echo "2. Dividir painéis (split):     tuios split-window vertical / horizontal"
echo "3. Status dos operários:        ${PINGA_BIN} maestro scoreboard"
echo "4. Recomendar orquestrador:     ${PINGA_BIN} maestro recommend <PLAN.md>"
echo "5. Consultar impacto Gira-G:    gira impact <target_id> --budget 800"
echo "====================================="

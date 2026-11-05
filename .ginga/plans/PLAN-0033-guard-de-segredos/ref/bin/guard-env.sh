#!/usr/bin/env bash
# guard-env.sh — fonte única de como as lanes ligam o guard de segredos (PLAN-0033). Uso: source guard-env.sh
# Padrão LIGADO. Só `GINGA_GUARD=off` (decisão do dono, em lane.env) desliga. Guard ausente com guard ligado = a lane NÃO inicia.
GUARD_DIR=${GUARD_DIR:-/home/shibuka/Projetos/duh-homelab/ginga}   # checkout da main do ginga: nada é copiado para ~
guard_on(){ [ "${GINGA_GUARD:-enforce}" != off ]; }
guard_require(){ guard_on || return 0; [ -f "$GUARD_DIR/contrib/guard/pi.ts" ] && [ -f "$GUARD_DIR/contrib/guard/opencode.ts" ] && [ -f "$GUARD_DIR/src/guard/cli.ts" ]; }
guard_export(){ guard_on || return 0   # $1 = nome da sessão (marca "sessão de lane" para os 3 runtimes)
  export GINGA_GUARD_LANE="${1:?nome da sessão}" GINGA_GUARD="${GINGA_GUARD:-enforce}" GINGA_GUARD_LOG="${GINGA_GUARD_LOG:-${G:-.}/handoffs/guard.events.jsonl}"; }
guard_pi_args(){ guard_on && printf '%s\n' -e "$GUARD_DIR/contrib/guard/pi.ts"; return 0; }
guard_opencode_env(){ guard_on && printf '%s\n' "OPENCODE_CONFIG_DIR=$GUARD_DIR/contrib/guard/opencode-config"; return 0; }

---
type: task
mode: padrao
goal: "O ginga tem equivalente para cada subcomando do bin/homelab, sem caminhos absolutos"
title: ginga cobre os subcomandos do homelab
plan: PLAN-0015-init-e-homelab
repo: ginga
pinga_task: T130
depends_on: [TASK-01-ginga-init]
tier: medium
touch: [src/workspace.ts, src/verbs/ops.ts, src/verbs/registry.ts, tests/homelab_parity.test.ts]
done_when: "bun test tests/homelab_parity.test.ts"
tests_frozen: [tests/homelab_parity.test.ts]
---
## Fazer
- `src/workspace.ts`: raiz por `GINGA_WORKSPACE` ou `.ginga/` mais próximo; binários pelo PATH.
- `status` (já existe), `web start|stop|open|status` → `serve`, `tui` (layout tuios), `hermes`, `hud`, `verify` → `pinga verify`, `maestro` → `pinga maestro`, `gira` → passthrough, `ctl` → menu (gum/fzf se houver).
- Teste: a lista de subcomandos do `bin/homelab` (`case` do dispatcher) tem verbo correspondente.
## Não fazer
- Não alterar o `bin/homelab` (TASK-04).
## Contexto
- `duh-homelab/bin/homelab` (l. 8-10 caminhos fixos; dispatcher l. 211-246).

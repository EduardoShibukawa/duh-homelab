---
type: task
mode: mvp
goal: "Com [supervisor] mode = tick, o supervisor roda ginga tick --loop por lane em vez de um operador LLM"
title: Supervisor roda o tick
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: ginga
depends_on: [TASK-04-tick-avanca-fases]
tier: free
touch: [src/supervisor.ts, tests/supervisor_tick_mode.test.ts]
done_when: "bun test tests/supervisor_tick_mode.test.ts"
tests_frozen: [tests/supervisor_tick_mode.test.ts]
pinga_task: T136
---
## Fazer
- `mode = "tick"` (padrão depois do e2e): o filho é `ginga tick --loop --repo <repo>`; `mode = "operador"` mantém o comportamento de hoje.
## Interface
- `childArgv(cfg: { mode: "tick" | "operador"; repo: string }): string[]` exportada de `src/supervisor.ts`. Teste: os dois argv; com `tick`, nenhum argv contém `opencode`, `claude` ou `pi`.
## Não fazer
- Não apagar o caminho do operador (corte depois do e2e).
## Contexto
- PLAN-0022 TASK-03 e PLAN-0023 TASK-06 (fechadas por esta).

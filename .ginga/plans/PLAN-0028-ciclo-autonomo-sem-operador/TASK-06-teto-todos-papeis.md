---
type: task
mode: mvp
goal: "Antes de cada chamada paga de qualquer papel, o manda soma o gasto real (opencode.db + claude -p) e nega a chamada que passaria do teto"
title: Teto de custo de todos os papéis
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: []
tier: free
touch: [src/cost_cap.ts, tests/cost_cap.test.ts, tests/fixtures/opencode-cost.sql]
done_when: "bun test tests/cost_cap.test.ts"
tests_frozen: [tests/cost_cap.test.ts, tests/fixtures/opencode-cost.sql]
pinga_task: T155
---
## Fazer
- `spentUsd`: `sum(cost)` de `session_v2` desde `since` (db aberto read-only; usa `ginga cost --json` se estiver no PATH) + custos do `claude -p` (`total_cost_usd` do stream-json).
- `capCheck`: nega se `spent + estimate > cap`; teto em `[budget] round_usd` (substitui o `TOTAL_CAP` que só via o executor).
## Interface
- `capCheck`, `spentUsd` (PLAN.md). Teste: fixture SQL com 3 sessões (0,10 + 0,25 + 0) e claude 0,40 → 0,75; cap 1,00 com estimativa 0,30 → nega.
## Não fazer
- Não ler o `paid-spend.tsv`.
## Contexto
- Decisão do dono ("Teto de custo medido pelo opencode.db"); PLAN-0014 TASK-07.

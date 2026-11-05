---
type: task
mode: mvp
goal: "envelope v1: cost_usd valida como campo numérico do kind attempt (aceita número, reprova string)"
title: cost_usd numérico no validate de eventos
plan: PLAN-0020-cost-usd-validation
repo: ginga
depends_on: []
tier: free
pinga_task: T24
touch: [src/events/validate.ts, tests/events_validate_cost.test.ts]
done_when: "bun test tests/events_validate_cost.test.ts"
tests_frozen: [tests/events_validate_cost.test.ts]
---
## Fazer
- Adicionar `cost_usd` ao conjunto `numbers` do kind `attempt` em `src/events/validate.ts` (docs/events-v1.md:22 o define; achado do judge codex7 do PLAN-0004).
- `bun test tests/events_validate_cost.test.ts` (testes já committados como RED, commit `0be20f4`).
## Não fazer
- Tocar em outros kinds, `tests/events_fix.test.ts` ou outros testes congelados.
## Contexto
- plan/0020 em `ginga-plan-0020`, com `tasks/T24/PLAN.md` e RED selado (`pinga prove-red` seq de pass).

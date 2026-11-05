---
type: task
mode: padrao
goal: "chamadas pagas ao Jev passam pelo budget do manda e todas emitem jev.call; jev.shadow registra a concordância"
title: Orçamento e eventos do Jev
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: [TASK-01-config-jev]
tier: free
touch: [src/jev/telemetry.ts, src/budget.ts, src/events.ts, tests/jev/telemetry.test.ts]
done_when: "bun test tests/jev/telemetry.test.ts tests/budget.test.ts tests/events.test.ts"
tests_frozen: [tests/jev/telemetry.test.ts]
---
## Fazer
- `jevCost(provider, model, tokensIn)`: `opencode` com `-free` e `local` = 0; os outros = `tokensIn × 0.042 / 1e6` (preço do Zen; OpenRouter/Vercel marcados `estimated`).
- `jevBudgetOk(budget, provider, model)`: pago só com `ALLOW_PAID` e dentro do teto (`budget.ts`); free e local sempre `true`.
- Eventos `jev.call` e `jev.shadow` no formato dos eventos v1 (`events.ts`); sem prompt nem resposta, só metadados.
## Interface
- Teste: custo por provider, `jevBudgetOk` com e sem `ALLOW_PAID`, estouro do teto, forma dos dois eventos e ausência de texto do input.
## Não fazer
- Não mudar o schema existente de `cost`; reaproveitar o evento `cost` com `scope: "call"` para o pago.
## Contexto
- SPEC-0003 (catálogo de sinais); ROUTING (teto por rodada somando tudo).

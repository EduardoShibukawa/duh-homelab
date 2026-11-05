---
type: task
mode: mvp
goal: "Evento receipt usa receipt.check quando presente (receipt de PLAN emite check: plan)"
title: Fix do judge — Evento receipt usa receipt.check quando presente (receipt de
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T69
depends_on: [TASK-07-receipt-events]
tier: free
touch: [src/events.ts, tests/receipt_events_fix.test.ts]
done_when: "bun test tests/receipt_events_fix.test.ts tests/receipt_events.test.ts tests/plan_verify.test.ts"
tests_frozen: [tests/receipt_events_fix.test.ts]
---
## Fazer
- `src/events.ts:30`: `data.check = receipt.check ?? receiptKind(receipt).replace('_','-')`.
- Testes RED já escritos pelo Planner em `tests/receipt_events_fix.test.ts` (frozen).
## Não fazer
- Não alterar `tests/receipt_events.test.ts` (frozen).
## Contexto
- Judge (Codex + Gemini flash) do PLAN-0005: o evento perdia check: plan.

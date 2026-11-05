---
type: task
mode: mvp
goal: "Todo receipt selado no ledger também vira um evento receipt v1 em $GINGA_EVENTS, sem efeito quando a variável não existe"
title: receipt em $GINGA_EVENTS
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T68
depends_on: [TASK-01-schema-task]
tier: free
touch: [src/events.ts, src/ledger.ts, tests/receipt_events.test.ts]
done_when: "bun test tests/receipt_events.test.ts tests/ledger.test.ts"
tests_frozen: [tests/receipt_events.test.ts]
---
## Fazer
- Após `append` no ledger: `{v:1, source:"pinga", kind:"receipt", task, repo, data:{ledger_n, hash, status, reason_code, check}}`.
- `O_APPEND`, uma linha por `write()`; falha ao emitir nunca falha o verify.
## Não fazer
- Não importar nada do ginga (implementação própria do 07).
## Contexto
- `src/ledger.ts` (`openLedger`, `append`), `src/receipt.ts` (`Receipt`, `receiptKind`).

---
type: task
mode: padrao
goal: "Um resolvedor único de id de task cobre tasks/T<N>/PLAN.md e PLAN-*/TASK-*.md em verify e prove-red"
title: task_ref.ts em verify e prove-red
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T63
depends_on: [TASK-01-schema-task]
tier: medium
touch: [src/task_ref.ts, src/verify.ts, src/prove.ts, tests/task_ref.test.ts]
done_when: "bun test tests/task_ref.test.ts tests/verify.test.ts tests/prove.test.ts"
tests_frozen: [tests/task_ref.test.ts]
---
## Fazer
- `taskRef(path)`: `tasks/T61/PLAN.md` → `T61`; `.../PLAN-0005-x/TASK-02-y.md` → `PLAN-0005/TASK-02`.
- Trocar `basename(dirname(...))` em `verify.ts:97` e `prove.ts:373`.
## Não fazer
- Não tocar nos outros comandos (TASK-03). Receipts do legado continuam com `task: "T<N>"`.
## Contexto
- `src/verify.ts` (`verifyPlan`), `src/prove.ts` (`provePlan`), `src/ledger.ts` (`scopedReceipts`).

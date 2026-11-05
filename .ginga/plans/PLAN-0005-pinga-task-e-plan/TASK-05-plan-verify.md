---
type: task
mode: padrao
goal: "pinga verify em um PLAN.md (type: plan) exige pass em todas as TASKs da pasta e então roda o done_when do PLAN"
title: Verificação de integração do PLAN
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T66
depends_on: [TASK-04-root-flag]
tier: medium
touch: [src/plan_verify.ts, src/cli.ts, src/receipt.ts, tests/plan_verify.test.ts]
done_when: "bun test tests/plan_verify.test.ts"
tests_frozen: [tests/plan_verify.test.ts]
---
## Fazer
- Detectar `type: plan` no frontmatter; sem limite de 25 linhas; `done_when` obrigatório.
- Falta receipt `pass` de alguma `TASK-*.md` → receipt `blocked`, `reason_code: tasks_open`, lista no summary.
- Todas `pass` → roda o `done_when` e sela receipt com `task: PLAN-NNNN` e `check: plan`.
- `src/receipt.ts`: `tasks_open` em `EXTRA_REASON_CODES` e o campo opcional `check` no `Receipt`, aceitos pelo validador.
- `kind: investigation` segue o mesmo caminho (teste com um PLAN de hipóteses).
## Não fazer
- Não rodar o Judge aqui.
## Contexto
- `verify.ts` (`verifyPlan`, `Receipt`), `ledger.ts` (`scopedReceipts`), `task_ref.ts` (TASK-02).

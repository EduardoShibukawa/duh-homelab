---
type: task
mode: padrao
goal: "manda plan <INTENT|SPEC> roda o papel Planner e grava PLAN.md + TASK-*.md válidos no bundle"
title: manda plan (papel Planner)
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: [TASK-07-judge-cego]
tier: medium
pinga_task: T14
touch: [src/plan.ts, src/cli.ts, tests/plan_cmd.test.ts]
done_when: "bun test tests/plan_cmd.test.ts"
tests_frozen: [tests/plan_cmd.test.ts]
---
## Fazer
- Runtime do papel `planner` pelo routing; prompt com o INTENT/SPEC e o formato do doc 04.
- Validação própria mínima (campos obrigatórios, DAG, 25 linhas por TASK); se `ginga` estiver no PATH, roda também `ginga lint`.
- Saída inválida → 1 retry com os erros; depois, exit 1 sem gravar.
## Não fazer
- Não aprovar o PLAN (`status: draft` sempre).
## Contexto
- `pi-harness/.pi/extensions/sdlc.ts` (`/spec`, `/task`), `src/intent/plan_linter.ts`.

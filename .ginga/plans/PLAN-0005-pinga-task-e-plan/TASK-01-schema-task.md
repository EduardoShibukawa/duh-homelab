---
type: task
mode: mvp
goal: "parsePlan aceita e valida os campos opcionais da TASK nova e recusa type: plan com erro claro"
title: Campos opcionais da TASK no parsePlan
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T62
depends_on: []
tier: free
touch: [src/plan.ts, tests/task_schema.test.ts]
done_when: "bun test tests/task_schema.test.ts tests/repo.test.ts"
tests_frozen: [tests/task_schema.test.ts]
---
## Fazer
- Opcionais: `type` (`task`), `title`, `plan`, `repo` (string), `depends_on` (array), `tier` (`free|medium|strong`). Tipo errado vira erro.
- `type: plan` → erro `use pinga verify em modo PLAN` (o parse de PLAN fica na TASK-05).
- Obrigatórios e `MODES` continuam iguais.
## Não fazer
- Não mexer em `MAX_LINES` (25) nem nos modos.
## Contexto
- `src/plan.ts` (`parsePlan`, `Plan`, `MODES`).

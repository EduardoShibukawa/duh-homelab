---
type: task
mode: padrao
goal: "supervisor não limita a supervisão a dez iterações e não encerra com pendência sem falha que acione reinício"
title: supervisor sem cap de iterações
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-03-serve-supervisor]
tier: free
pinga_task: T35
touch: [src/supervisor.ts, tests/supervisor_iterations.test.ts, tasks/T35/PLAN.md]
done_when: "bun test tests/supervisor_iterations.test.ts"
tests_frozen: [tests/supervisor_iterations.test.ts]
---
## Fazer
- Remover o teto de dez iterações: loop continua enquanto houver pendência; encerra apenas em no_pending, stop ou maxRestarts excedido.
## Não fazer
- Não alterar tests_frozen.

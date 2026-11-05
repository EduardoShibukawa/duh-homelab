---
type: task
mode: padrao
goal: "manda replan monta contexto real e usa o Planner configurado com fallback"
title: Correcao do contexto do manda replan
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-05-replan-por-codigo]
tier: medium
touch: [src/cli.ts, tests/replan_cli.test.ts, tasks/T161/PLAN.md]
done_when: "bun test tests/replan_cli.test.ts"
tests_frozen: [tests/replan_cli.test.ts]
pinga_task: T161
---
## Fazer
- Ler receipts, judge e diff real.
- Usar [roles] planner com fallback opencode.

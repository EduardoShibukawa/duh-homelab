---
type: task
mode: padrao
goal: "goal_reached só conta gate.result com code === 0 numérico; a string '0' não conta"
title: follow-up do judge — goal_reached exige code numérico 0
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-07-watch-goal-reached-strict]
tier: free
pinga_task: T107
touch: [src/watch/evaluate.ts, tests/watch_goal_code_numeric.test.ts, tasks/T107/PLAN.md]
done_when: "bun test tests/watch_goal_code_numeric.test.ts tests/watch_goal_reached_strict.test.ts"
tests_frozen: [tests/watch_goal_code_numeric.test.ts]
---
## Fazer
- `src/watch/evaluate.ts` (goal_reached): `allPass` usa `typeof g.data.code === "number" && g.data.code === 0`, sem `num()`.
## Não fazer
- Não alterar tests_frozen.

---
type: task
mode: padrao
goal: "ginga watch: goal_reached só dispara com todos os gate.result code 0, todos os alvo.check ok=true e nenhuma pendência (lane.round sem end); validateEvent valida data.actions como lista de strings no kind alert"
title: watch goal_reached estrito + validate actions
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-02-watch-rules]
tier: free
pinga_task: T34
touch: [src/events/validate.ts, src/watch/evaluate.ts, tests/watch_goal_reached_strict.test.ts, tasks/T34/PLAN.md]
done_when: "bun test tests/watch_goal_reached_strict.test.ts"
tests_frozen: [tests/watch_goal_reached_strict.test.ts]
---
## Fazer
- goal_reached: exigir gates.length>0 e todos code===0; alvos.length>0 e todos ok===true; e ausência de pendência (nenhum lane.round start sem end correspondente).
- validateEvent: kind alert valida data.actions como array de strings (quando presente).
## Não fazer
- Não alterar tests_frozen.

---
type: task
mode: padrao
goal: "main_moved_outside_gate sem SHA emite warn 'sem SHA de main no heartbeat' (1 por lane), sem depender de progress"
title: follow-up do judge — warn sem SHA independente de progress
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-13-watch-followup9]
tier: free
pinga_task: T108
touch: [src/watch/evaluate.ts, tests/watch_main_moved_nosha.test.ts, tasks/T108/PLAN.md]
done_when: "bun test tests/watch_main_moved_nosha.test.ts tests/watch_followup9.test.ts tests/watch_followup8.test.ts tests/serve_watch_tick.test.ts"
tests_frozen: [tests/watch_main_moved_nosha.test.ts]
---
## Fazer
- `src/watch/evaluate.ts` (main_moved_outside_gate): quando nenhum heartbeat traz SHA, emitir o warn `sem SHA de main no heartbeat` por entidade-lane (uma por lane; o `dedupe_key` já é `rule:entity`), qualquer que seja o `progress` e mesmo com 1 heartbeat. Ignorar entidades `executor/*` (não são lane e não carregam SHA); isso preserva `serve_watch_tick` (fixture no_progress de executor = 1 alerta).
## Não fazer
- Não alterar tests_frozen (`watch_followup9`, `serve_watch_tick`, os `watch_followup8`).

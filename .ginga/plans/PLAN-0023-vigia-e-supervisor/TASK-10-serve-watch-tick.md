---
type: task
mode: padrao
goal: "ginga serve executa ginga watch a cada tick; RED: 2 ticks com fixture no_progress geram 1 alerta"
title: serve executa watch a cada tick
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-02-watch-rules]
tier: free
pinga_task: T37
touch: [src/serve.ts, src/watch/index.ts, tests/serve_watch_tick.test.ts, tasks/T37/PLAN.md]
done_when: "bun test tests/serve_watch_tick.test.ts"
tests_frozen: [tests/serve_watch_tick.test.ts]
---
## Fazer
- Em makeTickRunner, apos runTick, invocar runWatch/watchCmd para o root.
- Idempotencia: nao reemitir alerta com dedupe_key ja presente nos eventos (state.db ou $GINGA_EVENTS).
- Resultado: 2 ticks com fixture no_progress geram exatamente 1 alerta.
## Não fazer
- Não alterar tests_frozen.

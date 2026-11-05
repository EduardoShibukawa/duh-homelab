---
type: task
mode: padrao
goal: "todo envio do router passa pela fila durável (enqueue -> drain), sem caminho direto"
title: router consome fila durável
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-02-watch-rules]
tier: medium
pinga_task: T33
touch: [src/notify/router.ts, src/notify/queue.ts, tests/notify_router_queue.test.ts, tasks/T33/PLAN.md]
done_when: "bun test tests/notify_router_queue.test.ts"
tests_frozen: [tests/notify_queue.test.ts, tests/event_router.test.ts, tests/notify_port.test.ts, tests/notify_thread_id.test.ts]
---

## Fazer
- routeEvents enfileira notificações e drena via queue, sem send direto.
- Item com canal falhando permanece na fila e sai no próximo drain.
## Não fazer
- Não alterar tests_frozen.

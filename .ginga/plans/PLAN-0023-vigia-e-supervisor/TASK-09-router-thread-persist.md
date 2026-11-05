---
type: task
mode: padrao
goal: "router persiste thread_id em toda entrega bem-sucedida, inclusive retries recuperados pelo drain da fila durável"
title: persistência de thread_id em retries
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-06-router-queue]
tier: free
pinga_task: T36
touch: [src/notify/router.ts, src/notify/queue.ts, tests/notify_router_thread_persist.test.ts, tasks/T36/PLAN.md]
done_when: "bun test tests/notify_router_thread_persist.test.ts"
tests_frozen: [tests/notify_router_thread_persist.test.ts]
---
## Fazer
- Envolva os drains (pendente e por evento) para gravar thread_id retornado em plan_thread para todos os plans do grupo, inclusive retries recuperados.
## Não fazer
- Não alterar tests_frozen.

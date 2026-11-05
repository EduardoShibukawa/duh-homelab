---
type: task
mode: padrao
goal: "O fallback Discord de src/notify/port.ts extrai o ID da mensagem da resposta e devolve thread_id mesmo sem thread de entrada; o router persiste a thread por PLAN"
title: follow-up judge: thread_id do fallback Discord (POST → id da resposta)
plan: PLAN-0010-tick-serve-notifier
repo: ginga
depends_on: [TASK-04-notifier-port]
tier: free
pinga_task: T26
touch: [src/notify/port.ts, tests/notify_thread_id.test.ts, tasks/T26/PLAN.md]
done_when: "bun test tests/notify_thread_id.test.ts"
tests_frozen: [tests/notify_thread_id.test.ts]
---
## Fazer
- No POST discord OK sem `thread` de entrada: extrair `id` do JSON da resposta e devolver `thread_id` (o router grava em `plan_thread` e reusa nos envios seguintes).
- Com `thread` de entrada: comportamento atual mantido (devolve a thread usada).
- JSON indisponível ou sem `id`: devolve como hoje (sem thread_id), sem falhar o envio.
## Não fazer
- Não tocar `tests/notify_port.test.ts` / `tests/event_router.test.ts` (frozen) nem a cadeia Hermes/stdout.
## Contexto
- Achado do judge da 20:55 (REPORT-2026-10-28): `src/notify/port.ts:56-64` só devolve thread_id se já havia thread; o fallback não inicia nem persiste a thread.

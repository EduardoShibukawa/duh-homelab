---
type: task
mode: padrao
goal: "O event router transforma eventos ingeridos em notificações conforme as regras de 05 §6, com uma thread por PLAN"
title: Event router
plan: PLAN-0010-tick-serve-notifier
repo: ginga
depends_on: [TASK-03-serve-timers, TASK-04-notifier-port]
tier: medium
pinga_task: T23
touch: [src/notify/router.ts, src/notify/rules.ts, src/serve.ts, tests/event_router.test.ts]
done_when: "bun test tests/event_router.test.ts"
tests_frozen: [tests/event_router.test.ts]
---
## Fazer
- Padrão: `blocker` e TASK `blocked` → discord (thread + menção) e telegram; aprovação → discord; `budget` cap → discord + telegram; retry interno → nada.
- Regras sobrescritas por `[notify.rules]` do `project.toml`. Thread por PLAN salva em `plan_thread`.
- Cada evento é notificado no máximo uma vez (marca no `state.db`).
## Não fazer
- Eventos são fatos: o router não chama verbos.
## Contexto
- Doc 05 §6 (tabela de regras), doc 07 ("Regras").

---
type: task
mode: mvp
goal: "Um blocker vai para Discord e Telegram, a resposta na thread vira answer e o próximo tick volta a despachar o PLAN"
title: e2e do blocker pela thread
plan: PLAN-0011-verbos-api-auth
repo: ginga
depends_on: [TASK-04-auth, TASK-05-hermes-inbound]
tier: medium
pinga_task: T126
touch: [tests/e2e/blocker_flow.test.ts, tests/stubs/, contrib/hermes-plugin/__init__.py]
done_when: "bun test tests/e2e/blocker_flow.test.ts"
tests_frozen: [tests/e2e/blocker_flow.test.ts]
---
## Fazer
- Evento `blocker` no `$GINGA_EVENTS` → `serve` → stub de `hermes send` recebe 2 envios (`discord:...` e `telegram:...`).
- Payload simulado de resposta na thread → plugin → `ginga answer` → `tick` despacha a TASK (stub de `manda`).
## Não fazer
- Sem rede real.
## Contexto
- `src/notify/router.ts` (PLAN-0010), `contrib/hermes-plugin/` (TASK-05).
- O router persiste `plan_thread.target` como o target completo do envio (ex.: `discord:chan-1`); o e2e grava a thread nesse formato e a resposta na thread precisa resolver o blocker daí — por isso o touch inclui `contrib/hermes-plugin/__init__.py` (alinhamento `resolve_blocker` ↔ router).

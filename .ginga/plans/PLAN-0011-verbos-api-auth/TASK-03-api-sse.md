---
type: task
mode: padrao
goal: "ginga serve expõe POST /v1/verbs/:nome e GET /v1/events (SSE) gerados do registro, com a mesma saída da CLI"
title: API HTTP + SSE
plan: PLAN-0011-verbos-api-auth
repo: ginga
depends_on: [TASK-02-cli-verbos]
tier: medium
touch: [src/api/server.ts, src/api/sse.ts, src/serve.ts, tests/api.test.ts]
done_when: "bun test tests/api.test.ts"
tests_frozen: [tests/api.test.ts]
pinga_task: T122
---
## Fazer
- Rotas geradas do registro; `via: web` por padrão (ou header `X-Ginga-Via`).
- SSE a partir da tabela `events` do `state.db` (`Last-Event-ID` = id do evento).
- Teste de paridade: conjunto de verbos do registro == conjunto de rotas; mesma resposta JSON da CLI.
## Não fazer
- Sem auth aqui (TASK-04); continua só em `127.0.0.1`.
## Contexto
- `p-inga/web/server.ts` e `p-inga/web/sse.ts` (base de SSE).

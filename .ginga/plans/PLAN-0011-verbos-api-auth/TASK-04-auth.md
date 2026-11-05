---
type: task
mode: padrao
goal: "API e web exigem token ou IP da allowlist da tailnet; sem auth configurada, serve recusa sair de 127.0.0.1"
title: Auth da API
plan: PLAN-0011-verbos-api-auth
repo: ginga
depends_on: [TASK-03-api-sse]
tier: medium
pinga_task: T124
touch: [src/api/auth.ts, src/api/server.ts, src/serve.ts, tests/auth.test.ts]
done_when: "bun test tests/auth.test.ts"
tests_frozen: [tests/auth.test.ts]
---
## Fazer
- `Authorization: Bearer` contra `GINGA_TOKEN` ou `[serve].token_file` (comparação em tempo constante); ou IP em `[serve].allow` (CIDRs).
- Sem token e sem allow → bind forçado em `127.0.0.1`; `--host 0.0.0.0` → exit 2 com mensagem.
- 401 sem corpo detalhado; verbos de escrita registram o principal no `by`.
## Não fazer
- Não guardar o token no `project.toml` versionado.
## Contexto
- SPEC-0001, risco "API e Roda sem auth".

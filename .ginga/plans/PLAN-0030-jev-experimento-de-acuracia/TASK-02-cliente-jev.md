---
type: task
mode: padrao
goal: "createJevClient chama o endpoint systemone de um provider, com timeout, um retry em 408/429/5xx, normalização de confiança e fetch injetável"
title: Cliente systemone
plan: PLAN-0030-jev-experimento-de-acuracia
repo: manda
depends_on: []
tier: free
touch: [src/jev/client.ts, src/jev/providers.json, tests/jev/client.test.ts]
done_when: "bun test tests/jev/client.test.ts"
tests_frozen: [tests/jev/client.test.ts]
---
## Fazer
- `providers.json` (dados): `opencode` (`https://opencode.ai/inference/systemone/v1/systemone`, modelo `jev-1.13-free`, chave `OPENCODE_API_KEY`), `openrouter` (`https://openrouter.ai/api/alpha/decisions`, `typesafe/jev-1.14`, `OPENROUTER_API_KEY`), `typesafe` (`https://api.typesafe.ai/v1/systemone`, `jev-latest`, `TYPESAFE_API_KEY`), `vercel` (`https://ai-gateway.vercel.sh/typesafe/v1/systemone`, `typesafe-ai/jev`, `AI_GATEWAY_API_KEY`), `local` (`http://127.0.0.1:8080/v1/systemone`, sem chave).
- Corpo `{ model, state, questions }`, header `Authorization: Bearer`. Timeout padrão 4000 ms; 1 retry em 100 ms só para 408/429/500/502/503/504. Resposta `choice` sem `confidence` → usar a maior probabilidade. Medir `latency_ms`.
- A chave vem de `cfg.apiKey` ou da variável de ambiente do provider; **nunca** é logada nem entra em mensagem de erro.
## Interface
- `createJevClient`, `JevProvider`, `JevQuestion`, `JevAnswer`, `JevResult`, `JevError` (PLAN.md). Teste: servidor falso via `fetchImpl` cobrindo ok, 401, 429 então ok, 500 duas vezes, timeout, `choice` sem `confidence`, chave ausente (erro claro sem vazar nada).
## Não fazer
- Nenhum teste faz rede. Não ler `~/.jev-gateway`. Não copiar código do `jev-gateway`; só o formato do corpo, que é a API pública do Jev.
## Contexto
- https://docs.typesafe.ai/introduction; `knowledge/research/jev-gateway-2026-10-29.md` §1 e §7.

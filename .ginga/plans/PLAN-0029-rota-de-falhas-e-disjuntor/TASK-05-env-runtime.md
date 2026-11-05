---
type: task
mode: mvp
goal: "Todo runtime do manda roda com PYTHONDONTWRITEBYTECODE=1 e stdin fechado"
title: Ambiente padrão dos runtimes
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: []
tier: free
touch: [src/runtime/env.ts, src/runtime/index.ts, tests/runtime_env.test.ts]
done_when: "bun test tests/runtime_env.test.ts"
tests_frozen: [tests/runtime_env.test.ts]
---
## Fazer
- `runtimeEnv(base)` acrescenta `PYTHONDONTWRITEBYTECODE=1`; o spawn de todos os runtimes (`opencode`, `pi`, `claude`, `codex`, `agy`) usa `stdin: "ignore"`.
## Interface
- `export function runtimeEnv(base: Record<string, string | undefined>): Record<string, string>` e `export const SPAWN_STDIN = "ignore"` em `src/runtime/env.ts`. Teste: para cada runtime da porta, o spawn espionado recebe o env com a variável e stdin `ignore`.
## Não fazer
- Não mudar argv dos runtimes.
## Contexto
- PLAN-0011, log de 2026-10-29 (`scope_drift` por `__pycache__`).

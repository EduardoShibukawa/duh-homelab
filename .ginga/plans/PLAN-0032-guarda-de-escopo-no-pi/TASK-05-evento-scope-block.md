---
type: task
mode: mvp
goal: "bloqueios e erros da guarda viram eventos v1 scope.block e scope.guard_error, contados por regra"
title: Eventos da guarda
plan: PLAN-0032-guarda-de-escopo-no-pi
repo: manda
depends_on: [TASK-03-extensao-pi]
tier: free
touch: [src/events.ts, src/runtime/scope_events.ts, tests/scope_events.test.ts]
done_when: "bun test tests/scope_events.test.ts tests/events.test.ts"
pinga_task: T165
tests_frozen: [tests/scope_events.test.ts]
---
## Fazer
- `scope.block` com `{ task, tool, path, rule }` e `scope.guard_error` com `{ task, message }`, no formato v1 (sem conteúdo de arquivo).
- `countByRule(events)` para a Roda/métricas medirem quantos `scope_drift` foram evitados.
## Interface
- Teste: forma dos eventos, contagem por regra, nenhum campo de conteúdo.
## Não fazer
- Não mudar eventos existentes.
## Contexto
- SPEC-0003 (catálogo de sinais), SPEC-0004 (meta de `scope_drift`).

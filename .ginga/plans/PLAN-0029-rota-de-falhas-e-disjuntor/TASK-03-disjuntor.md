---
type: task
mode: mvp
goal: "O disjuntor por modelo no state.db abre por 10, 30 e 120 minutos, passa a meio-aberto ao vencer e fecha no sucesso"
title: Disjuntor por modelo
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: []
tier: free
touch: [src/breaker.ts, tests/breaker.test.ts]
done_when: "bun test tests/breaker.test.ts"
tests_frozen: [tests/breaker.test.ts]
---
## Fazer
- Tabela `model_breaker(model PRIMARY KEY, level, opened_at, until, last_reason)` no `.ginga/state/state.db` (caminho injetável). Falha: `level+1` (máx. 3), `until = now + [10,30,120][level-1]` min. Vencido → `half_open`. `recordSuccess` zera.
## Interface
- `breakerOf`, `recordFailure`, `recordSuccess` (PLAN.md). Teste: 3 falhas → 10/30/120; relógio depois do `until` → `half_open`; dois `Database` no mesmo arquivo (2 lanes) veem o mesmo estado.
## Não fazer
- Não chamar probe (quem chama é a TASK-09).
## Contexto
- `breaker` do frontmatter do ROUTING; `src/escalation.ts` (`getBreaker`, hoje por `reason_code`).

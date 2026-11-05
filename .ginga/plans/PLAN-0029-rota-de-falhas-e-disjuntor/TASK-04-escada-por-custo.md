---
type: task
mode: mvp
goal: "pickModel escolhe o free saudável de qualquer provider antes de qualquer pago, e o pago só com todos os free abertos, ALLOW_PAID e teto ok"
title: Escada por custo
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-03-disjuntor]
tier: free
touch: [src/ladder.ts, tests/ladder.test.ts]
done_when: "bun test tests/ladder.test.ts"
tests_frozen: [tests/ladder.test.ts]
pinga_task: T172
---
## Fazer
- Ordem: lista `free` (alternando providers), pulando `open`; `iceman*` só com `mitRepo`. Depois o pool do `tier` (pago) só com `allowPaid && capOk`. `strong` só com `tier: strong` explícito. Nada disponível → `model: null` com o motivo.
## Interface
- `pickModel` (PLAN.md). Teste: todos free fechados → 1º free; 1º free aberto → 2º de outro provider; todos free abertos e `allowPaid: false` → `null`; `mitRepo: false` pula o iceman.
## Não fazer
- Não ler arquivos (tudo injetado).
## Contexto
- ROUTING (vigente desde 2026-10-28); `PROVIDER-nvidia.md`.

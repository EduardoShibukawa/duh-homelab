---
type: task
mode: padrao
goal: "buildReplanContext limita o LEARNINGS.md injetado: descarta linhas acima de 600 caracteres e mantém no máximo os últimos 4000 caracteres"
title: manda replan com teto de learnings
plan: PLAN-0038-learnings-que-funcionam
repo: manda
depends_on: []
tier: free
touch: [src/replan.ts, tests/replan_learnings_cap.test.ts]
done_when: "bun test tests/replan_learnings_cap.test.ts tests/replan.test.ts"
tests_frozen: [tests/replan_learnings_cap.test.ts]
---
## Fazer
- Em `src/replan.ts`, função pura exportada `capLearnings(raw: string, opts?: { maxLine?: number; maxTotal?: number }): string` (padrões 600 e 4000): troca cada linha maior que `maxLine` por `[linha omitida: N caracteres]`; se o total passar de `maxTotal`, mantém o **final** (as entradas mais novas), cortando no início de uma linha, e prefixa `[learnings antigos omitidos]`.
- `buildReplanContext` usa `capLearnings(learnings.trimEnd())` na seção `# LEARNINGS`.
## Interface
- Teste: linha de 700 chars vira `[linha omitida: 700 caracteres]`; entrada normal passa intacta; 50 linhas de 200 chars → resultado ≤ 4100 chars, termina na última linha e começa com o aviso; `buildReplanContext` com um `LEARNINGS.md` de 18 mil chars em uma linha devolve contexto sem essa linha. Os testes antigos de replan continuam verdes.
## Não fazer
- Não mudar o corte do diff (20 mil) nem a ordem das seções.
## Contexto
- `manda/src/replan.ts:38-59`.

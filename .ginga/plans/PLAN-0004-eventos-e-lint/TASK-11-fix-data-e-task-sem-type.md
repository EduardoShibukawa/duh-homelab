---
type: task
mode: mvp
goal: "Validador recusa datas de calendário impossíveis e o lint marca TASK-*.md fora do padrão mesmo sem type: task"
title: Fix do judge (rodada 3)
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T9
depends_on: [TASK-10-fix-okf-e-numeracao]
tier: free
touch: [src/events/validate.ts, src/lint/index.ts, src/lint/relations.ts, tests/lint_fix3.test.ts]
done_when: "bun test tests/lint_fix3.test.ts tests/lint_fix2.test.ts tests/events_fix.test.ts tests/events.test.ts tests/lint_relations.test.ts"
tests_frozen: [tests/lint_fix3.test.ts]
---
## Fazer
- `tsInvalida` (`src/events/validate.ts:150`): além do regex, conferir que ano/mês/dia/hora/min/seg do texto batem com os de `new Date(ts)` em UTC (recusa 2026-02-30, 2026-04-31, 24:00, :60; aceita 2024-02-29).
- Lint (`src/lint/index.ts:29-33`, `relations.ts:58`): todo arquivo `TASK-*.md` dentro de `plans/PLAN-*/` entra na checagem de nome, mesmo com `type` ausente ou desconhecido; fora do padrão `TASK-<NN>-slug` é erro com o nome do arquivo.
- Testes RED do Planner em `tests/lint_fix3.test.ts` (frozen).
## Não fazer
- Não alterar testes frozen. Não aceitar datas por `Date.parse` sozinho.
## Contexto
- Judge rodada 3 (Codex gpt-6-luna): fail simples nos dois itens. Flash: pass.

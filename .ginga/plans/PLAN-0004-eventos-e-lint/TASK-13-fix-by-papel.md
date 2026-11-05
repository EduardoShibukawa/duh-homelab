---
type: task
mode: mvp
goal: "transition.data.by aceita <papel> (qualquer papel), não só owner/system"
title: Fix do judge (rodada 5, achado 1)
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T18
depends_on: [TASK-12-fix-nome-sem-frontmatter]
tier: free
touch: [src/events/validate.ts, tests/events_fix2.test.ts]
done_when: "bun test tests/events_fix2.test.ts tests/events_fix.test.ts tests/events.test.ts tests/lint_fix4.test.ts tests/lint_fix3.test.ts tests/lint_fix2.test.ts tests/lint_relations.test.ts"
tests_frozen: [tests/events_fix2.test.ts]
---
## Fazer
- `src/events/validate.ts` (~linha 32-39): o enum de `transition.data.by` deixa de ser `["owner", "system"]` e passa a aceitar qualquer string (`<papel>`), conforme `docs/events-v1.md:26`. `owner` e `system` continuam válidos.
- `by` não-string continua inválido.
- Testes RED do Planner em `tests/events_fix2.test.ts` (frozen).
## Não fazer
- Não alterar testes frozen nem os demais enums de `transition` (entity, via).

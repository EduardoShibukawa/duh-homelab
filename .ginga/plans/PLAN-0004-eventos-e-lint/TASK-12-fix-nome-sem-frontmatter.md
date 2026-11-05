---
type: task
mode: mvp
goal: "TASK-*.md fora do padrão recebe o erro de nome mesmo sem frontmatter válido"
title: Fix do judge (rodada 4)
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T10
depends_on: [TASK-11-fix-data-e-task-sem-type]
tier: free
touch: [src/lint/index.ts, src/lint/relations.ts, tests/lint_fix4.test.ts]
done_when: "bun test tests/lint_fix4.test.ts tests/lint_fix3.test.ts tests/lint_fix2.test.ts tests/events_fix.test.ts tests/events.test.ts tests/lint_relations.test.ts"
tests_frozen: [tests/lint_fix4.test.ts]
---
## Fazer
- `src/lint/index.ts:27-40`: a checagem de nome de `TASK-*.md` em `plans/PLAN-*/` roda também quando `entry.ok` é falso (sem frontmatter ou com frontmatter quebrado); o erro de frontmatter continua.
- Nome válido (`TASK-03-ok.md`) sem frontmatter recebe só o erro de frontmatter.
- Testes RED do Planner em `tests/lint_fix4.test.ts` (frozen).
## Não fazer
- Não alterar testes frozen.

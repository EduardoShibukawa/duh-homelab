---
type: task
mode: mvp
goal: "Export OKF recusa saída igual ou dentro do bundle; TASK fora do padrão TASK-NN-slug é erro de lint"
title: Fix do judge (rodada 2)
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T8
depends_on: [TASK-09-fix-pi-harness-ulid]
tier: free
touch: [src/lint/okf.ts, src/lint/relations.ts, src/cli.ts, tests/lint_fix2.test.ts]
done_when: "bun test tests/lint_fix2.test.ts tests/lint_okf.test.ts tests/lint_relations.test.ts"
tests_frozen: [tests/lint_fix2.test.ts]
---
## Fazer
- `exportOkf`: se `out` for igual a `dir` ou estiver dentro dele (comparar `realpath`/`resolve`), não escrever nada e retornar erro; o CLI sai com exit != 0.
- `lintNumbering`/`relations.ts`: arquivo `TASK-*.md` cujo nome não casa `^TASK-(\d+)-` vira `LintError` (hoje é ignorado em `relations.ts:50-62`).
- Testes RED já escritos pelo Planner em `tests/lint_fix2.test.ts` (frozen).
## Não fazer
- Não alterar `tests/lint_okf.test.ts` nem `tests/lint_relations.test.ts` (frozen).
## Contexto
- Judge rodada 2 (Codex): `src/lint/okf.ts:96-123` e `src/lint/relations.ts:50-62`.

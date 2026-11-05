---
type: task
mode: mvp
goal: "ginga lessons import <arquivo> converte o LESSONS.md da raiz e as propostas do pinga em LESSON-*.md, sem duplicar"
title: ginga lessons import
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T148
depends_on: [TASK-06-lessons-find]
tier: free
touch: [src/lessons.ts, src/lessons_import.ts, src/verbs/learning.ts, tests/lessons_import.test.ts, tests/fixtures/lessons-import/]
done_when: "bun test tests/lessons_import.test.ts"
tests_frozen: [tests/lessons_import.test.ts, tests/fixtures/lessons-import/]
---
## Fazer
- Ler entradas `## ...` do `LESSONS.md` (formato livre da raiz) e do `LESSONS-PROPOSED.md` do pinga (cabeçalho `# LESSONS-PROPOSED — pinga learn propose v1`); cada uma vira `LESSON-NNNN-slug.md` com `from: import:<arquivo>`, `scope.files` vazio quando não houver caminho citado.
- Idempotente por hash do texto da entrada (`skipped` conta as já importadas).
## Interface
- `importLessons(root, file)` (PLAN.md); verbo `lessons import` (arg `file`) em `LEARNING_VERBS`. Teste: fixture com 3 entradas → 3 arquivos; rodar de novo → `created: []`, `skipped: 3`.
## Não fazer
- Não apagar nem editar os arquivos de origem.
## Contexto
- `p-inga/src/lessons.ts` (`PROPOSALS_HEADER`); `LESSONS.md` da raiz do workspace.

---
type: task
mode: mvp
goal: "ginga lessons find --touch <caminhos> devolve as LESSONs cujo escopo cobre esses caminhos"
title: ginga lessons find
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T147
depends_on: [TASK-05-learning-promote]
tier: free
touch: [src/lessons.ts, src/verbs/learning.ts, tests/lessons_find.test.ts]
done_when: "bun test tests/lessons_find.test.ts"
tests_frozen: [tests/lessons_find.test.ts]
---
## Fazer
- Match por prefixo/glob de `scope.files` e por `scope.repo`; `--json` com `id`, `title`, `path`, `why`.
- Com context provider gira, aceita `--symbol` (via `manda context`); sem ele, ignora.
## Interface
- `findLessons(root, touch, repo)` (PLAN.md); verbo `lessons find` em `LEARNING_VERBS`. Teste: lesson com `scope.files: [src/notify/]` casa `src/notify/router.ts` e não casa `src/tick.ts`.
## Não fazer
- Sem busca semântica/LLM.
## Contexto
- Doc 06 §5 ("Reuso").

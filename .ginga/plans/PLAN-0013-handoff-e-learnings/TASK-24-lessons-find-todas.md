---
type: task
mode: mvp
goal: "Corrigir o achado grave do judge na TASK-06: `lessons find` devolve TODAS as LESSONs que casam (não só matched[0]), com `title` real do frontmatter no --json, e aceita múltiplos caminhos no --touch (lista separada por vírgula)"
title: lessons find completo (todas as LESSONs, title, múltiplos --touch)
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T314
depends_on: [TASK-06-lessons-find]
tier: free
touch: [src/lessons.ts, src/verbs/learning.ts, tests/lessons_find_all.test.ts]
done_when: "bun test tests/lessons_find_all.test.ts tests/lessons_find.test.ts"
tests_frozen: [tests/lessons_find_all.test.ts]
---
## Fazer
- `findLessons(root, filePaths, repo?)` em `src/lessons.ts` passa a devolver `title` real (parseado do frontmatter `title:` da LESSON) em vez de `""`.
- O verbo `lessons find` em `src/verbs/learning.ts` devolve `lessons: [...]` com **todas** as LESSONs retornadas por `findLessons` (cada uma com `id`, `title`, `path`, `why`), não só a primeira.
- `--touch` aceita múltiplos caminhos numa lista separada por vírgula (ex.: `--touch src/notify/router.ts,src/other/x.ts`); o verbo separa e repassa todos ao `findLessons`. Caminho único continua funcionando.
## Interface
- Teste congelado novo `tests/lessons_find_all.test.ts`: bundle com 2 LESSONs do repo ginga que casam o mesmo caminho (`scope.files: [src/notify/]` e `[src/notify/router.ts]`) + 1 que não casa → `findLessons` devolve as 2 com `title` não vazio; o verbo com `--touch` lista vírgula devolve as 3 que casam (2 + a de `src/other/`) todas com `title`; `--touch` unitário devolve só as que casam.
## Não fazer
- Não alterar `tests/lessons_find.test.ts` (frozen da TASK-06); não adding busca semântica/LLM; não mudar a CLI genérica (`src/cli.ts`) — a lista por vírgula é a interface.
## Contexto
- Achado grave do judge 2026-10-31T23:11 (gate exit 11): `src/verbs/learning.ts` `lessonsFind` devolve só `matched[0]` com `title: ""` e um único `--touch`; AC "Learnings promovidos viram LESSON e o Planner os encontra pelo touch" quebrada. Não criar scripts de depuração fora do `touch` (use /tmp).

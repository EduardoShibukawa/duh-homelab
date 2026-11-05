---
type: task
mode: mvp
goal: "manda plan inclui no PLAN gerado as LESSONs encontradas pelo touch das TASKs"
title: manda plan cita lessons
plan: PLAN-0013-handoff-e-learnings
repo: manda
depends_on: [TASK-06-lessons-find]
tier: free
touch: [src/plan.ts, src/plan_lessons.ts, tests/plan_lessons.test.ts]
done_when: "bun test tests/plan_lessons.test.ts"
tests_frozen: [tests/plan_lessons.test.ts]
pinga_task: T318
---
## Fazer
- Depois de gerar as TASKs: `ginga lessons find --touch ... --json` se `ginga` estiver no PATH; senão, varre `.ginga/knowledge/lessons/` direto.
- Seção `## Lessons` no PLAN com links; lessons também entram no prompt do Planner numa 2ª passada opcional.
## Interface
- `lessonsForTouch(root: string, touch: string[]): { id: string; title: string; path: string }[]` em `src/plan_lessons.ts` do manda (usa `ginga lessons find --json` quando houver, senão lê os arquivos). Teste: com e sem `ginga` no PATH, mesmo resultado.
## Não fazer
- Não importar código do ginga.
## Contexto
- `src/plan.ts` (PLAN-0008 TASK-07).

---
type: task
mode: mvp
goal: "manda aloca ids T<N> livres de forma determinística a partir do pinga queue e dos TASK-*.md, sem colisão entre PLANs"
title: Alocação determinística do pinga_task
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: []
tier: free
touch: [src/alloc.ts, tests/alloc.test.ts]
done_when: "bun test tests/alloc.test.ts"
tests_frozen: [tests/alloc.test.ts]
pinga_task: T154
---
## Fazer
- `taken` = ids do `pinga queue --json` + `pinga_task:` de todos os `TASK-*.md` do bundle + `tasks/T*/` do repo; novos ids = maior + 1, +2...
## Interface
- `allocTaskIds(taken, count)` (PLAN.md). Teste: `["T13","T150","T9"]`, 2 → `["T151","T152"]`; vazio → `["T1"]`; ids não numéricos ignorados.
## Não fazer
- Não chamar o pinga no teste (lista injetada).
## Contexto
- Colisão real do PLAN-0010 (T13–T18), em `prompts/backlog-ginga.md`.

## Follow-up do judge (2026-10-31)
- O judge notou que `taken` em `src/red.ts` é montado antes de criar a worktree;
  na primeira execução `tasks/T*/` (nem root/<repo>/tasks) não é varrido, risco de colisão.
- [TASK-17](TASK-17-worktree-before-taken.md) (T167) resolve: move a criação da worktree
  antes de `taken`; `alloc.ts` em si está correto. Commit `e6c3d16`; verify pass (1331).

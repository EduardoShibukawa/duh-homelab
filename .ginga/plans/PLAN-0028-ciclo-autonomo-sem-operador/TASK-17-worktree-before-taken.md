---
type: task
mode: padrao
goal: "redPlan cria a worktree do plano antes de montar `taken`, varrendo tasks/T*/ da main na primeira execução (achado do judge em TASK-02 e TASK-16)"
title: redPlan cria worktree antes de taken para varrer tasks/T* na primeira execução
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-16-taken-scans-tasks-dir]
tier: free
touch: [src/red.ts, tests/red_taken.test.ts, tasks/T167/PLAN.md]
done_when: "bun test tests/red_taken.test.ts"
tests_frozen: [tests/red_taken.test.ts]
---

## Achado do judge (2026-10-30, grave; ref TASK-02/TASK-16)
- `redPlan` (src/red.ts) monta `taken` (fila + bundle + scan de `tasks/T*` do worktree) ANTES de criar a worktree.
- Na primeira execução a worktree não existe, o scan é no-op, e o id alocado pode colidir com um `tasks/T<N>` da `main`.
- O teste congelado (T166) só exercita worktree já existente.

## Fazer
- Mover a criação da worktree (`git worktree add`) para ANTES do cálculo de `taken`.
- O scan de `tasks/T*/` na worktree então varre a `main` recém-criada na primeira execução.

## Testes frozen em `tests/red_taken.test.ts` (novo caso)
3. **First execution**: `main` com `tasks/T1/PLAN.md`; worktree NÃO criada no setup; `redPlan` cria a worktree do `main` → `taken` inclui T1 → id alocado é **T2**, não T1.

## Não fazer
- Não editar tests/red.test.ts, tests/red_repo.test.ts, tests/red_cli_repo.test.ts nem fixtures existentes.

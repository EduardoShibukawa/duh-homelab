---
type: task
mode: padrao
goal: "CLI `manda red --repo <repo>` funciona em PLAN multi-repo: processa só TASKs do repo (herda o filtro de redPlan de TASK-14) e devolve JSON com as TASKs corretas"
title: CLI manda red multi-repo (achado do judge na TASK-09)
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-09-manda-red-cli, TASK-14-red-repo-filter]
tier: free
touch: [tests/red_cli_repo.test.ts, tasks/T165/PLAN.md]
done_when: "bun test tests/red_cli_repo.test.ts"
tests_frozen: [tests/red_cli_repo.test.ts]
pinga_task: T165
---

## Achado do judge (2026-10-30, simples; ref TASK-09)
- `src/cli.ts` (command red) chama `redPlan` e valida `tests_frozen`, mas herda a falta de filtro por repo de `src/red.ts:165-173`: PLAN multi-repo falha com arquivo ausente de TASK de outro repo.

## Fazer
- A CLI já passa `repo: repoArg` a `redPlan` (src/cli.ts:~354). Com o filtro de TASK-14, a multi-repo funciona sem mudança em `src/cli.ts`.
- Teste frozen em `tests/red_cli_repo.test.ts`: PLAN com TASKs de dois repos, `manda red --repo manda` processa só as do manda e devolve JSON com 1 TASK (TASK-01-a), sem erro de frozen de outro repo.

## Não fazer
- Não editar `tests/red_cli.test.ts` nem `src/cli.ts` (sem mudança de código, só teste).

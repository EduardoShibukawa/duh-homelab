---
type: task
mode: padrao
goal: "Filtra TASKs por repo em redPlan (src/red.ts:96 filtra bundle.tasks por repo), corrige o erro de frozen/<repo> ausente para lançar o caminho real em vez de 'tests/frozen.test.ts', e grava `status: blocked` com motivo `test_passed_on_base` no frontmatter em vez de `blocked: true`"
title: redPlan filtra por repo, frozen path real e status blocked (achado do judge na TASK-03)
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-03-manda-red]
tier: free
touch: [src/red.ts, tests/red_repo.test.ts, tasks/T164/PLAN.md]
done_when: "bun test tests/red_repo.test.ts"
tests_frozen: [tests/red_repo.test.ts]
pinga_task: T164
---

## Achado do judge (2026-10-30, grave; ref TASK-03)
- `redPlan` (src/red.ts:95-230) itera todas as TASKs do bundle sem filtrar por `repo`; em PLAN multi-repo aloca/prova RED de TASKs do ginga e src/red.ts:165-173 aborta por tests_frozen ausente em frozen/manda.
- `src/red.ts:161` lança caminho fixo `tests/frozen.test.ts` quando `frozen/<repo>` não existe, em vez do caminho real.
- `src/red.ts:209` grava `blocked: true` no frontmatter em vez de `status: "blocked"`.
- Testes existentes passam só porque a fixture é toda `repo: manda`.

## Fazer
- Filtrar TASKs por `repo` logo após `loadBundle` (só TASKs com `repo === options.repo`).
- Remover o check de existência de `frozenSrc`; a validação individual de cada `tests_frozen` (já existente) lança `srcPath` (caminho real) em vez de `tf`.
- Gravar `status: "blocked"` com `reason: "test_passed_on_base"` no frontmatter em vez de `blocked: true`.

## Testes frozen em `tests/red_repo.test.ts`
1. **Multi-repo**: bundle com TASKs de manda e ginga; `redPlan --repo manda` processa só as do manda (1 prove-red call, sem worktree ginga).
2. **Frozen ausente**: `frozen/manda` não existe → erro contém o caminho real (`frozen/manda`).
3. **Blocked status**: `test_passed_on_base` → frontmatter tem `status: blocked`, não `blocked: true`.

## Não fazer
- Não editar `tests/red.test.ts`, `tests/red_cli.test.ts` nem fixtures de T156/T159.

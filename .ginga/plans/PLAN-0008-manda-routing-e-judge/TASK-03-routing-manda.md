---
type: task
mode: padrao
goal: "manda route <TASK> --json resolve runtime/provider/modelo pela precedência project.toml > ROUTING > padrão"
title: manda route com precedência
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: [TASK-02-routing-legivel]
tier: medium
pinga_task: T10
touch: [src/routing.ts, src/family.ts, src/cli.ts, tests/routing.test.ts, tests/fixtures/models/]
done_when: "bun test tests/routing.test.ts"
tests_frozen: [tests/routing.test.ts, tests/fixtures/models/]
---
## Fazer
- Pasta de modelos: `--models`, senão `[routing].models` do `project.toml`, senão `~/.config/ginga/models`.
- Papel fixado em `[runtimes]` ganha e ignora a escada; senão o 1º candidato do pool do `tier` da TASK.
- `src/family.ts`: mesma saída de `p-inga/src/family.ts` (`modelFamily`) nos casos do teste de paridade.
## Não fazer
- Sem escalada (TASK-03) e sem probe de quota real (stub `available()`).
## Contexto
- `pi-harness/.pi/extensions/router.ts` (`getRolePool` l. 277, `loadPool` l. 805, `poolFromConfig` l. 734).

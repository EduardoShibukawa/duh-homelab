---
type: task
mode: padrao
goal: "manda lane lê [supervisor] models do project.toml e o vigia compara com o tick anterior"
title: follow-up do judge TASK-14(b) — models do toml e vigia por tick
plan: PLAN-0023-vigia-e-supervisor
repo: manda
depends_on: [TASK-14-manda-lane-paridade]
tier: free
pinga_task: T102
touch: [src/pipeline.ts, tests/pipeline_vigia.test.ts, tasks/T102/PLAN.md]
done_when: "bun test tests/pipeline_vigia.test.ts tests/pipeline_parity.test.ts tests/pipeline.test.ts"
tests_frozen: [tests/pipeline_vigia.test.ts]
---

## Fazer
- `src/pipeline.ts`: `loadSupervisorModels(root)` lê `[supervisor] models` (array de strings) de `<root>/.ginga/project.toml` via `Bun.TOML.parse`; ausente/inválido → `DEFAULT_MODELS`. `runPipelineImpl` usa `opts.models ?? loadSupervisorModels(root)`.
- No loop do vigia, guarde `tickMs = Date.now()` ANTES de checar e passe o `tickMs` do tick anterior (o 1º tick usa o início da rodada) como `sinceMs` a `hasRealProgress`, de modo que só mudanças desde o último tick contam como progresso.
## Não fazer
- Não alterar `tests/pipeline_vigia.test.ts` nem `tests/pipeline_parity.test.ts`.

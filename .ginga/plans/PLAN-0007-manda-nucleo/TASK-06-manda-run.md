---
type: task
mode: padrao
goal: "manda run <PLAN> [--task T] executa as TASKs em ordem: worktree, runtime, gate, merge, emitindo attempt e transition"
title: manda run + eventos
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T6
depends_on: [TASK-04-runtime-claude-codex-agy, TASK-05-worktree-gate]
tier: medium
touch: [src/run.ts, src/events.ts, src/cli.ts, tests/run.test.ts]
done_when: "bun test tests/run.test.ts"
tests_frozen: [tests/run.test.ts]
---
## Fazer
- Runtime por TASK: `[runtimes].executor` do `project.toml`, senão `[runtimes.tier]` (`free = "pi"` etc.), senão `pi`.
- Prompt do executor: TASK + `touch` + `done_when` (base: `formatWorkerPrompt` do `sdlc.ts`).
- `attempt` v1 (campos do 07) e `transition` (`entity: task`) em `$GINGA_EVENTS`; sem a variável, só stdout.
- Exit 0 todas ok, 1 alguma falhou, 2 uso.
## Não fazer
- Sem escalada/budget/judge (PLAN-0008); sem claim/lease (é do `ginga tick`).
## Contexto
- `pi-harness/scripts/harness-task.ts` (fluxo de 1 TASK headless), `pi-harness/.pi/extensions/sdlc.ts` (`runSubagentTask`, `formatWorkerPrompt`).

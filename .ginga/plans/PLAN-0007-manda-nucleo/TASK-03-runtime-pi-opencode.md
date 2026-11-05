---
type: task
mode: padrao
goal: "Runtime port com adapters pi e opencode portados do pi-harness, sem dependência do Pi"
title: Runtime port + pi + opencode
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T3
depends_on: [TASK-01-manda-repo]
tier: medium
touch: [src/runtime/port.ts, src/runtime/pi.ts, src/runtime/opencode.ts, src/runtime/failure.ts, tests/runtime_pi_opencode.test.ts, tests/fixtures/runtime/]
done_when: "bun test tests/runtime_pi_opencode.test.ts"
tests_frozen: [tests/runtime_pi_opencode.test.ts, tests/fixtures/runtime/]
---
## Fazer
- Interface `RuntimeAdapter` (ver PLAN). `failure` ∈ `done_when|quota_exhausted|timeout|infra|judge`.
- Portar `PiTaskRunner` (l. 416), `parsePiRunnerOutput` (l. 281), `OpenCodeTaskRunner` (l. 665), `parseOpenCodeOutput` (l. 607), `classifyRunnerFailure` (l. 321).
- O spawn é injetável (`SpawnFn`) para os testes rodarem com stdout gravado.
## Não fazer
- Sem `readControls`/HUD e sem `parseEventStream` do bench: portar só o parsing necessário.
## Contexto
- `pi-harness/.pi/extensions/runners.ts`; `pi-harness/src/router/probe.ts` (`defaultSpawn`).

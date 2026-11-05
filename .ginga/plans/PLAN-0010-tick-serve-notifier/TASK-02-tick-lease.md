---
type: task
mode: padrao
goal: "ginga tick despacha cada TASK desbloqueada uma única vez, mesmo com dois ticks em paralelo"
title: ginga tick com claim/lease
plan: PLAN-0010-tick-serve-notifier
repo: ginga
depends_on: [TASK-01-state-db]
tier: medium
pinga_task: T20
touch: [src/tick.ts, src/cli.ts, tests/tick.test.ts, tests/tick_parallel.test.ts, tests/stubs/]
done_when: "bun test tests/tick.test.ts tests/tick_parallel.test.ts"
tests_frozen: [tests/tick.test.ts, tests/tick_parallel.test.ts]
---
## Fazer
- Candidatas: TASKs de PLAN `approved`, sem receipt `pass` (`pinga queue --json`), deps fechadas, sem lease válido, PLAN não pausado.
- Claim atômico (`BEGIN IMMEDIATE`, lease com TTL), dispatch por `[commands].dispatch` (padrão `manda run {plan} --task {task}`), renova enquanto roda, libera no fim; lease vencido volta à fila.
- Emite `transition` (`by: system`). `--dry-run` e `--json`.
- Teste paralelo: 2 processos `ginga tick` + stub de `manda` que conta chamadas → cada TASK 1 vez.
## Não fazer
- Não decidir runtime/modelo (isso é do manda).
## Contexto
- `p-inga/src/queue.ts` (`claim` l. 382, `canClaim` l. 340, `release` l. 417).

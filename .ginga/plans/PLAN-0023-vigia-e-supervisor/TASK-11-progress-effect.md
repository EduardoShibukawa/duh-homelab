---
type: task
mode: padrao
goal: "progress do heartbeat mede efeito real (arquivos/commits/receipts), nunca iteracoes. RED: lane viva sem efeito -> progress constante -> no_progress dispara"
title: heartbeat progress efeito real
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-03-serve-supervisor]
tier: free
pinga_task: T38
touch: [src/supervisor.ts, tests/supervisor_progress_effect.test.ts, tasks/T38/PLAN.md]
done_when: "bun test tests/supervisor_progress_effect.test.ts"
tests_frozen: [tests/supervisor_progress_effect.test.ts]
---
## Fazer
- Adicionar SupervisorOptions.progressCheck?: (lane) => number | Promise<number>.
- Emitir heartbeat com progress = await progressCheck(lane) (default 0).
- Nunca usar numero de iteracoes/runs.
- Teste: lane viva sem efeito -> progress constante -> no_progress dispara.
## Não fazer
- Não alterar tests_frozen.

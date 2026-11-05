---
type: task
mode: padrao
goal: "heartbeat periódico do supervisor leva o PID do filho em execução, não process.pid do supervisor"
title: follow-up do judge 01:07 — pid do filho no heartbeat
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-20-heartbeat-periodico]
tier: free
pinga_task: T112
touch: [src/supervisor.ts, tests/supervisor_heartbeat_pid.test.ts, tasks/T112/PLAN.md]
done_when: "bun test tests/supervisor_heartbeat_pid.test.ts tests/supervisor_heartbeat_running.test.ts tests/supervisor_progress_effect.test.ts tests/supervisor_iterations.test.ts tests/serve_supervisor.test.ts"
tests_frozen: [tests/supervisor_heartbeat_pid.test.ts]
---
## Fazer
- `src/supervisor.ts` (~:162, heartbeat periódico): `pid` = `child.pid` quando for número inteiro > 0; sem pid conhecido (mock de teste sem `pid`) usa `0` (desconhecido) e nunca `process.pid`. O heartbeat pós-exit (~:178) também deixa de usar `process.pid` (mesma regra).
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

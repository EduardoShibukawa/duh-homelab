---
type: task
mode: padrao
goal: "supervisor emite heartbeat com progressCheck periodicamente (heartbeatMs) enquanto o filho roda"
title: follow-up do judge 00:51 — heartbeat enquanto o filho roda
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-11-progress-effect]
tier: free
pinga_task: T111
touch: [src/supervisor.ts, tests/supervisor_heartbeat_running.test.ts, tasks/T111/PLAN.md]
done_when: "bun test tests/supervisor_heartbeat_running.test.ts tests/supervisor_progress_effect.test.ts tests/supervisor_iterations.test.ts tests/serve_supervisor.test.ts"
tests_frozen: [tests/supervisor_heartbeat_running.test.ts]
---
## Fazer
- `src/supervisor.ts`: nova opção `heartbeatMs` (default 30000). Enquanto aguarda o exit do filho (~:140-149), um `setInterval(heartbeatMs)` chama `progressCheck` e emite `heartbeat` `{entity:"lane:<repo>", pid, progress, alive:true}` (sem sobreposição; erro do progressCheck não derruba). O intervalo é limpo (`clearInterval`) quando o filho sai, em qualquer caminho. O heartbeat pós-exit existente continua.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

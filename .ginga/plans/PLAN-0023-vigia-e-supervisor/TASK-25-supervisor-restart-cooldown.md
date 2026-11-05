---
type: task
mode: padrao
goal: "estourar max_restarts com pendência espera restart_cooldown_ms (30 min) e religa sem encerrar; padrões de backoff 60 s–10 min"
title: lacuna do corte (c) — lane não morre para sempre após max_restarts
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-24-supervisor-exit-20-e-4]
tier: free
pinga_task: T116
touch: [src/supervisor.ts, src/serve.ts, tests/supervisor_restart_cooldown.test.ts, tasks/T116/PLAN.md]
done_when: "bun test tests/supervisor_restart_cooldown.test.ts tests/supervisor_exit_codes.test.ts tests/supervisor_idle_cooldown.test.ts tests/supervisor_iterations.test.ts tests/supervisor_heartbeat_running.test.ts tests/supervisor_heartbeat_pid.test.ts tests/supervisor_progress_effect.test.ts tests/serve_supervisor.test.ts tests/install/install_supervisor.test.ts"
tests_frozen: [tests/supervisor_restart_cooldown.test.ts]
---
## Fazer
- `src/supervisor.ts`:
  - Padrões: `backoffBaseMs` 60000, `backoffMaxMs` 600000 (tanto em `runLane` quanto em `parseSupervisorConfig`); nova opção `restartCooldownMs` (padrão 1800000; `[supervisor] restart_cooldown_ms`).
  - No ramo de falha comum, quando `restarts > maxRestarts` **e há pendência** (o topo do laço reconfere), em vez de `break` com `max_restarts`: `await sleep(restartCooldownMs)`, `restarts = 0`, `backoff = base`, `continue`. A lane só encerra por `no_pending`, `stopped`, `main_moved`.
- `src/serve.ts`: repassar `restartCooldownMs` do `supCfg`.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs (se algum teste congelado depender do padrão antigo 50 ms/1 s sem passar as opções, registre no log.md do PLAN e pare).

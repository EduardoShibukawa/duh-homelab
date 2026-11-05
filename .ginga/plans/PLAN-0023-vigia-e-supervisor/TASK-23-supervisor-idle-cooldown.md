---
type: task
mode: padrao
goal: "lane que sai 0 sem progresso espera idle_cooldown_ms (padrão 10 min) antes de religar"
title: lacuna do corte (a) — saída 0 com pendência não religa na hora
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-22-no-progress-janela]
tier: free
pinga_task: T114
touch: [src/supervisor.ts, src/serve.ts, tests/supervisor_idle_cooldown.test.ts, tasks/T114/PLAN.md]
done_when: "bun test tests/supervisor_idle_cooldown.test.ts tests/supervisor_iterations.test.ts tests/supervisor_heartbeat_running.test.ts tests/supervisor_heartbeat_pid.test.ts tests/supervisor_progress_effect.test.ts tests/serve_supervisor.test.ts"
tests_frozen: [tests/supervisor_idle_cooldown.test.ts]
---
## Fazer
- `src/supervisor.ts` (`SupervisorOptions`, `runLane`, `parseSupervisorConfig`): nova opção `idleCooldownMs` (padrão 600000; `[supervisor] idle_cooldown_ms`).
- Rodada que termina com exit 0 **sem progresso** (progresso lido por `progressCheck` antes do spawn e depois da saída; sem `progressCheck` conta como sem progresso) faz `await sleep(idleCooldownMs)` antes do próximo spawn, em vez de `sleep(0)`. Com progresso, `sleep(0)`.
- `src/serve.ts`: repassar `idleCooldownMs` do `supCfg` ao `new Supervisor`.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

---
type: task
mode: padrao
goal: "supervisor trata exit 20 (main movida: para + alerta crítico) e exit 4 (cota free: pausa 60 min sem consumir restarts)"
title: lacuna do corte (b) — exit 20 e exit 4 não são falha comum
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-23-supervisor-idle-cooldown]
tier: free
pinga_task: T115
touch: [src/supervisor.ts, tests/supervisor_exit_codes.test.ts, tasks/T115/PLAN.md]
done_when: "bun test tests/supervisor_exit_codes.test.ts tests/supervisor_idle_cooldown.test.ts tests/supervisor_iterations.test.ts tests/supervisor_heartbeat_running.test.ts tests/supervisor_heartbeat_pid.test.ts tests/supervisor_progress_effect.test.ts tests/serve_supervisor.test.ts"
tests_frozen: [tests/supervisor_exit_codes.test.ts]
---
## Fazer
- `src/supervisor.ts` (`runLane`, depois de ler o `exitCode`; o ramo de falha comum fica como está):
  - **exit 20** (main movida fora do gate, como o `lane.sh`): emite `lane.round end` com `code`, emite um evento `{source:"ginga", kind:"alert", data:{rule_id:"main_moved_outside_gate", severity:"critical", entity:"lane:<repo>", summary:"..."}}`, define `stoppedReason = "main_moved"` e sai do laço da lane (para sempre). Não consome `restarts`.
  - **exit 4** (cota free esgotada): não incrementa `restarts`. Arquivo de pausa = `join(root, ".ginga", "handoffs", ".free-esgotado")` (opção `freeExhaustedFile` sobrescreve): se não existir, cria vazio (touch). Espera `max(0, 3_600_000 - idade_do_arquivo_ms)` via `sleep(...)` e volta ao topo do laço (que reconfere pendência). Sem novo spawn dentro dos 60 min.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

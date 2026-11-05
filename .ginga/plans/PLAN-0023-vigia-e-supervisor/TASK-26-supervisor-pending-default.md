---
type: task
mode: padrao
goal: "pendingCheck padrão do supervisor conta backlog (- [ ]) + ready/<repo>.json (+ fila, se configurada); tudo vazio = no_pending"
title: lacuna do corte (d) — pendência padrão do supervisor
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-25-supervisor-restart-cooldown]
tier: free
pinga_task: T117
touch: [src/supervisor.ts, tests/supervisor_pending_default.test.ts, tasks/T117/PLAN.md]
done_when: "bun test tests/supervisor_pending_default.test.ts tests/supervisor_restart_cooldown.test.ts tests/supervisor_exit_codes.test.ts tests/supervisor_idle_cooldown.test.ts tests/supervisor_iterations.test.ts tests/supervisor_heartbeat_running.test.ts tests/supervisor_heartbeat_pid.test.ts tests/supervisor_progress_effect.test.ts tests/serve_supervisor.test.ts tests/install/install_supervisor.test.ts"
tests_frozen: [tests/supervisor_pending_default.test.ts]
---
## Fazer
- `src/supervisor.ts`, `hasPending` (sem `opts.pendingCheck`): pendente se **qualquer** destes: (1) `<root>/.ginga/prompts/backlog-<repo>.md` tem linha `- [ ]` (regex `^- \[ \]`); (2) existe `<root>/.ginga/plans/*/ready/<repo>.json` (só o arquivo direto, não `ready/done/`); (3) `queueCommand` configurado e a fila indica pendência (lógica atual, inclusive "falhou ⇒ pendente"). Sem `queueCommand` e sem (1)/(2): **não pendente** (hoje devolve `true`).
- `pendingCheck` injetado continua mandando.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs. Se algum teste existente depender de "sem queueCommand ⇒ pendente", registre no log.md do PLAN e pare.

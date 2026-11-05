---
type: task
mode: padrao
goal: "ginga install instala contrib/systemd/ginga-supervisor.service em HOME falso; supervisor.ts emite evento coerente sem pendência"
title: install supervisor service + evento coerente
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-03-serve-supervisor]
tier: medium
pinga_task: T32
touch: [src/install/install.ts, src/supervisor.ts, contrib/systemd/ginga-supervisor.service, tests/install/install_supervisor.test.ts, tasks/T32/PLAN.md]
done_when: "bun test tests/install/install_supervisor.test.ts"
tests_frozen: [tests/serve_supervisor.test.ts, tests/install/install.test.ts]
---

## Fazer
- installCmd copia contrib/systemd/ginga-supervisor.service para ~/.config/systemd/user/ginga-supervisor.service.
- supervisor.ts:135 emite lane.round phase end coerente (reason no_pending) quando não há pendência.
## Não fazer
- Não tocar tests_frozen.

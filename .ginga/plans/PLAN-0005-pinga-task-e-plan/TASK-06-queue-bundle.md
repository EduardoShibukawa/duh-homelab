---
type: task
mode: padrao
goal: "pinga queue --json lista as TASK-*.md de PLANs approved com o status vindo do ledger e respeitando depends_on"
title: pinga queue enxerga o bundle
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T67
depends_on: [TASK-05-plan-verify]
tier: medium
touch: [src/queue.ts, tests/queue_bundle.test.ts]
done_when: "bun test tests/queue_bundle.test.ts tests/queue.test.ts"
tests_frozen: [tests/queue_bundle.test.ts]
---
## Fazer
- `scanQueue` também varre `<root>/.ginga/plans/*/TASK-*.md`, só de PLANs `status: approved`.
- Cada entrada ganha `plan`, `task` (ref) e `blocked_by` (deps sem `pass`). `--json` com `schema_version`.
## Não fazer
- Claim/lease não muda aqui (sai para o `ginga tick`, PLAN-0010). O legado `tasks/T*` continua.
## Contexto
- `src/queue.ts` (`scanQueue` l. 202, `sortTasks`, `nextTask`, `QueueEntry`).

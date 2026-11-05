---
type: task
mode: padrao
goal: "state.db guarda a execução e ginga events ingest consome $GINGA_EVENTS a partir do offset salvo, sem duplicar"
title: state.db + ingestão de eventos
plan: PLAN-0010-tick-serve-notifier
repo: ginga
depends_on: []
tier: medium
pinga_task: T19
touch: [src/state/db.ts, src/state/ingest.ts, src/cli.ts, tests/state_db.test.ts]
done_when: "bun test tests/state_db.test.ts"
tests_frozen: [tests/state_db.test.ts]
---
## Fazer
- `bun:sqlite` em `.ginga/state/state.db` (ou `GINGA_STATE_DB`); tabelas `task_exec(plan, task, status, attempts, lease_owner, lease_until)`, `events(id PK, ts, kind, plan, task, json)`, `offsets(path, byte)`, `plan_thread(plan, target, thread_id)`.
- `ginga events ingest`: lê do offset, valida com `src/events/validate.ts`, ignora `id` repetido, salva o novo offset.
## Não fazer
- Nunca reescrever o arquivo de eventos. Não guardar contrato (status de aprovação) no db.
## Contexto
- Doc 07 ("Transporte"); doc 04 §5 ("o arquivo guarda o contrato, o db guarda a execução").

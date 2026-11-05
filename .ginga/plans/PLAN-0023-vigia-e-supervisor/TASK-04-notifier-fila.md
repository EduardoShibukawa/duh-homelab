---
type: task
mode: padrao
goal: "notifier com fila durável: entrega pelo menos uma vez, o alert que falhou no envio volta na próxima conexão (retry + dedupe + digest), substituindo .ginga/bin/notify.sh"
title: fila durável do notifier (substitui o notify.sh)
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-02-watch-rules]
tier: medium
pinga_task: T31
touch: [src/notify/, src/state/db.ts, tests/notify_queue.test.ts, tasks/T31/PLAN.md]
done_when: "bun test tests/notify_queue.test.ts"
tests_frozen: [tests/notify_port.test.ts, tests/notify_thread_id.test.ts, tests/event_router.test.ts, tests/state_db.test.ts]
---
## Fazer
- Fila durável no state.db (tabela nova; migração no padrão do PLAN-0010): alertas/eventos entram na fila com dedupe_key + severidade; a cadeia Hermes → Discord → stdout do PLAN-0010 consome da fila com ack só após o envio; o que falhou fica na fila para a próxima conexão (retry; digest junta repetidos na mesma conexão).
- `ginga notify`/router passa a consumir da fila quando houver pendência nela (sem alterar a cadeia do PLAN-0010 quando a fila está vazia).
- Teste `tests/notify_queue.test.ts`: falha de envio mantém o item na fila (entrega com sucesso na próxima conexão), dedupe por key e digest de N itens num envio.
## Não fazer
- Não alterar a cadeia Hermes → Discord → stdout de TASK-04 do PLAN-0010 nem thread_id do TASK-07 (frozen); sem rede real no teste (socks fake/injectados como hoje).
## Contexto
- PLAN-0023 §Desenho camada 3; substitui .ginga/bin/notify.sh (TASK-06 corta).

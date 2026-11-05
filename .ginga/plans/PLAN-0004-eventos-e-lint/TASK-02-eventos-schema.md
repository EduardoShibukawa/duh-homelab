---
type: task
mode: padrao
goal: "Schema JSON do envelope v1, emissor O_APPEND sem efeito sem $GINGA_EVENTS e ginga events validate"
title: Schema v1, emissor e validador de eventos
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T2
depends_on: [TASK-01-ginga-repo]
tier: free
touch: [docs/events-v1.md, schemas/events-v1.json, src/events/emit.ts, src/events/validate.ts, src/cli.ts, tests/events.test.ts]
done_when: "bun test tests/events.test.ts"
tests_frozen: [tests/events.test.ts]
---
## Fazer
- `emitEvent(ev)`: sem `$GINGA_EVENTS` não escreve nada; com ele, 1 linha por `write()` com `O_APPEND`, < 4 KiB, `id` ULID, `ts` ISO.
- `validate`: obrigatórios `v,ts,source,kind,id`; `data` por `kind` da tabela do 07; campos desconhecidos são aceitos.
- `ginga events validate <arquivo>`: exit 1 e linha do erro se houver evento inválido.
## Não fazer
- Não publicar como lib para outros repos (o 07 é spec em documento).
## Contexto
- `.ginga/knowledge/design/ginga-revamp/07-eventos.md`; `pi-harness/src/harness/events.ts` (formato antigo).

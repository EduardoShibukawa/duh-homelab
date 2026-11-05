---
type: task
mode: mvp
goal: "appendEvent do pi-harness também emite o envelope v1 em $GINGA_EVENTS quando a variável existe"
title: pi-harness emite eventos v1
plan: PLAN-0004-eventos-e-lint
repo: pi-harness
pinga_task: T57
depends_on: [TASK-02-eventos-schema]
tier: free
touch: [src/harness/events.ts, tests/unit/harness_events_v1.test.ts]
done_when: "bun test tests/unit/harness_events_v1.test.ts"
tests_frozen: [tests/unit/harness_events_v1.test.ts]
---
## Fazer
- Em `appendEvent`, além do `state/events.jsonl` legado, escrever em `$GINGA_EVENTS` a mesma conversão da TASK-03 (implementação própria).
- Sem `$GINGA_EVENTS`: comportamento idêntico ao de hoje.
## Não fazer
- Não importar nada de `ginga/`. Não mudar o formato do `state/events.jsonl` legado.
## Contexto
- `src/harness/events.ts` (`EVENTS_PATH`, `serializeEvent`, `appendEvent`); escritores: `scripts/harness-task.ts`, `src/harness/record_claude_cost.ts`.

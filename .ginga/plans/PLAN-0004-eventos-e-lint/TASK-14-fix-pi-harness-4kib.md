---
type: task
mode: mvp
goal: "appendEvent recusa eventos com linha v1 de 4 KiB ou mais"
title: Fix do judge (rodada 5, achado 2)
plan: PLAN-0004-eventos-e-lint
repo: pi-harness
pinga_task: T60
depends_on: [TASK-13-fix-by-papel]
tier: free
touch: [src/harness/events.ts, tests/unit/harness_events_v1_fix2.test.ts]
done_when: "bun test tests/unit/harness_events_v1_fix2.test.ts tests/unit/harness_events_v1.test.ts tests/unit/harness_events_v1_fix.test.ts"
tests_frozen: [tests/unit/harness_events_v1_fix2.test.ts]
---
## Fazer
- `src/harness/events.ts` `appendEvent`: quando a linha serializada do envelope v1 (`toEnvelopeV1`) tem 4 KiB (4096 bytes) ou mais, o evento é recusado (não escrito) no alvo `$GINGA_EVENTS`, conforme `docs/events-v1.md:9` (linha < 4 KiB para ser atômica).
- O legado `state/events.jsonl` continua sendo escrito normalmente (não é afetado pelo limite).
- Testes RED do Planner em `tests/unit/harness_events_v1_fix2.test.ts` (frozen).
## Não fazer
- Não alterar testes frozen nem o formato do envelope v1.

---
type: task
mode: mvp
goal: "pi-harness emite eventos v1 com id ULID e que passam no validador v1"
title: Fix do judge — pi-harness emite eventos v1 com id ULID e que passam no vali
plan: PLAN-0004-eventos-e-lint
repo: pi-harness
pinga_task: T58
depends_on: [TASK-08-fix-validador]
tier: free
touch: [src/harness/events.ts, tests/unit/harness_events_v1_fix.test.ts]
done_when: "bun test tests/unit/harness_events_v1_fix.test.ts tests/unit/harness_events_v1.test.ts"
tests_frozen: [tests/unit/harness_events_v1_fix.test.ts]
---
## Fazer
- `id`: ULID (26 chars Crockford base32, regex `^[0-9A-HJKMNP-TV-Z]{26}$`), implementação própria; hoje é `crypto.randomUUID()` (`events.ts:75-78`).
- `verify` → `receipt` com `check: "bdd"` (sem `ledger_n`/`hash`, permitido pelo TASK-08).
- Testes RED já escritos pelo Planner em `tests/unit/harness_events_v1_fix.test.ts` (frozen).
## Não fazer
- Não importar de `ginga/`. Não alterar o teste frozen `harness_events_v1.test.ts`. Não mudar `state/events.jsonl` legado.
## Contexto
- Judge do PLAN-0004: UUID em vez de ULID; receipt sem ledger_n/hash; teste só checava length >= 16.

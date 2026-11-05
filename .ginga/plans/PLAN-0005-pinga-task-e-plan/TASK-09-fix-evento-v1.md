---
type: task
mode: mvp
goal: "Evento receipt do pinga usa id ULID e omite campos null, passando no validador v1"
title: Fix do judge (rodada 2)
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T70
depends_on: [TASK-08-fix-check-plan]
tier: free
touch: [src/events.ts, tests/receipt_events_v1.test.ts, tests/receipt_events.test.ts]
done_when: "bun test tests/receipt_events_v1.test.ts tests/receipt_events.test.ts tests/receipt_events_fix.test.ts"
tests_frozen: [tests/receipt_events_v1.test.ts, tests/receipt_events.test.ts]
---
## Fazer
- `id`: ULID (26 chars Crockford base32: 48 bits de tempo em ms + 80 bits aleatórios), implementação própria; hoje `randomBytes(12).toString("hex")` (`src/events.ts:21`).
- Omitir do envelope e do `data` as chaves com valor `null` (`reason_code` em `pass`, `repo` ausente).
- Testes RED já escritos pelo Planner em `tests/receipt_events_v1.test.ts` (frozen).
## Não fazer
- Não importar do `ginga/`. Não alterar os testes frozen (o Planner já alinhou `receipt_events.test.ts:86` ao v1: `reason_code` ausente, não `null`).
## Contexto
- Judge rodada 2 (Gemini flash + Codex): ids hex e `reason_code: null` falham em `ginga events validate`.

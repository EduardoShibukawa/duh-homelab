---
type: task
mode: mvp
goal: "Validador v1 exige ts ISO 8601 estrito e aceita receipt check: bdd sem ledger_n/hash"
title: Fix do judge — Validador v1 exige ts ISO 8601 estrito e aceita receipt chec
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T7
depends_on: [TASK-07-export-okf]
tier: free
touch: [src/events/validate.ts, tests/events_fix.test.ts, docs/events-v1.md]
done_when: "bun test tests/events_fix.test.ts tests/events.test.ts"
tests_frozen: [tests/events_fix.test.ts]
---
## Fazer
- `ts`: só ISO 8601 UTC com `Z` (`YYYY-MM-DDTHH:MM:SS(.sss)?Z`); hoje `Date.parse` aceita qualquer coisa (`validate.ts:194`).
- `check` aceita também `plan` (receipt de PLAN do pinga, PLAN-0005).
- `receipt` com `data.check: "bdd"`: `ledger_n` e `hash` opcionais (BDD do pi-harness não tem ledger). Demais checks continuam exigindo os dois.
- Testes RED já escritos pelo Planner em `tests/events_fix.test.ts` (frozen).
## Não fazer
- Não alterar `tests/events.test.ts` (frozen).
## Contexto
- Judge (Codex + Gemini flash) do PLAN-0004.

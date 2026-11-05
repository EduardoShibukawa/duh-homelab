---
type: task
mode: mvp
goal: "Um PLAN kind: investigation com TASKs de hipótese passa pelo pinga verify (TASK e PLAN) e gera learnings"
title: e2e de PLAN de investigação
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T145
depends_on: [TASK-03-handoff]
tier: free
touch: [tests/e2e/investigation.test.ts, tests/fixtures/investigation/]
done_when: "bun test tests/e2e/investigation.test.ts"
tests_frozen: [tests/e2e/investigation.test.ts, tests/fixtures/investigation/]
---
## Fazer
- Fixture: PLAN `kind: investigation` com TASK "reproduzir RED" (passa) e "hipótese A" (`done_when` que falha = descartada).
- `pinga verify` real em cada TASK e no PLAN; `LEARNINGS.md` com L-01 confirmada e L-02 descartada passa no lint; handoff lista a descartada primeiro.
## Interface
- Nenhuma nova: usa `pinga verify`, `ginga lint` e `buildHandoff`.
## Não fazer
- Não mudar o pinga (o caminho do verify é o do PLAN-0005 TASK-05).
## Contexto
- Doc 06 §3.

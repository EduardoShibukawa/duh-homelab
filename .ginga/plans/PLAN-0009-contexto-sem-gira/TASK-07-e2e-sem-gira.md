---
type: task
mode: mvp
goal: "Num repo git novo sem gira no PATH, INTENT vira PLAN e TASK, roda no Pi e passa no pinga verify, sem ginga"
title: e2e sem gira (Pi + pinga + manda)
plan: PLAN-0009-contexto-sem-gira
repo: manda
pinga_task: T153
depends_on: [TASK-05-context-rg, TASK-09-pi-resulttext]
tier: medium
touch: [tests/e2e/no_gira.test.ts, tests/e2e/stubs/pi, tasks/T153/PLAN.md]
done_when: "bun test tests/e2e/no_gira.test.ts"
tests_frozen: [tests/e2e/no_gira.test.ts, tests/e2e/stubs/pi]
---
## Fazer
- tmp repo com `.ginga/intents/INTENT-0001-x.md` e `project.toml` (`provider = "rg"`, `verify = "pinga verify {task} --root {repo}"`).
- `PATH` sem `gira` e sem `ginga`; stub de `pi` (planner e executor) no formato real; `pinga` real (`PINGA_BIN`).
- `manda plan` → `manda run` → receipt `pass` no ledger temporário (`--ledger`).
## Não fazer
- Sem modelos reais, sem ginga.
## Contexto
- Stubs da `tests/e2e/two_runtimes.test.ts` (PLAN-0007).

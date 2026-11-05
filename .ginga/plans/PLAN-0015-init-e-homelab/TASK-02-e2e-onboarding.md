---
type: task
mode: mvp
goal: "Num repo novo sem gira, ginga init + intent + tick levam uma TASK até o receipt pass do pinga"
title: e2e do onboarding sem gira
plan: PLAN-0015-init-e-homelab
repo: ginga
pinga_task: T129
depends_on: [TASK-01-ginga-init]
tier: medium
touch: [tests/e2e/onboarding_no_gira.test.ts, tests/stubs/]
done_when: "bun test tests/e2e/onboarding_no_gira.test.ts"
tests_frozen: [tests/e2e/onboarding_no_gira.test.ts]
---
## Fazer
- tmp git repo, `PATH` sem `gira`; `ginga init --yes` → `provider = "rg"`.
- `ginga intent new` → PLAN pré-gravado no fixture (`manda plan` com stub de `pi`) → `ginga approve` → `ginga tick` → `manda run` (stub de runtime) → `pinga verify` real com `--ledger` temporário → receipt `pass`.
## Não fazer
- Sem modelos reais e sem rede.
## Contexto
- `manda/tests/e2e/no_gira.test.ts` (PLAN-0009) para os stubs.

---
type: task
mode: mvp
goal: "Um PLAN com duas TASKs roda fora do Pi, cada uma num runtime diferente, e as duas passam no gate"
title: e2e com dois runtimes no mesmo PLAN
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T7
depends_on: [TASK-06-manda-run]
tier: medium
touch: [tests/e2e/two_runtimes.test.ts, tests/e2e/stubs/]
done_when: "bun test tests/e2e/two_runtimes.test.ts"
tests_frozen: [tests/e2e/two_runtimes.test.ts]
---
## Fazer
- Repo git temporário com `.ginga/plans/PLAN-0001-x/` (2 TASKs, `tier: free` e `medium`) e `project.toml` com `free = "pi"`, `medium = "opencode"`.
- Stubs `pi` e `opencode` no `PATH` que escrevem o arquivo do `touch` e imprimem saída no formato real.
- Asserções: dois `attempt` com `runtime` diferentes, os dois `passed: true`, nenhum processo do Pi como host.
## Não fazer
- Não chamar modelos reais.
## Contexto
- Fixtures de saída da TASK-03/04.

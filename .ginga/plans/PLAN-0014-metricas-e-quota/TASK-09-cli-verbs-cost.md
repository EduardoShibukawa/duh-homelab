---
type: task
mode: padrao
goal: "A cobertura pública da CLI inclui os verbos cost sync e cost, com paridade CLI×run direto e sem tocar no opencode.db real"
title: Cobertura CLI dos verbos de custo
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-07-custo-opencode-db]
tier: free
touch: [tests/cli_verbs.test.ts, tests/cost_cli_coverage.test.ts]
done_when: "bun test tests/cost_cli_coverage.test.ts tests/cli_verbs.test.ts"
tests_frozen: [tests/cost_cli_coverage.test.ts]
pinga_task: T353
---
## Fazer
- Acrescentar ao CASES de `tests/cli_verbs.test.ts` um caso para `cost sync` e outro para `cost`.
- O caso `cost sync` usa um SQLite temporário com o schema mínimo de `session_v2`/`session_message`; nunca o `opencode.db` real.
- Preservar a igualdade exata entre os verbos públicos e os casos, sem remover ou afrouxar testes.
## Interface
- `tests/cost_cli_coverage.test.ts` exige caso para os dois verbos públicos e roda junto do contrato CLI×run direto.
## Contexto
- A T348 adicionou `cost sync` e `cost` ao registro; a suíte ficou com 3 falhas em `tests/cli_verbs.test.ts` por falta dos casos.

---
type: task
mode: padrao
goal: "A cobertura pública da CLI inclui quota e valida a paridade CLI×run direto"
title: Cobertura CLI do verbo quota
plan: PLAN-0014-metricas-e-quota
repo: ginga
pinga_task: T355
depends_on: [TASK-03-quota-claude]
tier: free
touch: [tests/cli_verbs.test.ts, tests/quota_cli_coverage.test.ts]
done_when: "bun test tests/quota_cli_coverage.test.ts tests/cli_verbs.test.ts"
tests_frozen: [tests/quota_cli_coverage.test.ts]
---
## Fazer
- Acrescentar o caso `quota` ao contrato público de `tests/cli_verbs.test.ts`.
- Manter a paridade entre `ginga quota --json` e `runVerb("quota")`.

## Interface
- Teste novo: o verbo `quota` existe no registro e `tests/cli_verbs.test.ts` contém um caso para ele.

## Não fazer
- Não alterar o registro de verbos nem a implementação da quota.

## Contexto
- A TASK-03/T354 introduziu o verbo público `quota`; o gate exige cobertura por verbo.

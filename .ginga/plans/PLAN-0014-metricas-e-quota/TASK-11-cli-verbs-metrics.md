---
type: task
mode: padrao
goal: "O verbo público metrics entra no registro de verbos e a cobertura pública da CLI inclui metrics com paridade CLI×run direto"
title: Registro e cobertura CLI do verbo metrics
plan: PLAN-0014-metricas-e-quota
repo: ginga
pinga_task: T357
depends_on: [TASK-01-metricas]
tier: free
touch: [src/verbs/registry.ts, tests/cli_verbs.test.ts, tests/metrics_cli_coverage.test.ts]
done_when: "bun test tests/metrics_cli_coverage.test.ts tests/cli_verbs.test.ts"
tests_frozen: [tests/metrics_cli_coverage.test.ts]
---
## Fazer
- Registrar `{ name: "metrics", args: [arg("since")], write: false, run: read.metrics }` em `src/verbs/registry.ts` (o export `metrics` já existe em `src/verbs/read.ts` desde a T356).
- Acrescentar o caso `metrics: { argv: ["metrics"], args: {} }` ao contrato público de `tests/cli_verbs.test.ts`.
- Manter a paridade entre `ginga metrics --json` e `runVerb("metrics")`.

## Interface
- Teste novo: o verbo `metrics` existe no registro e `tests/cli_verbs.test.ts` contém um caso para ele.

## Não fazer
- Não alterar `src/metrics.ts` nem `src/verbs/read.ts` (já entregues pela TASK-01/T356).

## Contexto
- A TASK-01/T356 entregou `computeMetrics` e o export `metrics` em read.ts, mas o touch dela não inclui `src/verbs/registry.ts`; sem o registro o verbo não existe na CLI. Segue o precedente TASK-09/TASK-10 (cobertura pública em TASK própria sem tocar no frozen alheio nem replan do touch).

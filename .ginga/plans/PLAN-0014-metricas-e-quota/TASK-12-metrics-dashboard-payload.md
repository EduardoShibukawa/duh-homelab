---
type: task
mode: padrao
goal: "ginga metrics --json entrega ao dashboard o número de execuções, a taxa de falha, o custo por SPEC/PLAN/TASK e as métricas do vigia"
title: Payload do dashboard de métricas
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-01-metricas, TASK-04-erros-repetidos, TASK-08-metricas-vigia]
tier: free
pinga_task: T360
touch: [src/metrics.ts, src/metrics_alerts.ts, src/verbs/read.ts, tests/metrics_dashboard_payload.test.ts]
done_when: "bun test tests/metrics_dashboard_payload.test.ts"
tests_frozen: [tests/metrics_dashboard_payload.test.ts]
---
## Fazer
- `executions` conta eventos `attempt`; `failure_rate` = tentativas com `failure` / `executions`.
- `cost_by` agrega eventos `cost` por SPEC (relação do frontmatter do PLAN), PLAN e TASK (`PLAN/TASK`).
- `read.metrics` recebe `root`, inclui `repeated_errors` e junta `alert_metrics` da TASK-08.
## Interface
- `computeMetrics(db, {since?, root?})` devolve também `executions`, `failure_rate` e `cost_by: {spec,plan,task}`.
- `metrics(ctx, args)` devolve o payload com `alert_metrics: RuleMetrics[]`.
## Não fazer
- Não alterar os contratos frozen de `tests/metrics.test.ts`, `tests/metrics_repeat.test.ts` ou `tests/metrics_alerts.test.ts`.
## Contexto
- Correção do PLAN-0014 TASK-05: a tela precisa de dados que `ginga metrics` ainda não expunha.

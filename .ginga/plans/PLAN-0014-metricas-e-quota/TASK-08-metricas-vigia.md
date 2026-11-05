---
type: task
mode: mvp
goal: "ginga metrics inclui, por regra do vigia, a contagem de alertas, os abertos, o MTTR e o custo por alerta"
title: Métricas do vigia (SPEC-0003)
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-01-metricas]
pinga_task: T359
tier: free
touch: [src/metrics_alerts.ts, tests/metrics_alerts.test.ts, tests/fixtures/metrics-alerts.jsonl]
done_when: "bun test tests/metrics_alerts.test.ts"
tests_frozen: [tests/metrics_alerts.test.ts, tests/fixtures/metrics-alerts.jsonl]
---
## Fazer
- Para cada `alert`: resolvido = primeiro `receipt` `pass` ou `transition` para `done` da mesma entidade (`plan`/`task`) depois dele; MTTR da regra = média dos minutos até a resolução (sem resolvidos → `null`); sem resolução → conta em `open`.
- Custo por alerta = soma dos eventos `cost` da entidade entre o alerta e a resolução (ou até agora, se aberto).
## Interface
- `alertMetrics(db, {since})` → `RuleMetrics[]` (PLAN.md), ordenado por `count` desc. Teste: fixture com 3 alertas de `infra_stuck` (2 resolvidos em 10 e 30 min, 1 aberto) e 1 de `budget_cap` → `infra_stuck: count 3, open 1, mttr_min 20`.
## Não fazer
- Não mudar `src/metrics.ts` (a tela junta as duas saídas).
## Contexto
- SPEC-0003 §Ações ("Métricas mostram contagem por regra, MTTR e custo por alerta").

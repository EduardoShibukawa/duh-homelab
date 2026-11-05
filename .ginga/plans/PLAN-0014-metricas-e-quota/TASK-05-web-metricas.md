---
type: task
mode: mvp
goal: "A Roda Web mostra as telas Métricas e Quota a partir de ginga metrics e ginga quota"
title: Telas Métricas e Quota
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-03-quota-claude, TASK-04-erros-repetidos, TASK-08-metricas-vigia, TASK-12-metrics-dashboard-payload]
tier: free
pinga_task: T361
touch: [src/web/render/metrics.ts, src/web/render/quota.ts, web/metrics.js, tests/web_metrics.test.ts]
done_when: "bun test tests/web_metrics.test.ts"
tests_frozen: [tests/web_metrics.test.ts]
---
## Fazer
- KPIs: execuções, taxa de falha, FTPR, custo pago, custo por TASK ok, escaladas, erros repetidos; falhas por motivo; custo por SPEC/PLAN/TASK.
- Vigia: tabela por regra (contagem, abertos, MTTR, custo por alerta) de `alertMetrics`.
- Quota: uma linha por provider (janela, uso, reseta, fonte), "manual" quando for o caso.
- Cada gráfico com tabela alternativa (acessibilidade).
## Interface
- `renderMetrics(m: Metrics, rules: RuleMetrics[]): string` e `renderQuota(q: Quota[]): string` (puras). Teste: cada KPI tem `data-kpi`, cada gráfico SVG tem uma `<table>` irmã com os mesmos números.
## Não fazer
- Sem lib de gráfico pesada (SVG inline).
## Contexto
- Protótipo `knowledge/design/ginga-revamp/prototipos/Metricas.dc.html`; doc 05 §3.5.

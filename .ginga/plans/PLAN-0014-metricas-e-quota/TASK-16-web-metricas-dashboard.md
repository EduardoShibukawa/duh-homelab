---
type: task
mode: padrao
goal: "A UI real web/metrics.js exibe o dashboard completo: falhas por motivo (failures_by_reason) com gráfico SVG e tabela irmã, custo por SPEC/PLAN/TASK (cost_by) e FTPR, além dos KPIs e da tabela do vigia que já monta"
title: Dashboard real de Métricas na casca web
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-05-web-metricas, TASK-13-web-metricas-ligadas, TASK-12-metrics-dashboard-payload]
tier: free
pinga_task: T365
touch: [web/metrics.js, tests/web_metrics_dashboard.test.ts]
done_when: "bun test tests/web_metrics_dashboard.test.ts tests/web_metrics.test.ts tests/web_metrics_wired.test.ts"
tests_frozen: [tests/web_metrics_dashboard.test.ts]
---
## Fazer
- Achado grave do judge 2026-11-03T04:05 (gate 11 no PLAN-0014): `web/metrics.js` monta só KPIs, tabela vigia e quota; não exibe `failures_by_reason` nem `cost_by`, e não usa os renderers puros.
- Adicione a `web/metrics.js` renderers puros exportados `renderMetricsHtml(metrics)` e `renderQuotaHtml(quotas)` (strings HTML, espelho de `src/web/render/metrics.ts`/`quota.ts` — o navegador não importa TS, então o módulo precisa das próprias funções puras) e faça `mountMetrics`/`mountQuota` montarem por eles (ex.: `host.innerHTML = renderMetricsHtml(payload)`), mantendo as assinaturas e os atributos `data-metrics`/`data-quota`/`data-kpi`/`data-vigia`/`data-rule`/`data-provider` já usados.
- O HTML de métricas deve trazer: KPIs com `data-kpi`, gráfico SVG `data-chart="failures"` de `failures_by_reason` dentro de `<figure>` com `<table>` irmã com os mesmos números, tabela FTPR por escopo, seções `data-cost-by="spec|plan|task"` com as linhas de `cost_by`, e a tabela do vigia por regra.
- Não mude `fetchMetrics`/`fetchQuota`/`initMetrics` (tests/web_metrics.test.ts é frozen) nem o `nav data-view="inbox|board|plan"` de web/index.html (web_shell_casca.test.ts é frozen).
## RED
- `tests/web_metrics_dashboard.test.ts` (novo, seu): importa `../web/metrics.js` e falha antes da mudança — `renderMetricsHtml` não existe e o fonte de `web/metrics.js` não referencia `failures_by_reason`/`cost_by`; depois passa com SVG+tabela irmã, `data-cost-by` SPEC/PLAN/TASK e `mountMetrics` num host stub.
## Não fazer
- Sem lib de gráfico (SVG inline) e sem tocar em `tests_frozen` alheio (`tests/web_metrics.test.ts`, `tests/web_metrics_wired.test.ts`).
## Contexto
- Correção do AC-dashboard-metricas/TASK-05 reprovados pelo judge: os renderers de `src/web/render/metrics.ts` passam no teste, mas a UI real servida (`web/metrics.js`) não os usa.

---
type: task
mode: mvp
goal: "Ligar as telas Métricas e Quota na casca real da Roda Web: VIEWS em web/app.js inclui metrics e quota; web/index.html inclui script /metrics.js, links de nav data-view=metrics/quota e seções view-metrics/view-quota com os hosts [data-metrics] e [data-quota]"
title: Ligar Métricas/Quota na casca web
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-05-web-metricas]
tier: free
pinga_task: T362
touch: [web/app.js, web/index.html, web/metrics.js, tests/web_metrics_wired.test.ts]
done_when: "bun test tests/web_metrics_wired.test.ts"
tests_frozen: [tests/web_metrics_wired.test.ts]
---
## Fazer
- Achado grave do judge 2026-11-03T00:38 (gate 11 no PLAN-0014): `renderMetrics`/`renderQuota` e `web/metrics.js` existem (TASK-05/T361), mas a casca não liga as telas — `web/app.js:6` VIEWS sem metrics/quota; `web/index.html` sem `<script src="/metrics.js">`, sem nav e sem os hosts.
- Adicione `"metrics"` e `"quota"` ao `VIEWS` de `web/app.js`; no `web/index.html` adicione o script do módulo, os links `href="#metrics"`/`href="#quota"` com `data-view` na nav existente, e `<section id="view-metrics" data-view="metrics" ... hidden>` com `<div class="panel" data-metrics>` e o análogo `view-quota`/`[data-quota]` dentro de `<main>`.
- `web/metrics.js` já monta via `initMetrics` quando os hosts existem; toque nele só se necessário.
- **Não mude** o atributo `nav data-view="inbox|board|plan"` (o frozen `tests/web_shell_casca.test.ts` afirma essa string) nem nenhum teste alheio.
## RED
- `tests/web_metrics_wired.test.ts` lê os arquivos REAIS `web/app.js` e `web/index.html` e falha antes da ligação (VIEWS sem metrics/quota; index.html sem script metrics.js, sem nav metrics/quota e sem os hosts nas seções).

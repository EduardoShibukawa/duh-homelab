---
type: task
mode: padrao
goal: "Alertas de ponta a ponta: deriveBoard emite itens alerta no Inbox, verbo alerts no registro com filtro por severidade, e a Roda Web monta o painel (nav, view, web/alerts.js via /v1/verbs/alerts + SSE)"
title: Painel de alertas ligado de ponta a ponta (follow-up do judge na TASK-09)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-09-painel-alertas]
tier: free
touch: [src/board.ts, src/verbs/read.ts, src/verbs/registry.ts, web/app.js, web/index.html, web/alerts.js, tests/cli_verbs.test.ts, tests/alertas_e2e.test.ts, tests/web_alerts_js.test.ts]
done_when: "bun test tests/alertas_e2e.test.ts tests/web_alerts_js.test.ts tests/cli_verbs.test.ts tests/board.test.ts tests/web_alerts.test.ts tests/web_shell_casca.test.ts"
tests_frozen: [tests/alertas_e2e.test.ts, tests/web_alerts_js.test.ts]
pinga_task: T334
---
## Context
- Judge 2026-11-01T221449 (grave, TASK-09 / AC-SPEC0003): deriveBoard não emite itens `alerta` no Inbox; nenhum verbo lista alertas; web/app.js e web/index.html não montam o painel (web/alerts.js só exporta helpers de filtro).
## Interface
- Inbox (src/board.ts): para cada evento kind=alert do state.db, item { id, type: "alerta", entity, title: summary, severity, plan?, actions: [] }.
- Verbo `alerts` (read.ts + registry, args: [sev]): runVerb("alerts", ctx, {}) → { items: Alert[] } (src/alerts.ts listAlerts); { sev: "high" } → severidade mínima. 1 linha a mais em CASES de tests/cli_verbs.test.ts (a cobertura exige 1 caso por verbo; precedente T331).
- Web: index.html ganha link nav data-view="alerts" + seção view-alerts com [data-alerts]/[data-alerts-list] (o atributo `nav data-view="inbox|board|plan"` não muda — frozen T329); app.js VIEWS ganha "alerts"; web/alerts.js monta o painel: POST /v1/verbs/alerts com sev da URL (?sev=), linhas com data-severity, [data-count], re-lê no evento SSE ginga:event; helpers minSeverityFromSearch/filterBySeverity continuam exportados.
## Não fazer
- Não quebrar os frozen: tests/web_shell_casca.test.ts, tests/web_alerts.test.ts, tests/board.test.ts; em cli_verbs.test.ts só o +1 caso do verbo alerts.

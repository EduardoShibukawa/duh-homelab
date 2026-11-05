---
type: task
mode: mvp
goal: "A Roda Web mostra os alertas do vigia com filtro por severidade, e o Inbox inclui os high e critical"
title: Painel de alertas por severidade
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-03-inbox, TASK-08-status-json]
tier: free
touch: [src/web/render/alerts.ts, src/web/render/inbox.ts, web/alerts.js, tests/web_alerts.test.ts]
done_when: "bun test tests/web_alerts.test.ts"
tests_frozen: [tests/web_alerts.test.ts]
pinga_task: T328
---
## Fazer
- Tela Alertas: lista de `listAlerts(db)` com `rule_id`, severidade, entidade, resumo e hora; filtro `?sev=critical|high|warn|info` (mostra a severidade escolhida e as acima).
- No Inbox, alertas `high`/`critical` viram itens `type: "alerta"` com o link do PLAN.
## Interface
- `renderAlerts(alerts: Alert[], minSeverity?: Alert["severity"]): string` (pura). Cada linha tem `data-severity`.
- Teste: 4 alertas (um de cada severidade) com `minSeverity: "high"` → 2 linhas; `renderInbox` com 1 alerta `critical` → item com `data-type="alerta"`.
## Não fazer
- Sem árvore de spans/traces (lacuna 8). Sem ações de correção (o vigia já age pelos verbos).
## Contexto
- SPEC-0003 §Ações ("Painéis da Roda"); `src/watch/evaluate.ts` (quem emite `alert`).

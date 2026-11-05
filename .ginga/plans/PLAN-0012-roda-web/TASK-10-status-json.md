---
type: task
mode: padrao
goal: "ginga status --json devolve o estado do harness (pendências do dono, PLANs com TASKs/tentativas/custo, alertas por severidade, fontes quebradas) e substitui o MCP harness_status"
title: ginga status --json (frozen corrigido; substitui TASK-08/T161 superseded)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-01-board-model, TASK-06-index-gerado]
tier: medium
touch: [src/status.ts, src/alerts.ts, src/verbs/read.ts, src/cli.ts, tests/status_json.test.ts]
done_when: "bun test tests/status_json.test.ts"
tests_frozen: [tests/status_json.test.ts]
pinga_task: T323
---
## Fazer
- Implementar `buildStatus(root, db, now)` e `listAlerts(db, { minSeverity?, since? })`
  conforme as interfaces do PLAN.md ("Interfaces"): `owner` = `deriveBoard(root, db).inbox`;
  `plans` = um por PLAN não `superseded`, com `tasks` do `task_exec`, `attempts` e
  `cost_usd` somados dos eventos `attempt` (campo `data.cost_usd`); `alerts` =
  contagem por severidade nas últimas 24 h; `broken_sources` = fontes que falharam
  (ex.: `$GINGA_EVENTS` para arquivo inexistente), sem abortar.
- O verbo `status` devolve `buildStatus(...)`.
## Por que existe (TASK-08/T161 foi superseded)
- O frozen de T161 era incompatível com o schema real do state.db: fazia
  `CREATE TABLE IF NOT EXISTS task_exec(... plan_id ... cost_usd ...)` depois que
  `openStateDb` já criara a tabela com `PRIMARY KEY (plan, task)` — o INSERT falhava
  antes de carregar `src/status.ts`, e `src/state/db.ts` está fora do touch.
  O teste frozen desta TASK foi reescrito contra o schema real (task_exec com
  (plan, task, status, attempts); eventos com o envelope inteiro em `json`).
## Interface
- Tipos `Status` e `Alert` no PLAN.md ("Interfaces"). `schema_version: 1` fixo.
- Teste (frozen, já escrito): fixture com 1 PLAN draft (vira `owner` "aprovar"),
  3 TASKs no `task_exec` (1 pass, 2 open), 3 eventos `attempt` (custo 0 + 0,02 + 0,01),
  3 alertas (critical, warn dentro da janela; info antiga fora), `$GINGA_EVENTS`
  inexistente → `broken_sources` com 1 item e sem abortar; relógio fixo.
## Não fazer
- Não chamar LLM nem rede; não gravar nada; não tocar em `src/state/db.ts`
  (o schema é outro TASK); não alterar os testes frozen.
## Contexto
- MCP `harness_status` do pi-harness; PLAN-0017 TASK-04; `src/board.ts` (deriveBoard).

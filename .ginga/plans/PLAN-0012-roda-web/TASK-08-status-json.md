---
type: task
mode: padrao
goal: "ginga status --json devolve o estado do harness (pendências do dono, PLANs com TASKs/tentativas/custo, alertas por severidade, fontes quebradas) e substitui o MCP harness_status"
title: ginga status --json
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-01-board-model, TASK-06-index-gerado]
tier: medium
touch: [src/status.ts, src/alerts.ts, src/verbs/read.ts, tests/status_json.test.ts, tests/fixtures/status/]
done_when: "bun test tests/status_json.test.ts"
tests_frozen: [tests/status_json.test.ts, tests/fixtures/status/]
---
## Fazer
- `buildStatus(root, db, now)` (tipo `Status` no PLAN.md): `owner` = `deriveBoard(...).inbox`; `plans` = um por PLAN não `superseded`, com `tasks` do `task_exec`, `attempts` e `cost_usd` somados dos eventos `attempt`/`cost`; `alerts` = contagem por severidade de `listAlerts(db)` nas últimas 24 h; `broken_sources` = fontes que falharam ao ler (`state.db`, `pinga queue --json`, `$GINGA_EVENTS`), com o erro, sem abortar.
- `listAlerts(db, {minSeverity, since})` lê os eventos `kind = 'alert'` do `state.db`, ordenados por `ts` desc.
- O verbo `status` passa a devolver `buildStatus` (a CLI já imprime JSON com `--json`).
## Interface
- Tipos `Status` e `Alert` no PLAN.md ("Interfaces"). `schema_version: 1` fixo; campos novos só por replan.
- Teste: fixture com 1 PLAN draft (vira `owner` "aprovar"), 1 PLAN approved com 3 TASKs (1 pass, 1 com 2 tentativas, custo 0,03), 2 alertas (`critical`, `warn`) e `$GINGA_EVENTS` apontando para arquivo inexistente → `broken_sources` com 1 item e exit 0. Relógio fixo → saída idêntica.
## Não fazer
- Não chamar LLM nem rede; não gravar nada.
## Contexto
- MCP `harness_status` do pi-harness (o que ele mostra: o que precisa do dono, frentes, tentativas, custo, quarentena, fontes quebradas); PLAN-0017 TASK-04.

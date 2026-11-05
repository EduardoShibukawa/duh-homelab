
### 04:06 PLAN-0014-metricas-e-quota · ginga · plan/0014 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 636fa422 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0014-metricas-e-quota/judge/ginga-20261103T040522.log)
  - FALHA [AC-dashboard-metricas] web/metrics.js:56-92 monta só KPIs, tabela vigia e quota; não exibe failures_by_reason nem cost_by; renderMetrics/renderQuota (src/web/render/metrics.ts) não são usados por web/ nem src (grep)
  - FALHA [TASK-05] src/web/render/metrics.ts tem SVG+table e passa o teste, mas a UI real web/metrics.js não os usa e omite falhas por motivo e custo por SPEC/PLAN/TASK
  - ok [AC-quota-automatica] src/quota/index.ts:79-91 readQuotas (claude, codex, gemini-pro/opencode-go manual, zen opencode-db); web/metrics.js:94-108 exibe
  - ok [AC-AB-e-erros-repetidos] src/bench/store.ts, src/bench/handoff_ab.ts, src/metrics_repeat.ts; repeated_errors em KPI web/metrics.js:66
  - ok [AC-SPEC0003] src/metrics_alerts.ts; src/metrics.ts:243 exclui quota_exhausted/infra do FTPR; read.ts metrics junta alert_metrics
  - ok [TASK-01] src/metrics.ts computeMetrics; tests/metrics.test.ts passa
  - ok [TASK-02] src/quota/codex.ts; tests/quota_codex.test.ts passa
  - ok [TASK-03] contrib/claude-statusline.sh, src/quota/claude.ts, src/quota/index.ts, registry.ts:56 quota; README com instrução; ignora seven_day (simples)
  - ok [TASK-04] src/metrics_repeat.ts repeatedErrors; metrics.ts repeated_errors
  - ok [TASK-06] src/bench/store.ts:38 bench.db; src/bench/handoff_ab.ts; tests/bench_handoff_ab.test.ts passa
  - ok [TASK-07] src/cost/opencode_db.ts, src/verbs/cost.ts, registry.ts:54-55
  - ok [TASK-08] src/metrics_alerts.ts alertMetrics; tests/metrics_alerts.test.ts passa
  - ok [TASK-09] tests/cli_verbs.test.ts casos 'cost sync' e 'cost' com SQLite temporário; tests/cost_cli_coverage.test.ts
  - ok [TASK-10] tests/cli_verbs.test.ts caso quota; tests/quota_cli_coverage.test.ts
  - ok [TASK-11] src/verbs/registry.ts:57 metrics; caso metrics em tests/cli_verbs.test.ts
  - ok [TASK-12] src/metrics.ts executions/failure_rate/cost_by; src/verbs/read.ts:101-107 metrics com root e alert_metrics
  - ok [TASK-13] web/app.js:6 VIEWS com metrics/quota; web/index.html script /metrics.js, nav e seções com [data-metrics]/[data-quota]
  - ok [TASK-14] README.md seção 'Statusline do Claude (quota)' cita contrib/claude-statusline.sh e ~/.claude/settings.json
  - ok [TASK-15] src/quota/index.ts:25 quotaCapOk; src/tick.ts:595 cap_ok: quotaCapOk(readQuotas(...))
- resumo do judge: Suíte 806/0; as 15 TASKs ginga têm código e testes, sem regressão. Reprova a TASK-05 e o AC do dashboard: a UI real (web/metrics.js) não mostra falhas por motivo nem custo por SPEC/PLAN/TASK nem gráficos SVG com tabela alternativa, e os renderers puros de src/web/render não estão ligados a ela.

### 05:36 PLAN-0014-metricas-e-quota · ginga · plan/0014 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD a0c2b337 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0014-metricas-e-quota/judge/ginga-20261103T053516.log)
  - FALHA [TASK-07] src/cost/opencode_db.ts syncCost grava ts=new Date() (hora do sync) em vez de session.created. Reproduzido: sessão de 2026-10-05 com US$40 vira evento de 2026-11-03, readQuotas devolve zen used_pct=400, quotaCapOk fica false e src/tick.ts:595 para de despachar. Também distorce ginga cost por dia (sr
  - FALHA [AC] Dashboard e quota lidos automaticamente estão implementados, mas o custo vindo do opencode.db entra com data de sync. A quota do zen e o cap_ok do tick ficam errados após o primeiro sync de histórico (src/cost/opencode_db.ts syncCost). Custo por TASK/PLAN/SPEC também não enxerga o custo importado (p
  - ok [TASK-01] src/metrics.ts:215-240 FTPR exclui quota_exhausted/infra; cost de evento vence attempt.cost_usd (l.262-275); tests/metrics.test.ts passa. Limitação: eventos cost importados do opencode.db têm plan/task nulos, então só entram em spent_usd
  - ok [TASK-02] src/quota/codex.ts readCodexQuota; tests/quota_codex.test.ts passa
  - ok [TASK-03] src/quota/index.ts:84-92 readQuotas (claude, codex, 2 manual, zen); contrib/claude-statusline.sh; tests/quota.test.ts passa. O used_pct do zen herda o ts errado da TASK-07
  - ok [TASK-04] src/metrics_repeat.ts repeatedErrors; src/metrics.ts:288-293 repeated_errors; tests/metrics_repeat.test.ts passa
  - ok [TASK-05] src/web/render/metrics.ts e quota.ts; tests/web_metrics.test.ts passa
  - ok [TASK-06] src/bench/store.ts e handoff_ab.ts; tests/bench_handoff_ab.test.ts passa
  - ok [TASK-08] src/metrics_alerts.ts alertMetrics; tests/metrics_alerts.test.ts passa
  - ok [TASK-09] src/verbs/registry.ts:54-55 cost sync/cost; tests/cost_cli_coverage.test.ts e tests/cli_verbs.test.ts passam
  - ok [TASK-10] src/verbs/registry.ts:56 quota; tests/quota_cli_coverage.test.ts passa
  - ok [TASK-11] src/verbs/registry.ts:57 metrics com arg since; tests/metrics_cli_coverage.test.ts passa
  - ok [TASK-12] src/verbs/read.ts:101-107 metrics junta computeMetrics com root e alert_metrics; tests/metrics_dashboard_payload.test.ts passa
  - ok [TASK-13] web/app.js:6 VIEWS com metrics/quota; web/index.html tem script /metrics.js, nav e seções com [data-metrics]/[data-quota]; tests/web_metrics_wired.test.ts passa
  - ok [TASK-14] README.md seção 'Statusline do Claude (quota)' cita contrib/claude-statusline.sh e ~/.claude/settings.json; tests/readme_statusline.test.ts passa
  - ok [TASK-15] src/quota/index.ts:23-32 quotaCapOk; src/tick.ts:595 cap_ok alimentado por readQuotas; tests/quota_cap.test.ts passa
  - ok [TASK-16] web/metrics.js renderMetricsHtml/renderQuotaHtml, SVG data-chart=failures com tabela irmã, data-cost-by; tests/web_metrics_dashboard.test.ts passa
- resumo do judge: Suíte completa verde (812 pass, 0 fail) e sem regressão. Todas as 16 TASKs ginga estão implementadas e ligadas, mas a TASK-07 grava os eventos cost com o ts da hora do sync, não o da sessão. Isso faz o custo histórico cair no mês corrente, infla a quota do zen (reproduzido 400%) e pode travar o tick via quotaCapOk. Eventos cost importados também não têm plan/task, então cost_by e o custo por TASK 

### 14:45 PLAN-0014-metricas-e-quota · ginga · plan/0014 · gate 0
- motivo: mergeado 2c5f516
- judge: pass no HEAD 0a38eb38 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0014-metricas-e-quota/judge/ginga-20261103T144316.log)
  - ok [TASK-01] src/metrics.ts:243 exclui quota_exhausted/infra do FTPR; tests/metrics.test.ts passa; verbo metrics registrado em src/verbs/registry.ts
  - ok [TASK-02] src/quota/codex.ts readCodexQuota, emitEvent quota (l.150), unavailableQuota (l.118); tests/quota_codex.test.ts passa
  - ok [TASK-03] src/quota/index.ts readQuotas (claude+codex automáticos, gemini-pro/opencode-go manual, zen opencode-db); contrib/claude-statusline.sh; src/verbs/quota.ts; tests/quota.test.ts passa
  - ok [TASK-04] src/metrics_repeat.ts repeatedErrors; metrics.ts expõe repeated_errors; tests/metrics_repeat.test.ts passa
  - ok [TASK-05] src/web/render/metrics.ts e quota.ts renderMetrics/renderQuota; tests/web_metrics.test.ts passa
  - ok [TASK-06] src/bench/store.ts e handoff_ab.ts (braços native-compact/ginga-handoff, l.78); tests/bench_handoff_ab.test.ts passa
  - ok [TASK-07] src/cost/opencode_db.ts readOpencodeSessions readonly, syncCost idempotente com ts=session.created (l.179); verbos cost sync/cost em registry.ts; tests/cost_opencode_db.test.ts e cost_sync_ts.test.ts passam
  - ok [TASK-08] src/metrics_alerts.ts alertMetrics (count/open/mttr/cost); tests/metrics_alerts.test.ts passa
  - ok [TASK-09] tests/cli_verbs.test.ts casos 'cost sync' e 'cost' com sqlite temporário; tests/cost_cli_coverage.test.ts passa
  - ok [TASK-10] tests/cli_verbs.test.ts caso quota; tests/quota_cli_coverage.test.ts passa
  - ok [TASK-11] src/verbs/registry.ts registra metrics com arg since; caso metrics em cli_verbs.test.ts; tests/metrics_cli_coverage.test.ts passa
  - ok [TASK-12] src/verbs/read.ts metrics junta computeMetrics(root) + alert_metrics; executions/failure_rate/cost_by em src/metrics.ts; tests/metrics_dashboard_payload.test.ts passa
  - ok [TASK-13] web/app.js:6 VIEWS com metrics/quota; web/index.html:14,43-46,136-157 script, nav e hosts data-metrics/data-quota; tests/web_metrics_wired.test.ts passa
  - ok [TASK-14] README.md:10-21 seção Statusline do Claude cita claude-statusline.sh e ~/.claude/settings.json; tests/readme_statusline.test.ts passa
  - ok [TASK-15] src/tick.ts usa quotaCapOk(readQuotas(...)) no lugar do stub; src/quota/index.ts:25 quotaCapOk; tests/quota_cap.test.ts, tick_plan e tick passam
  - ok [TASK-16] web/metrics.js:139 renderMetricsHtml, :188 renderQuotaHtml, data-chart=failures com figure+table, data-cost-by; tests/web_metrics_dashboard.test.ts passa
  - ok [TASK-17] src/cost/opencode_db.ts:179 ts=session.created e planTaskForDirectory/resolve; src/verbs/cost.ts passa resolve; tests/cost_sync_ts.test.ts passa
  - ok [TASK-18] resets_at epoch (s/ms) normalizado para ISO em src/quota/codex.ts e claude.ts; tests/quota_resets_epoch.test.ts passa
  - ok [AC] Dashboard (web/metrics.js + index.html + serve.ts estático) mostra FTPR, custo por TASK, falhas por motivo, quota; codex/claude automáticos, gemini-pro/opencode-go manual (src/quota/index.ts); ontologia de bench + erros repetidos no payload; vigia por regra/MTTR/custo e FTPR sem quota/infra; 822 tes
- resumo do judge: Todas as 18 TASKs do ginga e os ACs estão cumpridos em HEAD: a suíte completa dá 822 pass e 0 fail. O diff contra a main é aditivo, sem regressão. Os achados graves anteriores (ligação da web, ts do custo, resets_at em epoch, cap_ok do tick, README) estão corrigidos.

### 20:09 PLAN-0035-bytecode-fora-do-git · ginga · plan/0035 · gate 2
- motivo: conflito no merge
- judge: pass no HEAD 8a552f60 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0035-bytecode-fora-do-git/judge/ginga-20261103T200752.log)
  - ok [AC] tests/no_tracked_bytecode.test.ts:6-11 passa (bun test: 1 pass, 0 fail); git ls-files não lista .pyc/__pycache__; .gitignore:1-2 ignora __pycache__/ e *.pyc
  - ok [TASK-368] git diff main...HEAD: contrib/hermes-plugin/__pycache__/__init__.cpython-314.pyc removido do índice (10251 -> 0 bytes), teste congelado adicionado em tests/no_tracked_bytecode.test.ts, tasks/T368/PLAN.md com touch e tests_frozen coerentes; nenhuma referência restante ao .pyc no repo
- resumo do judge: O .pyc rastreado saiu do git via git rm --cached, o teste congelado passa em HEAD e o diff só toca os 3 arquivos previstos no touch da T368. Sem regressão.

### 20:10 PLAN-0035-bytecode-fora-do-git · ginga · plan/0035 · gate 0
- motivo: mergeado 44c62cc
- judge: pass no HEAD 8a552f60 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0035-bytecode-fora-do-git/judge/ginga-20261103T200752.log)
  - ok [AC] tests/no_tracked_bytecode.test.ts:6-11 passa (bun test: 1 pass, 0 fail); git ls-files não lista .pyc/__pycache__; .gitignore:1-2 ignora __pycache__/ e *.pyc
  - ok [TASK-368] git diff main...HEAD: contrib/hermes-plugin/__pycache__/__init__.cpython-314.pyc removido do índice (10251 -> 0 bytes), teste congelado adicionado em tests/no_tracked_bytecode.test.ts, tasks/T368/PLAN.md com touch e tests_frozen coerentes; nenhuma referência restante ao .pyc no repo
- resumo do judge: O .pyc rastreado saiu do git via git rm --cached, o teste congelado passa em HEAD e o diff só toca os 3 arquivos previstos no touch da T368. Sem regressão.

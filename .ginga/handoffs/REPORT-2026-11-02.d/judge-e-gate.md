
### 00:59 PLAN-0012-roda-web · ginga · plan/0012 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD ea576860 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0012-roda-web/judge/ginga-20261102T005752.log)
  - FALHA [TASK-02] src/serve.ts:301-317 o fallback serve lê join(base,'web') onde base é o --root/cwd (src/serve.ts:276), não o web/ da instalação do ginga; num workspace real (ex. duh-homelab/) GET / devolve só 'ginga serve' e /app.js 404; tests/web_shell.test.ts:28-31 cria web/ dentro do root temporário e mascara
  - FALHA [AC-roda-web-inbox-quadro-plan] depende da TASK-02: src/serve.ts:301-317 não acha web/ fora do root que contém web/ (workspace real fica sem UI)
  - ok [TASK-01] src/board.ts:232,316 blocked real via listOpenBlockers; src/board.ts:319-320 PLAN done -> FEITO; tests/board.test.ts e board_blocked.test.ts passam
  - ok [TASK-03] src/web/render/inbox.ts renderInbox com data-verb/data-id/data-count; tests/web_inbox.test.ts passa
  - ok [TASK-04] src/web/render/board.ts marcas ⚑ ✓? ⟳ e filtros; ⚑ agora alimentado por card.blocked real (src/board.ts:316)
  - ok [TASK-05] src/web/render/plan.ts renderPlan com botões retry/escalate/pause/cancel; tests/web_plan.test.ts passa
  - ok [TASK-06] src/index_md.ts:44-53,111 deriva de <ws>/.ginga sem ## duplicado; tests/index_md.test.ts e index_md_raiz.test.ts passam
  - ok [TASK-09] src/web/render/alerts.ts, src/board.ts:353-362 itens alerta no Inbox, verbo alerts em src/verbs/read.ts e registry.ts, web/alerts.js; tests/web_alerts.test.ts passa
  - ok [TASK-10] src/status.ts buildStatus, src/alerts.ts listAlerts, src/verbs/read.ts status; tests/status_json.test.ts passa
  - ok [TASK-11] tests/status_cli_parity.test.ts e tests/cli_verbs.test.ts passam
  - ok [TASK-12] web/index.html, web/app.js, web/style.css reais; tests/web_shell_casca.test.ts passa
  - ok [TASK-13] web/inbox.js liga botões a /v1/verbs e contador por SSE; tests/web_inbox_js.test.ts passa
  - ok [TASK-14] src/verbs/registry.ts:53 verbo index com check bool; src/verbs/index.ts:14-23; src/serve.ts:233-245 regenera no tick; tests/index_cli.test.ts passa
  - ok [TASK-15] src/board.ts:232,316,319-320; tests/board_blocked.test.ts passa
  - ok [TASK-16] src/index_md.ts:35-53 replaceSection não duplica cabeçalho, resolveBundleRoot; tests/index_md_raiz.test.ts passa
  - ok [TASK-17] src/board.ts:353 alertas no Inbox, src/verbs/registry.ts:50 verbo alerts, web/alerts.js e index.html montam o painel; tests/alertas_e2e.test.ts e web_alerts_js.test.ts passam
  - ok [AC-sem-logica-propria] read.board/inbox/status derivam de deriveBoard/buildStatus (src/verbs/read.ts); web chama /v1/verbs/*
  - ok [AC-SPEC0003-alertas] src/board.ts:353-362 + verbo alerts + web/alerts.js com ?sev= e data-severity; tests/alertas_e2e.test.ts passa
  - ok [AC-index-gerado] src/index_md.ts + verbo index --check + regeneração no serve (src/serve.ts:233); TASK-07 (duh-homelab) não julgada aqui
- resumo do judge: 731 testes passam e sem regressão; os achados do judge anterior (blocked/FEITO, index da raiz certa e sem cabeçalho duplicado, alertas ponta a ponta) estão corrigidos, mas o serve resolve web/ relativo ao --root em vez da instalação do ginga, então a Roda Web não é entregue num workspace real (TASK-02 e AC da Roda Web).

### 01:37 PLAN-0012-roda-web · ginga · plan/0012 · gate 0
- motivo: mergeado d12bf50
- judge: pass no HEAD cb5d4067 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0012-roda-web/judge/ginga-20261102T013522.log)
  - ok [TASK-01] src/board.ts:232,316 blocked real via blockedPlans; PLAN done -> FEITO; tests/board.test.ts e board_blocked.test.ts passam
  - ok [TASK-02] src/serve.ts:301-317 fallback usa web/ do workspace ou join(import.meta.dir,'..','web'); tests/web_shell.test.ts e web_shell_install.test.ts passam
  - ok [TASK-03] src/web/render/inbox.ts + web/inbox.js (8440 bytes) ligam data-verb a /v1/verbs; testes passam
  - ok [TASK-04] src/web/render/board.ts + web/board.js; marcas e filtros; tests/web_board.test.ts passa
  - ok [TASK-05] src/web/render/plan.ts + web/plan.js; tests/web_plan.test.ts passa
  - ok [TASK-06] src/index_md.ts renderIndex/writeIndex/checkIndex; tests/index_md.test.ts e index_md_raiz.test.ts passam
  - ok [TASK-08] superseded pela TASK-10; src/status.ts e src/alerts.ts presentes, tests/status_json.test.ts passa
  - ok [TASK-09] src/web/render/alerts.ts, web/alerts.js, src/board.ts:353 itens alerta; tests/web_alerts.test.ts passa
  - ok [TASK-10] src/status.ts buildStatus, src/alerts.ts listAlerts; tests/status_json.test.ts passa
  - ok [TASK-11] tests/status_cli_parity.test.ts e tests/cli_verbs.test.ts passam
  - ok [TASK-12] web/index.html:28-39 nav data-view; web/app.js EventSource/data-theme//v1/verbs; web/style.css 10876 bytes; web_shell_casca.test.ts passa
  - ok [TASK-13] web/inbox.js liga botões e contador por SSE; tests/web_inbox_js.test.ts passa
  - ok [TASK-14] verbo index com check no registry, regenera no tick do serve; tests/index_cli.test.ts passa
  - ok [TASK-15] src/board.ts:232,316 e PLAN done em FEITO; tests/board_blocked.test.ts passa
  - ok [TASK-16] src/index_md.ts deriva de <ws>/.ginga sem ## duplicado; tests/index_md_raiz.test.ts passa
  - ok [TASK-17] src/board.ts:353 alertas no Inbox, verbo alerts, web/index.html view-alerts + web/alerts.js; alertas_e2e e web_alerts_js passam
  - ok [TASK-18] src/serve.ts:301-317 installWebDir fallback; tests/web_shell_install.test.ts passa
  - ok [AC-roda-web-inbox-quadro-plan] src/serve.ts:301-317 entrega o web/ da instalação em workspace real; web/index.html com as views inbox/board/plan
  - ok [AC-sem-logica-propria] read.board/inbox/status derivam de deriveBoard/buildStatus; web só chama /v1/verbs/*
  - ok [AC-SPEC0003-alertas] src/board.ts:353 + verbo alerts + web/alerts.js com ?sev= e data-severity
  - ok [AC-index-gerado] src/index_md.ts + verbo index --check + regeneração no serve; TASK-07 (duh-homelab) não julgada aqui
- resumo do judge: Suíte completa 732 pass/0 fail; o achado grave anterior (serve não entregava a UI num workspace real) foi corrigido com o fallback para o web/ da instalação. Todas as TASKs ginga e os ACs estão cumpridos, sem regressão.

### 07:42 PLAN-0016-validar-code-mode · ginga · plan/0016 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 3b9883fa (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0016-validar-code-mode/judge/ginga-20261102T074039.log)
  - FALHA [AC] done_when `bun test tests/code_mode/` passa no worktree (20 pass), mas num `git archive HEAD` limpo dá 17 pass / 3 fail: fixture tests/fixtures/code-mode/snapshot/runs/ não commitado (ignorado por runs/ em ginga/.git/info/exclude)
  - FALHA [TASK-01] tests/code_mode/oracle.test.ts falha 2 testes em checkout limpo (Oracle 10/10 e verify) porque t06/t07 dependem de snapshot/runs/*, não versionado; bench/code-mode/tasks.ts e oracle.ts existem e passam só com os arquivos locais
  - FALHA [TASK-03] m.ts tem 12 tools e mcp_stdio.ts responde por linha, mas surface_m.test.ts 'read_plan e count_in_runs' falha em checkout limpo (esperado 3 step_finish do fixture runs/ ausente do git)
  - FALHA [TASK-06] report.ts:117-121 H4 escolhe por menor tokensIn e não por menor modelo; report.ts:140-144 H7 depende de sufixo '-min' que run.ts/config.ts nunca geram; regra 'diferença < 1 task → inconclusivo' ausente; sem CLI main apesar do PLAN
  - ok [TASK-02] bench/code-mode/runner.ts:trialArgv/parseExport/runTrial e run.ts:runCells (teto de custo) atendem runner.test.ts; ressalva: sem timeout real (processSpawn sem timer, runner.ts:51-70)
  - ok [TASK-04] config.ts:agentConfig gera M/C/X1/X2 conforme config.test.ts e c-skill.md existe; ressalva: tools read/grep/glob nativas do opencode ficam ligadas em M/X e C permite bash sem confinamento
  - ok [TASK-05] x.ts:bwrapArgv/truncate/execute/search_tools atendem surface_x.test.ts e x1.md existe; ressalva: funções anunciadas por search_tools não são injetadas no script, e minimal monta só /usr (bun fica em ~/.local/share/mise)
- resumo do judge: Código das 6 TASKs existe e os 20 testes passam no worktree, mas o fixture runs/ do snapshot sintético está ignorado pelo git (exclude 'runs/'), então em HEAD limpo 3 testes falham (TASK-01, TASK-03, done_when do PLAN). TASK-06 também implementa H4 e H7 de forma divergente dos critérios pré-registrados. Sem regressão: o diff contra main só adiciona arquivos.

### 09:42 PLAN-0016-validar-code-mode · ginga · plan/0016 · gate 0
- motivo: mergeado b8c18a8
- judge: pass no HEAD a7ce1d95 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0016-validar-code-mode/judge/ginga-20261102T093953.log)
  - ok [AC] bun test tests/code_mode/ = 26 pass/0 fail no worktree e em git archive HEAD extraído; tests/fixtures/code-mode/snapshot/runs/{a.log,b.log,c.jsonl,d.jsonl} agora versionados
  - ok [TASK-01] bench/code-mode/tasks.ts e oracle.ts; oracle.test.ts passa em checkout limpo (runs/ no git archive)
  - ok [TASK-02] runner.ts trialArgv/parseExport/runTrial, infraFailure runner.ts:243; run.ts runCells com teto de custo; runner.test.ts passa. Ressalva: sem timer real de timeout
  - ok [TASK-03] surfaces/m.ts 12 tools, mcp_stdio.ts JSON-RPC; surface_m.test.ts passa também em extração limpa
  - ok [TASK-04] config.ts agentConfig M/C/X1/X2 (config.ts:80-110), surfaces/c-skill.md; config.test.ts passa
  - ok [TASK-05] surfaces/x.ts:32-53 bwrapArgv (--unshare-net, --ro-bind snapshot, minimal só /usr), truncate 8000; x1.md; surface_x.test.ts passa. Ressalva: minimal monta só /usr
  - ok [TASK-06] report.ts decide/renderReport com critérios H1-H5/H7; report.test.ts passa
  - ok [TASK-07] clean_checkout.test.ts passa; git archive HEAD contém snapshot/runs/ e os testes de Oracle e M passam na extração
  - ok [TASK-08] report.ts: H4 por modelSizeRank, H7 pareado por Trial.sandbox (run.ts:37-41, runner.ts:329, config.ts:94-95, x.ts:105-106), regra sub-task em H1/H3, CLI main em report.ts; report_followup.test.ts passa
- resumo do judge: Todas as TASKs ginga (01-08) e o AC done_when estão cumpridos em HEAD: 26 testes passam, inclusive numa extração limpa de git archive HEAD, o que corrige a falha da rodada anterior. O diff contra main só adiciona arquivos, então não há regressão. Restam ressalvas simples e não bloqueantes: sem timeout real no spawn, bwrap minimal monta só /usr, e H7 normaliza o sufixo -min só para o fixture legado

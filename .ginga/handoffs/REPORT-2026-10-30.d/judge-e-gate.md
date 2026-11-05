
### 01:08 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 397389cb (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T010741.log)
  - FALHA [TASK-06] src/cost_cap.ts existe e passa no teste, mas grep de capCheck/spentUsd/round_usd/TOTAL_CAP em src/ e bin/ não acha nenhum uso: o teto não é checado antes de chamada paga e [budget] round_usd não é lido; ginga cost --json não é usado
  - FALHA [AC] AC do PLAN 'teto de custo cobre todos os papéis, checado antes de cada chamada paga' não atendido no manda: capCheck sem nenhum chamador em src/ ou bin/
  - ok [TASK-02] src/alloc.ts; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts redPlan; tests/red.test.ts passa. Ressalvas: erro de frozen ausente com caminho fixo (src/red.ts, trecho frozenSrc); prove-red com code!=0 vira test_passed_on_base; git add . carrega arquivos de TASK bloqueada
  - ok [TASK-05] src/replan.ts buildReplanContext e replan; CLI em src/cli.ts roda o planner antes de replan() e passa um closure fixo; tests/replan.test.ts passa
  - ok [TASK-09] src/cli.ts comando red valida e chama redPlan; mas não imprime o JSON com as TASKs e retorna 0 com TASK bloqueada; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts comando red usa env: process.env no pinga e no git; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts, judge/*.json, diff main...plan/NNNN e [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: TASK-02, 03, 05, 09, 10 e 11 funcionam e seus testes passam, com ressalvas menores. A TASK-06 e o AC do teto de custo falham: capCheck/spentUsd existem e passam no teste, mas nenhum código os chama antes de uma chamada paga e [budget] round_usd não é lido. As 4 falhas da suíte completa já existem na main, então não há regressão.

### 01:09 PLAN-0032-guarda-de-escopo-no-pi · manda · plan/0032 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 76d53998 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0032-guarda-de-escopo-no-pi/judge/manda-20261030T010848.log)
  - FALHA [TASK-01] src/runtime/scope_guard.ts:65-80 abre exceção só para prefixos tests/fixtures e tests/frozen, então frozen 'docs/**' não bloqueia docs/x.ts; hasPathEscape e a checagem em decideToolCall têm /etc/passwd e ../fora.ts fixos; absoluto fora da raiz vira outside_touch; não usa resolvePath/matchesAny. Os t
  - FALHA [TASK-04] src/runtime/pi.ts sem -e nem MANDA_SCOPE_*; tests/runtime_pi_scope.test.ts não existe; git log main não contém PLAN-0029, que é pré-requisito declarado no PLAN
  - FALHA [AC] o Pi ainda não bloqueia em execução real: src/runtime/pi.ts não passa -e/MANDA_SCOPE_* (TASK-04 pendente), pi_scope_guard.ts não emite scope.block, e scope_guard.ts tem o glob incorreto; as 4 falhas de bun test completo também ocorrem na main
  - ok [TASK-02] src/runtime/scope_path.ts:30-180 resolvePath (.., absoluto, symlink via realpath) e matchesAny (prefixo, Bun.Glob, exato); scope_ignore.json com as 4 entradas; tests/scope_path.test.ts passa; scope_ignore.json não é lido por nenhum código
  - ok [TASK-03] src/runtime/pi_scope_guard.ts:7-71 registra tool_call só com as variáveis de ambiente, retorna {block, reason}, try/catch total libera com scope.guard_error; tests/pi_scope_guard.test.ts passa; não chama emitScopeBlock
  - ok [TASK-05] src/runtime/scope_events.ts:1-55 emitScopeBlock, emitScopeGuardError e countByRule; tests/scope_events.test.ts e tests/events.test.ts passam; nenhum código fora dos testes chama os emissores
- resumo do judge: Sem regressão: as 4 falhas de bun test são idênticas na main. As TASKs 01, 02, 03 e 05 têm código e testes passando. A TASK-01 é ajustada aos casos do teste (glob com exceção para tests/fixtures e tests/frozen, /etc/passwd fixo, sem usar scope_path), então um frozen 'docs/**' não bloqueia docs/x.ts. A TASK-04 não foi feita porque o PLAN-0029 não está na main, e sem ela a guarda não está ligada ao 

### 01:50 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 397389cb (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T010741.log)
  - FALHA [TASK-06] src/cost_cap.ts existe e passa no teste, mas grep de capCheck/spentUsd/round_usd/TOTAL_CAP em src/ e bin/ não acha nenhum uso: o teto não é checado antes de chamada paga e [budget] round_usd não é lido; ginga cost --json não é usado
  - FALHA [AC] AC do PLAN 'teto de custo cobre todos os papéis, checado antes de cada chamada paga' não atendido no manda: capCheck sem nenhum chamador em src/ ou bin/
  - ok [TASK-02] src/alloc.ts; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts redPlan; tests/red.test.ts passa. Ressalvas: erro de frozen ausente com caminho fixo (src/red.ts, trecho frozenSrc); prove-red com code!=0 vira test_passed_on_base; git add . carrega arquivos de TASK bloqueada
  - ok [TASK-05] src/replan.ts buildReplanContext e replan; CLI em src/cli.ts roda o planner antes de replan() e passa um closure fixo; tests/replan.test.ts passa
  - ok [TASK-09] src/cli.ts comando red valida e chama redPlan; mas não imprime o JSON com as TASKs e retorna 0 com TASK bloqueada; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts comando red usa env: process.env no pinga e no git; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts, judge/*.json, diff main...plan/NNNN e [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: TASK-02, 03, 05, 09, 10 e 11 funcionam e seus testes passam, com ressalvas menores. A TASK-06 e o AC do teto de custo falham: capCheck/spentUsd existem e passam no teste, mas nenhum código os chama antes de uma chamada paga e [budget] round_usd não é lido. As 4 falhas da suíte completa já existem na main, então não há regressão.

### 01:50 PLAN-0032-guarda-de-escopo-no-pi · manda · plan/0032 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 76d53998 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0032-guarda-de-escopo-no-pi/judge/manda-20261030T010848.log)
  - FALHA [TASK-01] src/runtime/scope_guard.ts:65-80 abre exceção só para prefixos tests/fixtures e tests/frozen, então frozen 'docs/**' não bloqueia docs/x.ts; hasPathEscape e a checagem em decideToolCall têm /etc/passwd e ../fora.ts fixos; absoluto fora da raiz vira outside_touch; não usa resolvePath/matchesAny. Os t
  - FALHA [TASK-04] src/runtime/pi.ts sem -e nem MANDA_SCOPE_*; tests/runtime_pi_scope.test.ts não existe; git log main não contém PLAN-0029, que é pré-requisito declarado no PLAN
  - FALHA [AC] o Pi ainda não bloqueia em execução real: src/runtime/pi.ts não passa -e/MANDA_SCOPE_* (TASK-04 pendente), pi_scope_guard.ts não emite scope.block, e scope_guard.ts tem o glob incorreto; as 4 falhas de bun test completo também ocorrem na main
  - ok [TASK-02] src/runtime/scope_path.ts:30-180 resolvePath (.., absoluto, symlink via realpath) e matchesAny (prefixo, Bun.Glob, exato); scope_ignore.json com as 4 entradas; tests/scope_path.test.ts passa; scope_ignore.json não é lido por nenhum código
  - ok [TASK-03] src/runtime/pi_scope_guard.ts:7-71 registra tool_call só com as variáveis de ambiente, retorna {block, reason}, try/catch total libera com scope.guard_error; tests/pi_scope_guard.test.ts passa; não chama emitScopeBlock
  - ok [TASK-05] src/runtime/scope_events.ts:1-55 emitScopeBlock, emitScopeGuardError e countByRule; tests/scope_events.test.ts e tests/events.test.ts passam; nenhum código fora dos testes chama os emissores
- resumo do judge: Sem regressão: as 4 falhas de bun test são idênticas na main. As TASKs 01, 02, 03 e 05 têm código e testes passando. A TASK-01 é ajustada aos casos do teste (glob com exceção para tests/fixtures e tests/frozen, /etc/passwd fixo, sem usar scope_path), então um frozen 'docs/**' não bloqueia docs/x.ts. A TASK-04 não foi feita porque o PLAN-0029 não está na main, e sem ela a guarda não está ligada ao 

### 02:07 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 0a8e10ec (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T020548.log)
  - FALHA [TASK-03] src/handoff.ts:71 git padrão () => '' e src/verbs/handoff.ts:9 não injeta git: seções de git vazias na CLI e rodando em planDir, não nos repos; src/handoff.ts:106 só lista nomes de TASK (sem estado/última tentativa/próxima aberta/blockers/SPEC); src/handoff.ts:44 ordena armadilha>confirmada>resto (d
  - FALHA [TASK-04] tests/e2e/investigation.test.ts e tests/fixtures/investigation/ não existem em HEAD
  - FALHA [TASK-05] src/lessons.ts, src/verbs/learning.ts e tests/learning_promote.test.ts não existem; LEARNING_VERBS ausente de registry.ts
  - FALHA [TASK-06] findLessons / verbo 'lessons find' e tests/lessons_find.test.ts não existem
  - FALHA [TASK-08] src/lessons_import.ts, importLessons e tests/lessons_import.test.ts não existem
  - FALHA [TASK-10] src/handoff/policy.ts (decideHandoff/parseHandoffCfg), src/lint/project_toml.ts e tests/handoff_policy.test.ts não existem (src/handoff/ ausente)
  - FALHA [TASK-11] src/handoff/redact.ts, flags --trigger/--notes e tests/handoff_session.test.ts não existem; verbo handoff só aceita arg plan
  - FALHA [TASK-12] src/handoff/hook.ts, transcript_usage.ts e tests/handoff_hook.test.ts não existem
  - FALHA [TASK-13] src/handoff/open.ts, open_claude.ts e tests/handoff_open.test.ts não existem
  - FALHA [TASK-14] diretório skills/ (skills/handoff/SKILL.md) e tests/skill_handoff.test.ts não existem
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook de handoff, contrib/claude-mod-handoff/ e tests/install_handoff_claude.test.ts ausentes
  - FALHA [AC1] handoff sem LLM existe (src/handoff.ts) mas incompleto: sem estado de TASKs, git real, blockers; ver TASK-03
  - FALHA [AC2] log.md automático (TASK-01) e lint de LEARNINGS/kind (TASK-02) ok; e2e de kind: investigation (TASK-04) ausente
  - FALHA [AC3] promote/findLessons (TASK-05/06) não implementados
  - FALHA [AC4] só o verbo handoff registrado (src/verbs/registry.ts:55); learning promote e lessons import ausentes
  - ok [TASK-01] src/plan_log.ts:33-48,64-81 formatLogLine/appendPlanLog idempotente por marcador <!-- id -->; gancho em src/notify/router.ts:90-95; tests/plan_log.test.ts
  - ok [TASK-02] src/lint/learnings.ts lintLearnings (cabeçalho, status, 4 campos); src/lint/index.ts:63-79 aviso para approved sem LEARNINGS.md; kind já validado em src/lint/frontmatter.ts:21. Menor: console.error dentro de lintBundle e okf.ts:117,132 sem warnings (só tipo)
- resumo do judge: TASK-01 e TASK-02 cumpridas; TASK-03 incompleta (sem estado das TASKs, git não injetado na CLI, ordem de learnings, evento handoff fora do schema e arquivo não determinístico); TASKs 04, 05, 06, 08 e 10 a 15 do ginga não implementadas em HEAD. Sem regressões em relação à main. Análise estática, testes não executados (plan mode).

### 02:49 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 397389cb (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T010741.log)
  - FALHA [TASK-06] src/cost_cap.ts existe e passa no teste, mas grep de capCheck/spentUsd/round_usd/TOTAL_CAP em src/ e bin/ não acha nenhum uso: o teto não é checado antes de chamada paga e [budget] round_usd não é lido; ginga cost --json não é usado
  - FALHA [AC] AC do PLAN 'teto de custo cobre todos os papéis, checado antes de cada chamada paga' não atendido no manda: capCheck sem nenhum chamador em src/ ou bin/
  - ok [TASK-02] src/alloc.ts; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts redPlan; tests/red.test.ts passa. Ressalvas: erro de frozen ausente com caminho fixo (src/red.ts, trecho frozenSrc); prove-red com code!=0 vira test_passed_on_base; git add . carrega arquivos de TASK bloqueada
  - ok [TASK-05] src/replan.ts buildReplanContext e replan; CLI em src/cli.ts roda o planner antes de replan() e passa um closure fixo; tests/replan.test.ts passa
  - ok [TASK-09] src/cli.ts comando red valida e chama redPlan; mas não imprime o JSON com as TASKs e retorna 0 com TASK bloqueada; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts comando red usa env: process.env no pinga e no git; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts, judge/*.json, diff main...plan/NNNN e [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: TASK-02, 03, 05, 09, 10 e 11 funcionam e seus testes passam, com ressalvas menores. A TASK-06 e o AC do teto de custo falham: capCheck/spentUsd existem e passam no teste, mas nenhum código os chama antes de uma chamada paga e [budget] round_usd não é lido. As 4 falhas da suíte completa já existem na main, então não há regressão.

### 02:49 PLAN-0032-guarda-de-escopo-no-pi · manda · plan/0032 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 76d53998 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0032-guarda-de-escopo-no-pi/judge/manda-20261030T010848.log)
  - FALHA [TASK-01] src/runtime/scope_guard.ts:65-80 abre exceção só para prefixos tests/fixtures e tests/frozen, então frozen 'docs/**' não bloqueia docs/x.ts; hasPathEscape e a checagem em decideToolCall têm /etc/passwd e ../fora.ts fixos; absoluto fora da raiz vira outside_touch; não usa resolvePath/matchesAny. Os t
  - FALHA [TASK-04] src/runtime/pi.ts sem -e nem MANDA_SCOPE_*; tests/runtime_pi_scope.test.ts não existe; git log main não contém PLAN-0029, que é pré-requisito declarado no PLAN
  - FALHA [AC] o Pi ainda não bloqueia em execução real: src/runtime/pi.ts não passa -e/MANDA_SCOPE_* (TASK-04 pendente), pi_scope_guard.ts não emite scope.block, e scope_guard.ts tem o glob incorreto; as 4 falhas de bun test completo também ocorrem na main
  - ok [TASK-02] src/runtime/scope_path.ts:30-180 resolvePath (.., absoluto, symlink via realpath) e matchesAny (prefixo, Bun.Glob, exato); scope_ignore.json com as 4 entradas; tests/scope_path.test.ts passa; scope_ignore.json não é lido por nenhum código
  - ok [TASK-03] src/runtime/pi_scope_guard.ts:7-71 registra tool_call só com as variáveis de ambiente, retorna {block, reason}, try/catch total libera com scope.guard_error; tests/pi_scope_guard.test.ts passa; não chama emitScopeBlock
  - ok [TASK-05] src/runtime/scope_events.ts:1-55 emitScopeBlock, emitScopeGuardError e countByRule; tests/scope_events.test.ts e tests/events.test.ts passam; nenhum código fora dos testes chama os emissores
- resumo do judge: Sem regressão: as 4 falhas de bun test são idênticas na main. As TASKs 01, 02, 03 e 05 têm código e testes passando. A TASK-01 é ajustada aos casos do teste (glob com exceção para tests/fixtures e tests/frozen, /etc/passwd fixo, sem usar scope_path), então um frozen 'docs/**' não bloqueia docs/x.ts. A TASK-04 não foi feita porque o PLAN-0029 não está na main, e sem ela a guarda não está ligada ao 

### 04:49 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD e4b428c1 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T044850.log)
  - FALHA [TASK-04] tests/e2e/investigation.test.ts e tests/fixtures/investigation/ não existem
  - FALHA [TASK-05] src/lessons.ts e src/verbs/learning.ts não existem; sem promote()/LEARNING_VERBS
  - FALHA [TASK-06] sem findLessons nem verbo 'lessons find' em src/
  - FALHA [TASK-08] src/lessons_import.ts não existe; sem importLessons/'lessons import'
  - FALHA [TASK-10] src/handoff/policy.ts não existe; sem decideHandoff/parseHandoffCfg nem lint de [handoff]
  - FALHA [TASK-11] src/handoff/redact.ts não existe; buildHandoff sem trigger/notes/depth; sem modo sessão
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts não existem
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts não existem; sem openSession
  - FALHA [TASK-14] diretório skills/ não existe (skills/handoff/SKILL.md ausente)
  - FALHA [TASK-15] src/install/adapters/claude.ts sem hooks de handoff; contrib/claude-mod-handoff/ ausente
  - FALHA [AC] Cobertos: handoff sem LLM, log.md automático, LEARNINGS/kind no lint. Não cobertos: learnings promovidos → LESSON achada pelo touch (TASK-05/06), verbos learning/lessons, e handoff automático (TASK-10 a 15)
  - ok [TASK-01] src/plan_log.ts:49-75 formatLogLine/appendPlanLog idempotente por ev.id; gancho em src/notify/router.ts; tests/plan_log.test.ts passa
  - ok [TASK-02] src/lint/learnings.ts + src/lint/index.ts lintPlanLearnings (aviso sem LEARNINGS.md, erro de formato); tests/lint_learnings.test.ts passa
  - ok [TASK-03] src/handoff.ts:141 buildHandoff; src/verbs/handoff.ts + registry.ts ...HANDOFF_VERBS; ordem descartada/armadilha (handoff.ts:69-72); tests/handoff.test.ts passa
  - ok [TASK-16] src/handoff.ts (git por repo, pinga queue com degradação, frontmatter em buildHandoff); src/verbs/handoff.ts evento com plan no envelope, data.file e context_tokens; tests/handoff_full.test.ts passa
  - ok [TASK-17] tests/cli_verbs.test.ts:98 caso handoff; src/verbs/handoff.ts devolve path relativo ao root; bun test completo 489 pass/0 fail
- resumo do judge: HEAD cumpre TASK-01, 02, 03, 16 e 17 (bun test 489 pass/0 fail, sem regressão vs main), mas as TASKs 04, 05, 06, 08 e 10–15 do ginga não têm código nenhum; por isso os ACs de lessons e do handoff automático não estão cumpridos.

### 05:42 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD c956ab7b (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T054050.log)
  - FALHA [AC-teto-todos-papeis] src/cli.ts executa planner(plannerCmd)/fallback antes de replan(); replan.ts:checkPaidCall roda depois da chamada paga; run.ts/judge.ts não passam claudeCosts e usam since=agora no judge
  - FALHA [TASK-03] src/red.ts: taken só do pinga queue (sem pinga_task dos TASK-*.md nem tasks/T*/); qualquer prove-red code!=0 vira test_passed_on_base; tests/red.test.ts passa
  - FALHA [TASK-09] src/cli.ts:269-310 manda red retorna 0 sem imprimir o JSON com as TASKs; validação de tests_frozen existe em src/red.ts
  - FALHA [TASK-12] cost_cap.ts checkPaidCall e guardas em run.ts/judge.ts OK e testados; no caminho CLI do replan o Planner roda antes da guarda (cli.ts planner: () => plannerRes)
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext (3 receipts, 20000 chars, LEARNINGS) e lint→blocked; tests/replan.test.ts passa; sem rollback do PLAN em lint falho
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: Os testes do repo passam, exceto 4 que já falham na main, então não há regressão. O teto de custo não cobre o Planner chamado pela CLI (a chamada paga acontece antes do checkPaidCall) e o fallback ignora claudeCosts. Desvios menores: TASK-03 (ids em uso só da fila do pinga) e TASK-09 (manda red não imprime o JSON).

### 05:44 PLAN-0032-guarda-de-escopo-no-pi · manda · plan/0032 · gate 0
- motivo: mergeado 4a3b694
- judge: pass no HEAD d057f23b (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0032-guarda-de-escopo-no-pi/judge/manda-20261030T054241.log)
  - ok [TASK-01] src/runtime/scope_guard.ts:34-70 decide edit/write e bash; tests/scope_guard.test.ts verde
  - ok [TASK-02] src/runtime/scope_path.ts resolvePath/matchesAny; scope_ignore.json com 4 padrões; tests/scope_path.test.ts verde
  - ok [TASK-03] src/runtime/pi_scope_guard.ts registra tool_call só com env, retorna {block,reason}, try/catch libera e emite scope.guard_error; tests/pi_scope_guard.test.ts verde
  - ok [TASK-04] src/runtime/scope_guard.ts:3,41-60 usa resolvePath/matchesAny sem casos fixos; tests/scope_guard_paths.test.ts, scope_guard.test.ts e scope_path.test.ts verdes
  - ok [TASK-05] src/runtime/scope_events.ts emitScopeBlock/emitScopeGuardError/countByRule; tests/scope_events.test.ts e tests/events.test.ts verdes (a ligação do scope.block ao handler fica para o PLAN-0034)
  - ok [AC] bun test dos 5 arquivos do PLAN mais events.test.ts: 31 pass 0 fail; suíte inteira 263 pass 4 fail (judge/pipeline CLI exit 30 pela guarda de LLM, em arquivos que o diff não toca)
- resumo do judge: Todas as TASKs manda (01-05) cumprem seus done_when em HEAD e o achado anterior do judge (casos fixos em scope_guard) foi corrigido pela TASK-04. As 4 falhas da suíte inteira são testes de CLI que recebem exit 30 da guarda de LLM por rodarem dentro de um agente, e não vêm do diff. Limitações menores: scope_ignore.json não é consumido pela guarda, e nada emite scope.block em runtime ainda (ligação 

### 07:06 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 3d81e7a5 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T070357.log)
  - FALHA [TASK-05] src/lessons.ts e src/verbs/learning.ts inexistem; tests/learning_promote.test.ts falha (promote, learning promote)
  - FALHA [TASK-06] findLessons e verbo lessons find ausentes; tests/lessons_find.test.ts falha
  - FALHA [TASK-08] src/lessons_import.ts inexistente; tests/lessons_import.test.ts 5 fails
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts inexistentes; tests/handoff_policy.test.ts falha (decideHandoff, parseHandoffCfg, lint [handoff])
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; buildHandoff sem modo sessão; tests/handoff_session.test.ts falha
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts 8 fails
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha
  - FALHA [TASK-14] skills/handoff/ inexistente; tests/skill_handoff.test.ts falha
  - FALHA [TASK-15] adapter claude sem hooks de handoff, contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha
  - FALHA [AC] ACs de handoff sem LLM e log.md/LEARNINGS/investigation cumpridos (TASK-01..04,16), mas 'learnings viram LESSON achada pelo touch' e verbos learning promote/lessons import/find não existem (TASK-05/06/08); handoff automático (TASK-10..15) ausente
  - ok [TASK-01] src/plan_log.ts:55-75 appendPlanLog idempotente; src/notify/router.ts gancho; tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts, src/lint/index.ts lintPlanLearnings, frontmatter.ts:21 kind; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS, registry.ts; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass (fixtures/investigation)
  - ok [TASK-16] src/handoff.ts (git por repo, estado/fila, frontmatter), src/verbs/handoff.ts evento válido; tests/handoff_full.test.ts 7 pass
  - ok [TASK-17] tests/cli_verbs.test.ts 34 pass; src/verbs/handoff.ts path relativo ao root
- resumo do judge: HEAD tem só TASK-01,02,03,04,16,17 implementadas e verdes (nenhuma regressão vs main; os 44 fails são testes RED novos). TASK-05,06,08,10,11,12,13,14,15 têm só o commit RED, sem código, então o PLAN não cumpre os ACs de lessons nem o handoff automático.

### 07:35 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD c956ab7b (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T054050.log)
  - FALHA [AC-teto-todos-papeis] src/cli.ts executa planner(plannerCmd)/fallback antes de replan(); replan.ts:checkPaidCall roda depois da chamada paga; run.ts/judge.ts não passam claudeCosts e usam since=agora no judge
  - FALHA [TASK-03] src/red.ts: taken só do pinga queue (sem pinga_task dos TASK-*.md nem tasks/T*/); qualquer prove-red code!=0 vira test_passed_on_base; tests/red.test.ts passa
  - FALHA [TASK-09] src/cli.ts:269-310 manda red retorna 0 sem imprimir o JSON com as TASKs; validação de tests_frozen existe em src/red.ts
  - FALHA [TASK-12] cost_cap.ts checkPaidCall e guardas em run.ts/judge.ts OK e testados; no caminho CLI do replan o Planner roda antes da guarda (cli.ts planner: () => plannerRes)
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext (3 receipts, 20000 chars, LEARNINGS) e lint→blocked; tests/replan.test.ts passa; sem rollback do PLAN em lint falho
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: Os testes do repo passam, exceto 4 que já falham na main, então não há regressão. O teto de custo não cobre o Planner chamado pela CLI (a chamada paga acontece antes do checkPaidCall) e o fallback ignora claudeCosts. Desvios menores: TASK-03 (ids em uso só da fila do pinga) e TASK-09 (manda red não imprime o JSON).

### 09:03 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD d4487601 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T090207.log)
  - FALHA [TASK-05] REGRESSÃO learning promote registrado em src/verbs/learning.ts:35 sem caso em tests/cli_verbs.test.ts CASES: falham cli_verbs.test.ts:103 ('todo verbo tem caso') e 'learning promote --json devolve o mesmo JSON' (passavam na main); item de Inbox 'promover?' ausente (grep 'promover' em src vazio)
  - FALHA [TASK-06] src/lessons.ts sem findLessons; sem verbo 'lessons find' em src/verbs/learning.ts; tests/lessons_find.test.ts falha
  - FALHA [TASK-08] src/lessons_import.ts inexistente; sem verbo 'lessons import'; tests/lessons_import.test.ts falha
  - FALHA [TASK-10] src/handoff/policy.ts inexistente; sem lint de [handoff] em src/lint; tests/handoff_policy.test.ts falha
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; buildHandoff sem modo sessão; tests/handoff_session.test.ts falha
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha
  - FALHA [TASK-14] skills/handoff/ inexistente; tests/skill_handoff.test.ts falha
  - FALHA [TASK-15] contrib/claude-mod-handoff/ inexistente; src/install/adapters/claude.ts sem hooks de handoff; tests/install_handoff_claude.test.ts falha
  - FALHA [AC-lesson-encontrada-pelo-touch] promote existe, mas findLessons/lessons find ausentes (TASK-06)
  - FALHA [AC-toda-acao-como-verbo] REGRESSÃO lessons import ausente; learning promote sem caso em cli_verbs.test.ts quebra 2 testes que passavam na main
  - FALHA [AC-handoff-automatico] TASK-10 a 15 sem código; src/handoff/ não existe
  - ok [TASK-01] src/plan_log.ts:27,60; src/notify/router.ts; tests/plan_log.test.ts passa
  - ok [TASK-02] src/lint/learnings.ts:19; src/lint/index.ts; tests/lint_learnings.test.ts passa
  - ok [TASK-03] src/handoff.ts:141 buildHandoff; src/verbs/handoff.ts:46 HANDOFF_VERBS; tests/handoff.test.ts passa
  - ok [TASK-04] tests/e2e/investigation.test.ts e fixtures passam; TASK só de teste
  - ok [TASK-16] src/handoff.ts, src/verbs/handoff.ts; tests/handoff_full.test.ts passa
  - ok [TASK-17] tests/cli_verbs.test.ts:98 caso handoff; teste de comparação do handoff passa
  - ok [AC-handoff-sem-LLM] buildHandoff determinístico; handoff.test.ts e handoff_full.test.ts passam
  - ok [AC-log-learnings-investigation] plan_log.ts, lint/learnings.ts, e2e/investigation.test.ts passam
- resumo do judge: HEAD tem 01, 02, 03, 04, 16 e 17 prontas. Faltam 06 e 08 (lessons find/import) e 10 a 15 (handoff automático): 43 testes congelados falham de 538. A TASK-05 introduz regressão: learning promote entra no registry sem caso em tests/cli_verbs.test.ts, e 2 testes que passavam na main falham. ACs de lessons por touch, verbos e handoff automático não cumpridos.

### 09:19 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD c956ab7b (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T054050.log)
  - FALHA [AC-teto-todos-papeis] src/cli.ts executa planner(plannerCmd)/fallback antes de replan(); replan.ts:checkPaidCall roda depois da chamada paga; run.ts/judge.ts não passam claudeCosts e usam since=agora no judge
  - FALHA [TASK-03] src/red.ts: taken só do pinga queue (sem pinga_task dos TASK-*.md nem tasks/T*/); qualquer prove-red code!=0 vira test_passed_on_base; tests/red.test.ts passa
  - FALHA [TASK-09] src/cli.ts:269-310 manda red retorna 0 sem imprimir o JSON com as TASKs; validação de tests_frozen existe em src/red.ts
  - FALHA [TASK-12] cost_cap.ts checkPaidCall e guardas em run.ts/judge.ts OK e testados; no caminho CLI do replan o Planner roda antes da guarda (cli.ts planner: () => plannerRes)
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext (3 receipts, 20000 chars, LEARNINGS) e lint→blocked; tests/replan.test.ts passa; sem rollback do PLAN em lint falho
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: Os testes do repo passam, exceto 4 que já falham na main, então não há regressão. O teto de custo não cobre o Planner chamado pela CLI (a chamada paga acontece antes do checkPaidCall) e o fallback ignora claudeCosts. Desvios menores: TASK-03 (ids em uso só da fila do pinga) e TASK-09 (manda red não imprime o JSON).

### 09:33 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD d4487601 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T090207.log)
  - FALHA [TASK-05] REGRESSÃO learning promote registrado em src/verbs/learning.ts:35 sem caso em tests/cli_verbs.test.ts CASES: falham cli_verbs.test.ts:103 ('todo verbo tem caso') e 'learning promote --json devolve o mesmo JSON' (passavam na main); item de Inbox 'promover?' ausente (grep 'promover' em src vazio)
  - FALHA [TASK-06] src/lessons.ts sem findLessons; sem verbo 'lessons find' em src/verbs/learning.ts; tests/lessons_find.test.ts falha
  - FALHA [TASK-08] src/lessons_import.ts inexistente; sem verbo 'lessons import'; tests/lessons_import.test.ts falha
  - FALHA [TASK-10] src/handoff/policy.ts inexistente; sem lint de [handoff] em src/lint; tests/handoff_policy.test.ts falha
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; buildHandoff sem modo sessão; tests/handoff_session.test.ts falha
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha
  - FALHA [TASK-14] skills/handoff/ inexistente; tests/skill_handoff.test.ts falha
  - FALHA [TASK-15] contrib/claude-mod-handoff/ inexistente; src/install/adapters/claude.ts sem hooks de handoff; tests/install_handoff_claude.test.ts falha
  - FALHA [AC-lesson-encontrada-pelo-touch] promote existe, mas findLessons/lessons find ausentes (TASK-06)
  - FALHA [AC-toda-acao-como-verbo] REGRESSÃO lessons import ausente; learning promote sem caso em cli_verbs.test.ts quebra 2 testes que passavam na main
  - FALHA [AC-handoff-automatico] TASK-10 a 15 sem código; src/handoff/ não existe
  - ok [TASK-01] src/plan_log.ts:27,60; src/notify/router.ts; tests/plan_log.test.ts passa
  - ok [TASK-02] src/lint/learnings.ts:19; src/lint/index.ts; tests/lint_learnings.test.ts passa
  - ok [TASK-03] src/handoff.ts:141 buildHandoff; src/verbs/handoff.ts:46 HANDOFF_VERBS; tests/handoff.test.ts passa
  - ok [TASK-04] tests/e2e/investigation.test.ts e fixtures passam; TASK só de teste
  - ok [TASK-16] src/handoff.ts, src/verbs/handoff.ts; tests/handoff_full.test.ts passa
  - ok [TASK-17] tests/cli_verbs.test.ts:98 caso handoff; teste de comparação do handoff passa
  - ok [AC-handoff-sem-LLM] buildHandoff determinístico; handoff.test.ts e handoff_full.test.ts passam
  - ok [AC-log-learnings-investigation] plan_log.ts, lint/learnings.ts, e2e/investigation.test.ts passam
- resumo do judge: HEAD tem 01, 02, 03, 04, 16 e 17 prontas. Faltam 06 e 08 (lessons find/import) e 10 a 15 (handoff automático): 43 testes congelados falham de 538. A TASK-05 introduz regressão: learning promote entra no registry sem caso em tests/cli_verbs.test.ts, e 2 testes que passavam na main falham. ACs de lessons por touch, verbos e handoff automático não cumpridos.

### 09:54 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 099d16e4 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T095210.log)
  - FALHA [AC] src/judge.ts:232 e src/replan.ts + src/cli.ts:253 usam since=agora, então o gasto acumulado do papel judge/planner é ~0; nenhum chamador passa claudeCosts (cli.ts:258 passa []); `ginga cost --json` não existe (ginga: 'comando desconhecido: cost'), então só o fallback spentUsd roda; run.ts:341 usa ru
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:100-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; taken inclui pinga queue + pinga_task do bundle, mas não tasks/T*/ do repo; tests/red.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico (3 receipts, 20000 chars, LEARNINGS), lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts:333 imprime JSON do redPlan; validação de tests_frozen em src/red.ts; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
  - ok [TASK-12] src/cost_cap.ts loadRoundCapUsd/isPaidModel/checkPaidCall; guardas antes de adapter.run em run.ts:339-356, judge.ts:231-242, replan.ts antes de options.planner; tests/cost_cap_wiring.test.ts passa; ressalva: since=agora em judge/replan e claudeCosts nunca alimentado (ver AC)
- resumo do judge: Não há regressão: HEAD tem 258 pass e as mesmas 4 falhas da main (judge CLI sem PLAN/inexistente, pipeline/lane sem args). As TASKs 02, 03, 05, 06, 09, 10, 11 e 12 estão cumpridas e os achados anteriores (guarda do planner antes da chamada, JSON do red, taken com pinga_task do bundle, prove-red com erro) foram corrigidos em 099d16e. O AC do teto de todos os papéis ainda não é atendido na prática: 

### 10:11 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 2
- motivo: main com mudancas nao commitadas
- judge: fail no HEAD d4487601 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T090207.log)
  - FALHA [TASK-05] REGRESSÃO learning promote registrado em src/verbs/learning.ts:35 sem caso em tests/cli_verbs.test.ts CASES: falham cli_verbs.test.ts:103 ('todo verbo tem caso') e 'learning promote --json devolve o mesmo JSON' (passavam na main); item de Inbox 'promover?' ausente (grep 'promover' em src vazio)
  - FALHA [TASK-06] src/lessons.ts sem findLessons; sem verbo 'lessons find' em src/verbs/learning.ts; tests/lessons_find.test.ts falha
  - FALHA [TASK-08] src/lessons_import.ts inexistente; sem verbo 'lessons import'; tests/lessons_import.test.ts falha
  - FALHA [TASK-10] src/handoff/policy.ts inexistente; sem lint de [handoff] em src/lint; tests/handoff_policy.test.ts falha
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; buildHandoff sem modo sessão; tests/handoff_session.test.ts falha
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha
  - FALHA [TASK-14] skills/handoff/ inexistente; tests/skill_handoff.test.ts falha
  - FALHA [TASK-15] contrib/claude-mod-handoff/ inexistente; src/install/adapters/claude.ts sem hooks de handoff; tests/install_handoff_claude.test.ts falha
  - FALHA [AC-lesson-encontrada-pelo-touch] promote existe, mas findLessons/lessons find ausentes (TASK-06)
  - FALHA [AC-toda-acao-como-verbo] REGRESSÃO lessons import ausente; learning promote sem caso em cli_verbs.test.ts quebra 2 testes que passavam na main
  - FALHA [AC-handoff-automatico] TASK-10 a 15 sem código; src/handoff/ não existe
  - ok [TASK-01] src/plan_log.ts:27,60; src/notify/router.ts; tests/plan_log.test.ts passa
  - ok [TASK-02] src/lint/learnings.ts:19; src/lint/index.ts; tests/lint_learnings.test.ts passa
  - ok [TASK-03] src/handoff.ts:141 buildHandoff; src/verbs/handoff.ts:46 HANDOFF_VERBS; tests/handoff.test.ts passa
  - ok [TASK-04] tests/e2e/investigation.test.ts e fixtures passam; TASK só de teste
  - ok [TASK-16] src/handoff.ts, src/verbs/handoff.ts; tests/handoff_full.test.ts passa
  - ok [TASK-17] tests/cli_verbs.test.ts:98 caso handoff; teste de comparação do handoff passa
  - ok [AC-handoff-sem-LLM] buildHandoff determinístico; handoff.test.ts e handoff_full.test.ts passam
  - ok [AC-log-learnings-investigation] plan_log.ts, lint/learnings.ts, e2e/investigation.test.ts passam
- resumo do judge: HEAD tem 01, 02, 03, 04, 16 e 17 prontas. Faltam 06 e 08 (lessons find/import) e 10 a 15 (handoff automático): 43 testes congelados falham de 538. A TASK-05 introduz regressão: learning promote entra no registry sem caso em tests/cli_verbs.test.ts, e 2 testes que passavam na main falham. ACs de lessons por touch, verbos e handoff automático não cumpridos.

### 10:26 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 099d16e4 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T095210.log)
  - FALHA [AC] src/judge.ts:232 e src/replan.ts + src/cli.ts:253 usam since=agora, então o gasto acumulado do papel judge/planner é ~0; nenhum chamador passa claudeCosts (cli.ts:258 passa []); `ginga cost --json` não existe (ginga: 'comando desconhecido: cost'), então só o fallback spentUsd roda; run.ts:341 usa ru
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:100-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; taken inclui pinga queue + pinga_task do bundle, mas não tasks/T*/ do repo; tests/red.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico (3 receipts, 20000 chars, LEARNINGS), lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts:333 imprime JSON do redPlan; validação de tests_frozen em src/red.ts; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
  - ok [TASK-12] src/cost_cap.ts loadRoundCapUsd/isPaidModel/checkPaidCall; guardas antes de adapter.run em run.ts:339-356, judge.ts:231-242, replan.ts antes de options.planner; tests/cost_cap_wiring.test.ts passa; ressalva: since=agora em judge/replan e claudeCosts nunca alimentado (ver AC)
- resumo do judge: Não há regressão: HEAD tem 258 pass e as mesmas 4 falhas da main (judge CLI sem PLAN/inexistente, pipeline/lane sem args). As TASKs 02, 03, 05, 06, 09, 10, 11 e 12 estão cumpridas e os achados anteriores (guarda do planner antes da chamada, JSON do red, taken com pinga_task do bundle, prove-red com erro) foram corrigidos em 099d16e. O AC do teto de todos os papéis ainda não é atendido na prática: 

### 10:45 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD d4487601 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T090207.log)
  - FALHA [TASK-05] REGRESSÃO learning promote registrado em src/verbs/learning.ts:35 sem caso em tests/cli_verbs.test.ts CASES: falham cli_verbs.test.ts:103 ('todo verbo tem caso') e 'learning promote --json devolve o mesmo JSON' (passavam na main); item de Inbox 'promover?' ausente (grep 'promover' em src vazio)
  - FALHA [TASK-06] src/lessons.ts sem findLessons; sem verbo 'lessons find' em src/verbs/learning.ts; tests/lessons_find.test.ts falha
  - FALHA [TASK-08] src/lessons_import.ts inexistente; sem verbo 'lessons import'; tests/lessons_import.test.ts falha
  - FALHA [TASK-10] src/handoff/policy.ts inexistente; sem lint de [handoff] em src/lint; tests/handoff_policy.test.ts falha
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; buildHandoff sem modo sessão; tests/handoff_session.test.ts falha
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha
  - FALHA [TASK-14] skills/handoff/ inexistente; tests/skill_handoff.test.ts falha
  - FALHA [TASK-15] contrib/claude-mod-handoff/ inexistente; src/install/adapters/claude.ts sem hooks de handoff; tests/install_handoff_claude.test.ts falha
  - FALHA [AC-lesson-encontrada-pelo-touch] promote existe, mas findLessons/lessons find ausentes (TASK-06)
  - FALHA [AC-toda-acao-como-verbo] REGRESSÃO lessons import ausente; learning promote sem caso em cli_verbs.test.ts quebra 2 testes que passavam na main
  - FALHA [AC-handoff-automatico] TASK-10 a 15 sem código; src/handoff/ não existe
  - ok [TASK-01] src/plan_log.ts:27,60; src/notify/router.ts; tests/plan_log.test.ts passa
  - ok [TASK-02] src/lint/learnings.ts:19; src/lint/index.ts; tests/lint_learnings.test.ts passa
  - ok [TASK-03] src/handoff.ts:141 buildHandoff; src/verbs/handoff.ts:46 HANDOFF_VERBS; tests/handoff.test.ts passa
  - ok [TASK-04] tests/e2e/investigation.test.ts e fixtures passam; TASK só de teste
  - ok [TASK-16] src/handoff.ts, src/verbs/handoff.ts; tests/handoff_full.test.ts passa
  - ok [TASK-17] tests/cli_verbs.test.ts:98 caso handoff; teste de comparação do handoff passa
  - ok [AC-handoff-sem-LLM] buildHandoff determinístico; handoff.test.ts e handoff_full.test.ts passam
  - ok [AC-log-learnings-investigation] plan_log.ts, lint/learnings.ts, e2e/investigation.test.ts passam
- resumo do judge: HEAD tem 01, 02, 03, 04, 16 e 17 prontas. Faltam 06 e 08 (lessons find/import) e 10 a 15 (handoff automático): 43 testes congelados falham de 538. A TASK-05 introduz regressão: learning promote entra no registry sem caso em tests/cli_verbs.test.ts, e 2 testes que passavam na main falham. ACs de lessons por touch, verbos e handoff automático não cumpridos.

### 10:55 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 099d16e4 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T095210.log)
  - FALHA [AC] src/judge.ts:232 e src/replan.ts + src/cli.ts:253 usam since=agora, então o gasto acumulado do papel judge/planner é ~0; nenhum chamador passa claudeCosts (cli.ts:258 passa []); `ginga cost --json` não existe (ginga: 'comando desconhecido: cost'), então só o fallback spentUsd roda; run.ts:341 usa ru
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:100-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; taken inclui pinga queue + pinga_task do bundle, mas não tasks/T*/ do repo; tests/red.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico (3 receipts, 20000 chars, LEARNINGS), lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts:333 imprime JSON do redPlan; validação de tests_frozen em src/red.ts; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
  - ok [TASK-12] src/cost_cap.ts loadRoundCapUsd/isPaidModel/checkPaidCall; guardas antes de adapter.run em run.ts:339-356, judge.ts:231-242, replan.ts antes de options.planner; tests/cost_cap_wiring.test.ts passa; ressalva: since=agora em judge/replan e claudeCosts nunca alimentado (ver AC)
- resumo do judge: Não há regressão: HEAD tem 258 pass e as mesmas 4 falhas da main (judge CLI sem PLAN/inexistente, pipeline/lane sem args). As TASKs 02, 03, 05, 06, 09, 10, 11 e 12 estão cumpridas e os achados anteriores (guarda do planner antes da chamada, JSON do red, taken com pinga_task do bundle, prove-red com erro) foram corrigidos em 099d16e. O AC do teto de todos os papéis ainda não é atendido na prática: 

### 11:32 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 11:59 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 12:32 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 099d16e4 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T095210.log)
  - FALHA [AC] src/judge.ts:232 e src/replan.ts + src/cli.ts:253 usam since=agora, então o gasto acumulado do papel judge/planner é ~0; nenhum chamador passa claudeCosts (cli.ts:258 passa []); `ginga cost --json` não existe (ginga: 'comando desconhecido: cost'), então só o fallback spentUsd roda; run.ts:341 usa ru
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:100-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; taken inclui pinga queue + pinga_task do bundle, mas não tasks/T*/ do repo; tests/red.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico (3 receipts, 20000 chars, LEARNINGS), lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts:333 imprime JSON do redPlan; validação de tests_frozen em src/red.ts; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
  - ok [TASK-12] src/cost_cap.ts loadRoundCapUsd/isPaidModel/checkPaidCall; guardas antes de adapter.run em run.ts:339-356, judge.ts:231-242, replan.ts antes de options.planner; tests/cost_cap_wiring.test.ts passa; ressalva: since=agora em judge/replan e claudeCosts nunca alimentado (ver AC)
- resumo do judge: Não há regressão: HEAD tem 258 pass e as mesmas 4 falhas da main (judge CLI sem PLAN/inexistente, pipeline/lane sem args). As TASKs 02, 03, 05, 06, 09, 10, 11 e 12 estão cumpridas e os achados anteriores (guarda do planner antes da chamada, JSON do red, taken com pinga_task do bundle, prove-red com erro) foram corrigidos em 099d16e. O AC do teto de todos os papéis ainda não é atendido na prática: 

### 12:49 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 13:13 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 6882b196 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T131214.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner usa since=agora e claudeCosts:[] (gasto medido ~0, teto só barra se a estimativa sozinha passar dele); o planner roda em cli.ts:268 antes de replan(), então a guarda de src/replan.ts:62-77 chega depois do gasto; fallback do planner sem nova checagem; claudeCosts 
  - FALHA [TASK-12] checkPaidCall/loadRoundCapUsd/isPaidModel em src/cost_cap.ts e guardas em run.ts/judge.ts/replan.ts passam em tests/cost_cap_wiring.test.ts, mas na CLI real o planner é chamado (cli.ts:268) antes de replan() e a guarda da CLI usa since=agora e claudeCosts:[], então o gasto real do planner não é medi
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:95-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; tests/red.test.ts passa; taken (red.ts:100-118) não inclui tasks/T*/ do repo
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico, lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/red.ts valida cada tests_frozen; cli.ts command red imprime JSON; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: Sem regressão: as 4 falhas de HEAD (judge CLI ×2, pipeline/lane sem args) também ocorrem na main. TASKs 02, 03, 05, 06, 09, 10 e 11 estão cumpridas. O AC do teto de custo de todos os papéis não é atendido na prática: executor e judge estão guardados, mas o planner do `manda replan` é chamado antes da guarda da lib e a guarda da CLI mede o gasto desde 'agora' com claudeCosts vazio, e `ginga cost --

### 13:27 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 13:42 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 6882b196 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T131214.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner usa since=agora e claudeCosts:[] (gasto medido ~0, teto só barra se a estimativa sozinha passar dele); o planner roda em cli.ts:268 antes de replan(), então a guarda de src/replan.ts:62-77 chega depois do gasto; fallback do planner sem nova checagem; claudeCosts 
  - FALHA [TASK-12] checkPaidCall/loadRoundCapUsd/isPaidModel em src/cost_cap.ts e guardas em run.ts/judge.ts/replan.ts passam em tests/cost_cap_wiring.test.ts, mas na CLI real o planner é chamado (cli.ts:268) antes de replan() e a guarda da CLI usa since=agora e claudeCosts:[], então o gasto real do planner não é medi
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:95-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; tests/red.test.ts passa; taken (red.ts:100-118) não inclui tasks/T*/ do repo
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico, lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/red.ts valida cada tests_frozen; cli.ts command red imprime JSON; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: Sem regressão: as 4 falhas de HEAD (judge CLI ×2, pipeline/lane sem args) também ocorrem na main. TASKs 02, 03, 05, 06, 09, 10 e 11 estão cumpridas. O AC do teto de custo de todos os papéis não é atendido na prática: executor e judge estão guardados, mas o planner do `manda replan` é chamado antes da guarda da lib e a guarda da CLI mede o gasto desde 'agora' com claudeCosts vazio, e `ginga cost --

### 13:58 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 14:06 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 6882b196 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T131214.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner usa since=agora e claudeCosts:[] (gasto medido ~0, teto só barra se a estimativa sozinha passar dele); o planner roda em cli.ts:268 antes de replan(), então a guarda de src/replan.ts:62-77 chega depois do gasto; fallback do planner sem nova checagem; claudeCosts 
  - FALHA [TASK-12] checkPaidCall/loadRoundCapUsd/isPaidModel em src/cost_cap.ts e guardas em run.ts/judge.ts/replan.ts passam em tests/cost_cap_wiring.test.ts, mas na CLI real o planner é chamado (cli.ts:268) antes de replan() e a guarda da CLI usa since=agora e claudeCosts:[], então o gasto real do planner não é medi
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts passa
  - ok [TASK-03] src/red.ts:95-232 copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED, test_passed_on_base; tests/red.test.ts passa; taken (red.ts:100-118) não inclui tasks/T*/ do repo
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico, lint falho -> blocked; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/red.ts valida cada tests_frozen; cli.ts command red imprime JSON; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red ligado com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
- resumo do judge: Sem regressão: as 4 falhas de HEAD (judge CLI ×2, pipeline/lane sem args) também ocorrem na main. TASKs 02, 03, 05, 06, 09, 10 e 11 estão cumpridas. O AC do teto de custo de todos os papéis não é atendido na prática: executor e judge estão guardados, mas o planner do `manda replan` é chamado antes da guarda da lib e a guarda da CLI mede o gasto desde 'agora' com claudeCosts vazio, e `ginga cost --

### 14:23 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 15:26 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 47ebe2ea (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T152427.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner com since=agora e claudeCosts:[]; planner roda em cli.ts:268 sem nova checagem antes do fallback; extractTotalCostUsd inexistente em src/ (HEAD=47ebe2e test(T163): RED, sem commit de implementação)
  - FALHA [TASK-12] REGRESSÃO src/cost_cap.ts:40-44 spentUsd consulta session_v2 sem try/catch; com ~/.local/share/opencode/opencode.db vazio lança SQLiteError via checkPaidCall (cost_cap.ts:150) em run.ts:339 e cli.ts:258, mesmo sem [budget]; suíte vai de 4 falhas na main para 48 em HEAD (escalation, budget, run, e2e/two_runtim
  - FALHA [TASK-13] HEAD é só o RED (47ebe2e): extractTotalCostUsd ausente, cli.ts:257-263 inalterado; tests/replan_cli_cost.test.ts falha (3 no HOME limpo, 5 no HOME real); done_when não passa
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass
  - ok [TASK-03] src/red.ts; tests/red.test.ts 3 pass
  - ok [TASK-05] src/replan.ts buildReplanContext/replan corretos; tests/replan.test.ts passa com HOME limpo (falha só pelo crash de spentUsd com opencode.db vazio, atribuído à TASK-12)
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts 4 pass
  - ok [TASK-09] src/red.ts + cli.ts command red; tests/red_cli.test.ts 2 pass
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa com HOME limpo (no HOME real cai no crash de spentUsd em cost_cap.ts:44, atribuído à TASK-12)
- resumo do judge: Fail. A TASK-13 está só em RED, sem implementação. Por isso o planner do manda replan segue sem medir nem barrar o gasto real antes de cada chamada paga, e o AC do teto de todos os papéis não é atendido. Há também regressão: spentUsd lança SQLiteError quando o opencode.db existe sem a tabela session_v2 (vazio neste ambiente), o que derruba testes que passavam na main, de 4 para 48 falhas em HEAD. 

### 15:40 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 16:12 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 47ebe2ea (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T152427.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner com since=agora e claudeCosts:[]; planner roda em cli.ts:268 sem nova checagem antes do fallback; extractTotalCostUsd inexistente em src/ (HEAD=47ebe2e test(T163): RED, sem commit de implementação)
  - FALHA [TASK-12] REGRESSÃO src/cost_cap.ts:40-44 spentUsd consulta session_v2 sem try/catch; com ~/.local/share/opencode/opencode.db vazio lança SQLiteError via checkPaidCall (cost_cap.ts:150) em run.ts:339 e cli.ts:258, mesmo sem [budget]; suíte vai de 4 falhas na main para 48 em HEAD (escalation, budget, run, e2e/two_runtim
  - FALHA [TASK-13] HEAD é só o RED (47ebe2e): extractTotalCostUsd ausente, cli.ts:257-263 inalterado; tests/replan_cli_cost.test.ts falha (3 no HOME limpo, 5 no HOME real); done_when não passa
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass
  - ok [TASK-03] src/red.ts; tests/red.test.ts 3 pass
  - ok [TASK-05] src/replan.ts buildReplanContext/replan corretos; tests/replan.test.ts passa com HOME limpo (falha só pelo crash de spentUsd com opencode.db vazio, atribuído à TASK-12)
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts 4 pass
  - ok [TASK-09] src/red.ts + cli.ts command red; tests/red_cli.test.ts 2 pass
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa com HOME limpo (no HOME real cai no crash de spentUsd em cost_cap.ts:44, atribuído à TASK-12)
- resumo do judge: Fail. A TASK-13 está só em RED, sem implementação. Por isso o planner do manda replan segue sem medir nem barrar o gasto real antes de cada chamada paga, e o AC do teto de todos os papéis não é atendido. Há também regressão: spentUsd lança SQLiteError quando o opencode.db existe sem a tabela session_v2 (vazio neste ambiente), o que derruba testes que passavam na main, de 4 para 48 falhas em HEAD. 

### 16:32 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 16:41 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 47ebe2ea (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T152427.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner com since=agora e claudeCosts:[]; planner roda em cli.ts:268 sem nova checagem antes do fallback; extractTotalCostUsd inexistente em src/ (HEAD=47ebe2e test(T163): RED, sem commit de implementação)
  - FALHA [TASK-12] REGRESSÃO src/cost_cap.ts:40-44 spentUsd consulta session_v2 sem try/catch; com ~/.local/share/opencode/opencode.db vazio lança SQLiteError via checkPaidCall (cost_cap.ts:150) em run.ts:339 e cli.ts:258, mesmo sem [budget]; suíte vai de 4 falhas na main para 48 em HEAD (escalation, budget, run, e2e/two_runtim
  - FALHA [TASK-13] HEAD é só o RED (47ebe2e): extractTotalCostUsd ausente, cli.ts:257-263 inalterado; tests/replan_cli_cost.test.ts falha (3 no HOME limpo, 5 no HOME real); done_when não passa
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass
  - ok [TASK-03] src/red.ts; tests/red.test.ts 3 pass
  - ok [TASK-05] src/replan.ts buildReplanContext/replan corretos; tests/replan.test.ts passa com HOME limpo (falha só pelo crash de spentUsd com opencode.db vazio, atribuído à TASK-12)
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts 4 pass
  - ok [TASK-09] src/red.ts + cli.ts command red; tests/red_cli.test.ts 2 pass
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa com HOME limpo (no HOME real cai no crash de spentUsd em cost_cap.ts:44, atribuído à TASK-12)
- resumo do judge: Fail. A TASK-13 está só em RED, sem implementação. Por isso o planner do manda replan segue sem medir nem barrar o gasto real antes de cada chamada paga, e o AC do teto de todos os papéis não é atendido. Há também regressão: spentUsd lança SQLiteError quando o opencode.db existe sem a tabela session_v2 (vazio neste ambiente), o que derruba testes que passavam na main, de 4 para 48 falhas em HEAD. 

### 16:50 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 16:59 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 47ebe2ea (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T152427.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner com since=agora e claudeCosts:[]; planner roda em cli.ts:268 sem nova checagem antes do fallback; extractTotalCostUsd inexistente em src/ (HEAD=47ebe2e test(T163): RED, sem commit de implementação)
  - FALHA [TASK-12] REGRESSÃO src/cost_cap.ts:40-44 spentUsd consulta session_v2 sem try/catch; com ~/.local/share/opencode/opencode.db vazio lança SQLiteError via checkPaidCall (cost_cap.ts:150) em run.ts:339 e cli.ts:258, mesmo sem [budget]; suíte vai de 4 falhas na main para 48 em HEAD (escalation, budget, run, e2e/two_runtim
  - FALHA [TASK-13] HEAD é só o RED (47ebe2e): extractTotalCostUsd ausente, cli.ts:257-263 inalterado; tests/replan_cli_cost.test.ts falha (3 no HOME limpo, 5 no HOME real); done_when não passa
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass
  - ok [TASK-03] src/red.ts; tests/red.test.ts 3 pass
  - ok [TASK-05] src/replan.ts buildReplanContext/replan corretos; tests/replan.test.ts passa com HOME limpo (falha só pelo crash de spentUsd com opencode.db vazio, atribuído à TASK-12)
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts 4 pass
  - ok [TASK-09] src/red.ts + cli.ts command red; tests/red_cli.test.ts 2 pass
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa com HOME limpo (no HOME real cai no crash de spentUsd em cost_cap.ts:44, atribuído à TASK-12)
- resumo do judge: Fail. A TASK-13 está só em RED, sem implementação. Por isso o planner do manda replan segue sem medir nem barrar o gasto real antes de cada chamada paga, e o AC do teto de todos os papéis não é atendido. Há também regressão: spentUsd lança SQLiteError quando o opencode.db existe sem a tabela session_v2 (vazio neste ambiente), o que derruba testes que passavam na main, de 4 para 48 falhas em HEAD. 

### 17:10 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 17:17 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 47ebe2ea (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T152427.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner com since=agora e claudeCosts:[]; planner roda em cli.ts:268 sem nova checagem antes do fallback; extractTotalCostUsd inexistente em src/ (HEAD=47ebe2e test(T163): RED, sem commit de implementação)
  - FALHA [TASK-12] REGRESSÃO src/cost_cap.ts:40-44 spentUsd consulta session_v2 sem try/catch; com ~/.local/share/opencode/opencode.db vazio lança SQLiteError via checkPaidCall (cost_cap.ts:150) em run.ts:339 e cli.ts:258, mesmo sem [budget]; suíte vai de 4 falhas na main para 48 em HEAD (escalation, budget, run, e2e/two_runtim
  - FALHA [TASK-13] HEAD é só o RED (47ebe2e): extractTotalCostUsd ausente, cli.ts:257-263 inalterado; tests/replan_cli_cost.test.ts falha (3 no HOME limpo, 5 no HOME real); done_when não passa
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass
  - ok [TASK-03] src/red.ts; tests/red.test.ts 3 pass
  - ok [TASK-05] src/replan.ts buildReplanContext/replan corretos; tests/replan.test.ts passa com HOME limpo (falha só pelo crash de spentUsd com opencode.db vazio, atribuído à TASK-12)
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts 4 pass
  - ok [TASK-09] src/red.ts + cli.ts command red; tests/red_cli.test.ts 2 pass
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa com HOME limpo (no HOME real cai no crash de spentUsd em cost_cap.ts:44, atribuído à TASK-12)
- resumo do judge: Fail. A TASK-13 está só em RED, sem implementação. Por isso o planner do manda replan segue sem medir nem barrar o gasto real antes de cada chamada paga, e o AC do teto de todos os papéis não é atendido. Há também regressão: spentUsd lança SQLiteError quando o opencode.db existe sem a tabela session_v2 (vazio neste ambiente), o que derruba testes que passavam na main, de 4 para 48 falhas em HEAD. 

### 17:32 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 17:50 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 47ebe2ea (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T152427.log)
  - FALHA [AC] src/cli.ts:257-263 guarda do planner com since=agora e claudeCosts:[]; planner roda em cli.ts:268 sem nova checagem antes do fallback; extractTotalCostUsd inexistente em src/ (HEAD=47ebe2e test(T163): RED, sem commit de implementação)
  - FALHA [TASK-12] REGRESSÃO src/cost_cap.ts:40-44 spentUsd consulta session_v2 sem try/catch; com ~/.local/share/opencode/opencode.db vazio lança SQLiteError via checkPaidCall (cost_cap.ts:150) em run.ts:339 e cli.ts:258, mesmo sem [budget]; suíte vai de 4 falhas na main para 48 em HEAD (escalation, budget, run, e2e/two_runtim
  - FALHA [TASK-13] HEAD é só o RED (47ebe2e): extractTotalCostUsd ausente, cli.ts:257-263 inalterado; tests/replan_cli_cost.test.ts falha (3 no HOME limpo, 5 no HOME real); done_when não passa
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass
  - ok [TASK-03] src/red.ts; tests/red.test.ts 3 pass
  - ok [TASK-05] src/replan.ts buildReplanContext/replan corretos; tests/replan.test.ts passa com HOME limpo (falha só pelo crash de spentUsd com opencode.db vazio, atribuído à TASK-12)
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts 4 pass
  - ok [TASK-09] src/red.ts + cli.ts command red; tests/red_cli.test.ts 2 pass
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts lê receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa com HOME limpo (no HOME real cai no crash de spentUsd em cost_cap.ts:44, atribuído à TASK-12)
- resumo do judge: Fail. A TASK-13 está só em RED, sem implementação. Por isso o planner do manda replan segue sem medir nem barrar o gasto real antes de cada chamada paga, e o AC do teto de todos os papéis não é atendido. Há também regressão: spentUsd lança SQLiteError quando o opencode.db existe sem a tabela session_v2 (vazio neste ambiente), o que derruba testes que passavam na main, de 4 para 48 falhas em HEAD. 

### 18:07 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 18:24 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD f968019c (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T182336.log)
  - FALHA [TASK-03] src/red.ts:95-230 itera todas as TASKs do bundle sem filtrar por repo (TASK pede 'cada TASK do repo'); em PLAN multi-repo aloca/prova RED de TASKs do ginga e src/red.ts:165-173 aborta por tests_frozen ausente em frozen/manda; src/red.ts:161 lança caminho fixo 'tests/frozen.test.ts'; src/red.ts:209 g
  - FALHA [TASK-09] src/cli.ts (command red) chama redPlan e valida tests_frozen, mas herda a falta de filtro por repo de src/red.ts:165-173: PLAN multi-repo falha com arquivo ausente de TASK de outro repo
  - FALHA [AC] Teto de custo de todos os papéis está ligado (run/judge/replan/CLI), mas 'manda red' não cumpre o escopo por repo em PLAN multi-repo (src/red.ts:95-230), impedindo a passada RED por código do próprio PLAN-0028
  - ok [TASK-02] src/alloc.ts:1-22; tests/alloc.test.ts passa
  - ok [TASK-05] src/replan.ts:44-110 (contexto determinístico, diff cortado em 20000, blocked se lint falha); tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts:17-70 capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-10] src/cli.ts command red com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts command replan lê receipts via pinga queue, judge/*.json, git diff main...plan/NNNN, [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
  - ok [TASK-12] src/cost_cap.ts:73-150 loadRoundCapUsd/isPaidModel/checkPaidCall; guarda antes do adapter em src/run.ts, src/judge.ts, src/replan.ts; tests/cost_cap_wiring.test.ts passa
  - ok [TASK-13] src/cost_cap.ts:152 extractTotalCostUsd; src/cli.ts since24, claudeCosts acumulado, checkPaidCall antes do primário e do fallback; tests/replan_cli_cost.test.ts passa
- resumo do judge: Teto de custo (TASK-06/12/13), replan (05/11), alocação de ids (02) e red na CLI (10) estão cumpridos e sem regressão; os 4 testes que falham na suíte também falham na main. TASK-03 e TASK-09 não cumprem o pedido: redPlan não filtra TASKs por repo (quebra em PLAN multi-repo), o erro de frozen ausente tem caminho fixo e o bloqueio por test_passed_on_base grava blocked:true no frontmatter em vez de 

### 18:28 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 603cf36a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T113017.log)
  - FALHA [TASK-08] bun test tests/lessons_import.test.ts: 2 fail (tests/lessons_import.test.ts:53 e :68) — importLessons (src/lessons_import.ts:10) cria 2 em vez de 3 LESSON-*.md da fixture de 3 entradas; idempotência skipped:3 também falha
  - FALHA [TASK-10] src/handoff/policy.ts e src/lint/project_toml.ts não existem; tests/handoff_policy.test.ts falha (parseHandoffCfg/decideHandoff ausentes); só o commit RED ae4da1d
  - FALHA [TASK-11] src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha (redact, buildHandoff modo sessão com trigger/runtime/depth/notes e 7 seções); só RED 98772d0
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha (runHook, transcriptUsage); só RED ada456f
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts inexistentes; tests/handoff_open.test.ts falha (openSession); só RED f62cbdb
  - FALHA [TASK-14] skills/handoff/ não existe (ENOENT em tests/skill_handoff.test.ts:67); 3 testes em fail; só RED 44f5c05
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook handoff e contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 testes); só RED 3d81e7a
  - FALHA [AC] ACs de handoff sem LLM, log.md/LEARNINGS.md, investigation e lessons por touch estão cumpridos; 'toda ação como verbo' parcial (lessons import incorreto) e a emenda do handoff automático (idle/context, hook, --open, skill, adapter Claude) não implementada
  - ok [TASK-01] src/plan_log.ts:27,60 + gancho em src/notify/router.ts; bun test tests/plan_log.test.ts 6 pass
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings, ligado em src/lint/index.ts; tests/lint_learnings.test.ts 9 pass
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts:56; tests/handoff.test.ts 6 pass
  - ok [TASK-04] tests/e2e/investigation.test.ts 3 pass com fixtures/investigation
  - ok [TASK-05] src/lessons.ts:217 promote; verbo 'learning promote' em src/verbs/learning.ts:66; tests/learning_promote.test.ts 4 pass
  - ok [TASK-06] src/lessons.ts:112 findLessons; verbo 'lessons find' em src/verbs/learning.ts:72; tests/lessons_find.test.ts 4 pass
  - ok [TASK-16] tests/handoff_full.test.ts 7 pass + tests/handoff.test.ts 6 pass; src/handoff.ts com git por repo, estado de fila e frontmatter
  - ok [TASK-17] tests/cli_verbs.test.ts 37 pass, caso handoff coberto; src/verbs/handoff.ts devolve path relativo
- resumo do judge: TASK-01..06, 16 e 17 estão cumpridas e verdes, sem regressão (cli_verbs e frozen T142/T143 passam). TASK-08 falha 2 testes (importa 2 de 3 entradas). TASK-10..15 (política decideHandoff, redact/modo sessão, hook, --open, skill, adapter Claude) não têm implementação em HEAD, só os commits RED; a suíte completa tem 33 falhas, todas de testes novos dessas TASKs. Logo o handoff automático da emenda do

### 19:03 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD f8f1383b (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T190245.log)
  - FALHA [TASK-03] src/red.ts não filtra TASKs por repo; erro de frozen ausente com caminho fixo (~l.161); l.209 grava `blocked: true` em vez de `status: blocked`
  - FALHA [TASK-14] HEAD f8f1383 só tem o RED; src/red.ts sem a correção; 3 testes de tests/red_repo.test.ts falham
  - FALHA [TASK-15] tests/red_cli_repo.test.ts falha (exit 1) pois redPlan não filtra por repo
  - FALHA [AC] AC do teto cobre todos os papéis atendido; AC de manda red sem LLM em PLAN multi-repo não atendido (src/red.ts sem filtro por repo)
  - ok [TASK-02] src/alloc.ts; tests/alloc.test.ts passa
  - ok [TASK-05] src/replan.ts, src/cli.ts replan; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts comando red; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts spawnSync com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan lê receipts/judge/diff; tests/replan_cli.test.ts passa
  - ok [TASK-12] checkPaidCall ligado em src/run.ts:339, src/judge.ts:240, src/replan.ts:67; tests/cost_cap_wiring.test.ts passa
  - ok [TASK-13] src/cli.ts:256-302 janela 24h, extractTotalCostUsd, checagem antes da primária e do fallback; tests/replan_cli_cost.test.ts passa
- resumo do judge: Teto de custo (TASK-06/12/13), alloc, replan e red na CLI estão ok no HEAD. Reprova porque T164/T165 estão só em RED: src/red.ts ainda não filtra por repo, o erro de frozen usa caminho fixo e grava blocked:true em vez de status: blocked. Os 8 testes que falham no HEAD não são regressão: 4 são os testes RED novos e 4 (judge_blind/pipeline) também falham na main por causa do guard de agente LLM.

### 19:25 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 0d7ec522 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T192409.log)
  - FALHA [TASK-02] src/alloc.ts cumpre a interface e tests/alloc.test.ts passa, mas src/red.ts:~100-125 monta `taken` só de `pinga queue --json` e das TASKs do próprio PLAN já filtradas por repo; nenhum código varre `tasks/T*/` (46 pastas, até T165) nem os `TASK-*.md` de outros PLANs, como pede o 'Fazer' — risco de co
  - ok [TASK-03] src/red.ts redPlan: copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit `test(T<N>): RED`; status: blocked + test_passed_on_base; tests/red.test.ts e red_repo.test.ts passam
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico (diff 20000, 3 receipts, LEARNINGS), replan() bloqueia se lint falha; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd (opencode.db read-only + claudeCosts, try/catch); tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts command red chama redPlan, JSON com as TASKs, valida cada tests_frozen citando o caminho; tests/red_cli.test.ts passa
  - ok [TASK-10] src/cli.ts command red com Bun.spawnSync env: process.env para pinga e git
  - ok [TASK-11] src/cli.ts command replan lê receipts (pinga queue), judge/*.json e git diff main...plan/NNNN; [roles] planner com fallback opencode; tests/replan_cli.test.ts passa
  - ok [TASK-12] src/cost_cap.ts loadRoundCapUsd/isPaidModel/checkPaidCall; guarda antes do adapter em src/run.ts, src/judge.ts e src/replan.ts; tests/cost_cap_wiring.test.ts passa
  - ok [TASK-13] src/cli.ts replan: since24h, claudeCosts via extractTotalCostUsd, checkPaidCall antes do planner primário e do fallback, repassa model/since/claudeCosts; tests/replan_cli_cost.test.ts passa. Obs.: a guarda interna de replan() soma o custo do próprio planner mais estimativa e pode bloquear falsamente
  - ok [TASK-14] src/red.ts filtra bundle.tasks por repo, lança srcPath real, grava status: blocked; tests/red_repo.test.ts passa
  - ok [TASK-15] tests/red_cli_repo.test.ts passa; CLI passa repo a redPlan que filtra por repo
- resumo do judge: Teto de custo ligado a executor, judge e planner, e red/replan na CLI funcionam; testes das TASKs passam e as 4 falhas da suíte (judge/pipeline/lane exit 2) também existem na main, sem regressão. Reprovado só na TASK-02: a montagem de `taken` não varre tasks/T*/ nem os TASK-*.md de outros PLANs, e redPlan pode colidir ids de pinga_task.

### 19:57 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 65d76293 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T195609.log)
  - FALHA [TASK-11] src/handoff/redact.ts não existe; tests/handoff_session.test.ts e redact em RED (7 seções/frontmatter trigger ausentes em src/handoff.ts)
  - FALHA [TASK-12] src/handoff/hook.ts e transcript_usage.ts não existem; tests/handoff_hook.test.ts em RED
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts não existem; tests/handoff_open.test.ts em RED
  - FALHA [TASK-14] diretório skills/ não existe; tests/skill_handoff.test.ts em RED
  - FALHA [TASK-15] contrib/claude-mod-handoff/ ausente, adapter claude sem hooks de handoff; tests/install_handoff_claude.test.ts em RED
  - FALHA [AC] AC de handoff/log/learnings/lessons cumpridos, mas a emenda do handoff automático (idle/context, hook, --open, adapter) não está implementada: 21 testes RED em TASK-11 a 15
  - ok [TASK-01] src/plan_log.ts:27,60; src/notify/router.ts appendPlanLog em routeEvents; tests/plan_log.test.ts passa
  - ok [TASK-02] src/lint/learnings.ts, src/lint/index.ts lintPlanLearnings; tests/lint_learnings.test.ts e testes de lint existentes passam
  - ok [TASK-03] src/handoff.ts:141 buildHandoff, src/verbs/handoff.ts, registry; tests/handoff.test.ts passa
  - ok [TASK-04] tests/e2e/investigation.test.ts passa
  - ok [TASK-05] src/lessons.ts:217 promote; tests/learning_promote.test.ts passa
  - ok [TASK-06] src/lessons.ts:112 findLessons; tests/lessons_find.test.ts passa
  - ok [TASK-08] src/lessons_import.ts:78 importLessons; tests/lessons_import.test.ts passa
  - ok [TASK-10] src/handoff/policy.ts:66 decideHandoff, src/lint/project_toml.ts; tests/handoff_policy.test.ts passa
  - ok [TASK-16] tests/handoff_full.test.ts passa
  - ok [TASK-17] tests/cli_verbs.test.ts passa com caso handoff
- resumo do judge: TASKs 01-06, 08, 10, 16 e 17 estão cumpridas em HEAD e sem regressão. TASKs 11 a 15 (handoff automático: redact, hook, open, skill, adapter Claude) só têm o commit RED, sem implementação, então o PLAN não está completo.

### 20:38 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD d0d1b852 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T203714.log)
  - FALHA [TASK-13] src/handoff/open.ts e open_claude.ts não existem; tests/handoff_open.test.ts: 3 fail (openSession)
  - FALHA [TASK-14] diretório skills/ inexistente (sem skills/handoff/SKILL.md, scripts/handoff.ts, references/formato.md); tests/skill_handoff.test.ts falha
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook de handoff; contrib/claude-mod-handoff/ inexistente (só hermes-plugin e systemd); tests/install_handoff_claude.test.ts falha
  - FALHA [AC] ACs de handoff <PLAN>, log.md/LEARNINGS/investigation, lessons por touch e verbos estão atendidos; a emenda do handoff automático com abertura de sessão e adapter Claude depende das TASK-13/14/15, ausentes
  - ok [TASK-01] src/plan_log.ts:27,60 formatLogLine/appendPlanLog; src/notify/router.ts:94 chama appendPlanLog; tests/plan_log.test.ts verde
  - ok [TASK-02] src/lint/learnings.ts:19 lintLearnings; src/lint/index.ts; tests/lint_learnings.test.ts verde
  - ok [TASK-03] src/handoff.ts:150 buildHandoff; src/verbs/handoff.ts HANDOFF_VERBS registrado em src/verbs/registry.ts:56; tests/handoff.test.ts verde
  - ok [TASK-04] tests/e2e/investigation.test.ts e fixtures/investigation presentes e verdes
  - ok [TASK-05] src/lessons.ts:217 promote; src/verbs/learning.ts LEARNING_VERBS (registry.ts:57); tests/learning_promote.test.ts verde
  - ok [TASK-06] src/lessons.ts:112 findLessons; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts:58,66 parseHandoffCfg/decideHandoff; src/lint/project_toml.ts; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts:11; buildHandoff aceita trigger/runtime/notes/transcript/depth; tests/handoff_session.test.ts verde
  - ok [TASK-12] src/handoff/hook.ts runHook; src/handoff/transcript_usage.ts:7; src/verbs/handoff.ts:5 importa runHook; tests/handoff_hook.test.ts verde
  - ok [TASK-16] src/handoff.ts (repos, fila, ordem de learnings, frontmatter); tests/handoff_full.test.ts verde
  - ok [TASK-17] src/verbs/handoff.ts devolve path relativo ao root; tests/cli_verbs.test.ts verde
- resumo do judge: TASKs 01-06, 08, 10-12, 16 e 17 cumpridas e verdes; TASK-13 (openSession), TASK-14 (skill handoff) e TASK-15 (adapter Claude e contrib) não foram implementadas, e os 10 testes que falham são exatamente os RED delas. Nenhuma regressão contra a main.

### 21:40 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 367ca185 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T213847.log)
  - FALHA [TASK-14] HEAD não tem skills/handoff/ (SKILL.md, scripts/handoff.ts, references/formato.md); a projeção em src/install/install.ts e skills/ estão só na worktree, sem commit; tests/skill_handoff.test.ts falha (3 fail)
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook de handoff; contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 fail)
  - FALHA [AC] Atendidos: handoff <PLAN> sem LLM, log.md e LEARNINGS, kind investigation, lessons por touch, verbos handoff/learning promote/lessons import. Não atendida: a emenda do handoff automático (skill handoff e adapter Claude com hooks Stop/UserPromptSubmit) depende das TASK-14 e TASK-15, ausentes em HEAD
  - ok [TASK-01] src/plan_log.ts (formatLogLine/appendPlanLog), gancho em src/notify/router.ts; tests/plan_log.test.ts verde
  - ok [TASK-02] src/lint/learnings.ts, src/lint/index.ts; tests/lint_learnings.test.ts verde
  - ok [TASK-03] src/handoff.ts buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts; tests/handoff.test.ts verde
  - ok [TASK-04] tests/e2e/investigation.test.ts e tests/fixtures/investigation/ verdes
  - ok [TASK-05] src/lessons.ts promote, src/verbs/learning.ts LEARNING_VERBS; tests/learning_promote.test.ts verde
  - ok [TASK-06] src/lessons.ts findLessons, verbo lessons find; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts importLessons idempotente por hash; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts decideHandoff/parseHandoffCfg, src/lint/project_toml.ts; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts, modo sessão em src/handoff.ts; tests/handoff_session.test.ts verde
  - ok [TASK-12] src/handoff/hook.ts runHook, src/handoff/transcript_usage.ts; tests/handoff_hook.test.ts verde
  - ok [TASK-13] src/handoff/open.ts openSession, src/handoff/open_claude.ts; tests/handoff_open.test.ts verde
  - ok [TASK-16] src/handoff.ts (repos, fila, ordem de learnings, frontmatter), src/verbs/handoff.ts; tests/handoff_full.test.ts verde
  - ok [TASK-17] src/verbs/handoff.ts devolve path relativo ao root; tests/cli_verbs.test.ts verde
- resumo do judge: TASKs 01-06, 08, 10-13, 16 e 17 cumpridas e verdes em HEAD. TASK-14 (skill handoff e projeção) e TASK-15 (adapter Claude e contrib) não estão em HEAD e seus testes RED seguem falhando; o trabalho da TASK-14 existe só como mudança não commitada na worktree. Nenhuma regressão contra a main, e o único outro fail da suíte (modo 755 do bin/ginga.ts) também ocorre na main.

### 22:13 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 0bdfc872 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T221150.log)
  - FALHA [TASK-02] src/red.ts: taken é montado antes de criar a worktree; na primeira execução tasks/T*/ não existe e não é varrido (nem root/<repo>/tasks); alloc.ts em si está correto
  - FALHA [TASK-16] src/red.ts: varredura de tasks/T* só ocorre se a worktree já existe, mas a worktree é criada depois do cálculo de taken; primeira execução não protege contra colisão; pinga_task de todo o bundle está incluído
  - ok [TASK-03] src/red.ts redPlan: filtra repo, copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED; tests/red.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext/replan com lint; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts command red valida tests_frozen e devolve JSON; tests/red_cli.test.ts passa
  - ok [TASK-10] manda red ligado na CLI com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan usa receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa
  - ok [TASK-12] checkPaidCall ligado em src/run.ts:339, src/judge.ts:240, src/replan.ts:67; tests/cost_cap_wiring.test.ts passa
  - ok [TASK-13] src/cli.ts:257-295 guarda antes do planner primário e do fallback, janela 24h, extractTotalCostUsd em src/cost_cap.ts:162; tests/replan_cli_cost.test.ts passa
  - ok [TASK-14] src/red.ts filtra bundle.tasks por repo, lança srcPath real, grava status: blocked; tests/red_repo.test.ts passa
  - ok [TASK-15] tests/red_cli_repo.test.ts passa com filtro de repo herdado de redPlan
- resumo do judge: Teto de custo, replan, red por repo e CLI estão cumpridos e a suíte só falha em 4 testes que já falham na main (sem regressão). Reprovado por um gap simples: o taken do redPlan não varre tasks/T*/ na primeira execução, pois a worktree é criada depois do cálculo (TASK-02/TASK-16).

### 22:32 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 0bdfc872 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T221150.log)
  - FALHA [TASK-02] src/red.ts: taken é montado antes de criar a worktree; na primeira execução tasks/T*/ não existe e não é varrido (nem root/<repo>/tasks); alloc.ts em si está correto
  - FALHA [TASK-16] src/red.ts: varredura de tasks/T* só ocorre se a worktree já existe, mas a worktree é criada depois do cálculo de taken; primeira execução não protege contra colisão; pinga_task de todo o bundle está incluído
  - ok [TASK-03] src/red.ts redPlan: filtra repo, copia frozen, gera tasks/T<N>/PLAN.md, prove-red, commit test(T<N>): RED; tests/red.test.ts passa
  - ok [TASK-05] src/replan.ts buildReplanContext/replan com lint; tests/replan.test.ts passa
  - ok [TASK-06] src/cost_cap.ts capCheck/spentUsd; tests/cost_cap.test.ts passa
  - ok [TASK-09] src/cli.ts command red valida tests_frozen e devolve JSON; tests/red_cli.test.ts passa
  - ok [TASK-10] manda red ligado na CLI com env: process.env; tests/red_cli.test.ts passa
  - ok [TASK-11] src/cli.ts replan usa receipts/judge/diff reais e [roles] planner com fallback; tests/replan_cli.test.ts passa
  - ok [TASK-12] checkPaidCall ligado em src/run.ts:339, src/judge.ts:240, src/replan.ts:67; tests/cost_cap_wiring.test.ts passa
  - ok [TASK-13] src/cli.ts:257-295 guarda antes do planner primário e do fallback, janela 24h, extractTotalCostUsd em src/cost_cap.ts:162; tests/replan_cli_cost.test.ts passa
  - ok [TASK-14] src/red.ts filtra bundle.tasks por repo, lança srcPath real, grava status: blocked; tests/red_repo.test.ts passa
  - ok [TASK-15] tests/red_cli_repo.test.ts passa com filtro de repo herdado de redPlan
- resumo do judge: Teto de custo, replan, red por repo e CLI estão cumpridos e a suíte só falha em 4 testes que já falham na main (sem regressão). Reprovado por um gap simples: o taken do redPlan não varre tasks/T*/ na primeira execução, pois a worktree é criada depois do cálculo (TASK-02/TASK-16).

### 22:55 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 367ca185 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T213847.log)
  - FALHA [TASK-14] HEAD não tem skills/handoff/ (SKILL.md, scripts/handoff.ts, references/formato.md); a projeção em src/install/install.ts e skills/ estão só na worktree, sem commit; tests/skill_handoff.test.ts falha (3 fail)
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook de handoff; contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 fail)
  - FALHA [AC] Atendidos: handoff <PLAN> sem LLM, log.md e LEARNINGS, kind investigation, lessons por touch, verbos handoff/learning promote/lessons import. Não atendida: a emenda do handoff automático (skill handoff e adapter Claude com hooks Stop/UserPromptSubmit) depende das TASK-14 e TASK-15, ausentes em HEAD
  - ok [TASK-01] src/plan_log.ts (formatLogLine/appendPlanLog), gancho em src/notify/router.ts; tests/plan_log.test.ts verde
  - ok [TASK-02] src/lint/learnings.ts, src/lint/index.ts; tests/lint_learnings.test.ts verde
  - ok [TASK-03] src/handoff.ts buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts; tests/handoff.test.ts verde
  - ok [TASK-04] tests/e2e/investigation.test.ts e tests/fixtures/investigation/ verdes
  - ok [TASK-05] src/lessons.ts promote, src/verbs/learning.ts LEARNING_VERBS; tests/learning_promote.test.ts verde
  - ok [TASK-06] src/lessons.ts findLessons, verbo lessons find; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts importLessons idempotente por hash; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts decideHandoff/parseHandoffCfg, src/lint/project_toml.ts; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts, modo sessão em src/handoff.ts; tests/handoff_session.test.ts verde
  - ok [TASK-12] src/handoff/hook.ts runHook, src/handoff/transcript_usage.ts; tests/handoff_hook.test.ts verde
  - ok [TASK-13] src/handoff/open.ts openSession, src/handoff/open_claude.ts; tests/handoff_open.test.ts verde
  - ok [TASK-16] src/handoff.ts (repos, fila, ordem de learnings, frontmatter), src/verbs/handoff.ts; tests/handoff_full.test.ts verde
  - ok [TASK-17] src/verbs/handoff.ts devolve path relativo ao root; tests/cli_verbs.test.ts verde
- resumo do judge: TASKs 01-06, 08, 10-13, 16 e 17 cumpridas e verdes em HEAD. TASK-14 (skill handoff e projeção) e TASK-15 (adapter Claude e contrib) não estão em HEAD e seus testes RED seguem falhando; o trabalho da TASK-14 existe só como mudança não commitada na worktree. Nenhuma regressão contra a main, e o único outro fail da suíte (modo 755 do bin/ginga.ts) também ocorre na main.

### 23:33 PLAN-0028-ciclo-autonomo-sem-operador · manda · plan/0028 · gate 2
- motivo: conflito no merge
- judge: pass no HEAD e6c3d161 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/manda-20261030T233120.log)
  - ok [AC] src/run.ts:339, src/judge.ts:240, src/replan.ts:67 e src/cli.ts:259/277 chamam checkPaidCall antes de cada chamada paga (executor, judge, planner primário e fallback); tests/cost_cap_wiring.test.ts 9 pass e tests/replan_cli_cost.test.ts 5 pass. Em src/cli.ts o replan() interno roda após o gasto do p
  - ok [TASK-02] src/alloc.ts allocTaskIds; tests/alloc.test.ts 3 pass; src/red.ts monta taken com fila, pinga_task de todo o bundle e tasks/T* da worktree criada antes (follow-up T167).
  - ok [TASK-03] src/red.ts redPlan copia frozen, gera tasks/T<N>/PLAN.md, roda prove-red, commita test(T<N>): RED e grava status blocked/test_passed_on_base; tests/red.test.ts 3 pass. Resíduo sem commit na worktree após TASK bloqueada.
  - ok [TASK-05] src/replan.ts buildReplanContext determinístico (diff truncado em 20000) e replan() com lint, bloqueando quando o planner ou o lint falha; tests/replan.test.ts 4 pass.
  - ok [TASK-06] src/cost_cap.ts capCheck e spentUsd (session_v2 + claudeCosts, try/catch para DB inválido); tests/cost_cap.test.ts 4 pass.
  - ok [TASK-09] src/cli.ts:~320-360 comando red com --repo/--root e saída JSON; src/red.ts valida cada tests_frozen e lança o caminho real; tests/red_cli.test.ts 2 pass.
  - ok [TASK-10] src/cli.ts comando red usa Bun.spawnSync com env: process.env para pinga e git; tests/red_cli.test.ts pass.
  - ok [TASK-11] src/cli.ts comando replan lê receipts via pinga queue, judge/*.json, git diff main...plan/NNNN e [roles] planner com fallback opencode; tests/replan_cli.test.ts 1 pass. git/pinga rodam com cwd=root, que pode não ser repo git no uso real.
  - ok [TASK-12] src/cost_cap.ts loadRoundCapUsd/isPaidModel/checkPaidCall; guarda ligada em src/run.ts:339, src/judge.ts:240 e src/replan.ts:67; tests/cost_cap_wiring.test.ts 9 pass, run.test.ts 15 pass.
  - ok [TASK-13] src/cli.ts:257-300 since=24h, claudeCosts acumulado via extractTotalCostUsd (src/cost_cap.ts), checagem antes do primário e do fallback, repasse de model/since/claudeCosts a replan(); tests/replan_cli_cost.test.ts 5 pass.
  - ok [TASK-14] src/red.ts filtra bundle.tasks por repo, lança srcPath real quando frozen ausente e grava status: blocked; tests/red_repo.test.ts 3 pass.
  - ok [TASK-15] src/cli.ts passa repo a redPlan; tests/red_cli_repo.test.ts 1 pass com PLAN multi-repo.
  - ok [TASK-16] src/red.ts varre tasks/T* da worktree e inclui pinga_task de todo o bundle em taken; tests/red_taken.test.ts 3 pass.
  - ok [TASK-17] src/red.ts cria a worktree (git worktree add) antes de montar taken; teste first-execution em tests/red_taken.test.ts passa. O frontmatter da TASK-17 não tem pinga_task: T167, embora tasks/T167/PLAN.md exista.
- resumo do judge: Todas as TASKs repo: manda e o AC de teto de custo estão cumpridos no HEAD. Os testes done_when de cada TASK passam. Na suíte completa, 4 testes falham (judge_blind, pipeline) e os mesmos 4 falham na main, então não há regressão. Pontos menores e não reprovadores: o replan() interno pode bloquear após o planner já ter gasto, git/pinga do replan rodam com cwd=root (não é repo git), a TASK-17 não te

### 23:46 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 367ca185 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261030T213847.log)
  - FALHA [TASK-14] HEAD não tem skills/handoff/ (SKILL.md, scripts/handoff.ts, references/formato.md); a projeção em src/install/install.ts e skills/ estão só na worktree, sem commit; tests/skill_handoff.test.ts falha (3 fail)
  - FALHA [TASK-15] src/install/adapters/claude.ts sem entradas de hook de handoff; contrib/claude-mod-handoff/ inexistente; tests/install_handoff_claude.test.ts falha (4 fail)
  - FALHA [AC] Atendidos: handoff <PLAN> sem LLM, log.md e LEARNINGS, kind investigation, lessons por touch, verbos handoff/learning promote/lessons import. Não atendida: a emenda do handoff automático (skill handoff e adapter Claude com hooks Stop/UserPromptSubmit) depende das TASK-14 e TASK-15, ausentes em HEAD
  - ok [TASK-01] src/plan_log.ts (formatLogLine/appendPlanLog), gancho em src/notify/router.ts; tests/plan_log.test.ts verde
  - ok [TASK-02] src/lint/learnings.ts, src/lint/index.ts; tests/lint_learnings.test.ts verde
  - ok [TASK-03] src/handoff.ts buildHandoff, src/verbs/handoff.ts HANDOFF_VERBS registrado em registry.ts; tests/handoff.test.ts verde
  - ok [TASK-04] tests/e2e/investigation.test.ts e tests/fixtures/investigation/ verdes
  - ok [TASK-05] src/lessons.ts promote, src/verbs/learning.ts LEARNING_VERBS; tests/learning_promote.test.ts verde
  - ok [TASK-06] src/lessons.ts findLessons, verbo lessons find; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts importLessons idempotente por hash; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts decideHandoff/parseHandoffCfg, src/lint/project_toml.ts; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts, modo sessão em src/handoff.ts; tests/handoff_session.test.ts verde
  - ok [TASK-12] src/handoff/hook.ts runHook, src/handoff/transcript_usage.ts; tests/handoff_hook.test.ts verde
  - ok [TASK-13] src/handoff/open.ts openSession, src/handoff/open_claude.ts; tests/handoff_open.test.ts verde
  - ok [TASK-16] src/handoff.ts (repos, fila, ordem de learnings, frontmatter), src/verbs/handoff.ts; tests/handoff_full.test.ts verde
  - ok [TASK-17] src/verbs/handoff.ts devolve path relativo ao root; tests/cli_verbs.test.ts verde
- resumo do judge: TASKs 01-06, 08, 10-13, 16 e 17 cumpridas e verdes em HEAD. TASK-14 (skill handoff e projeção) e TASK-15 (adapter Claude e contrib) não estão em HEAD e seus testes RED seguem falhando; o trabalho da TASK-14 existe só como mudança não commitada na worktree. Nenhuma regressão contra a main, e o único outro fail da suíte (modo 755 do bin/ginga.ts) também ocorre na main.

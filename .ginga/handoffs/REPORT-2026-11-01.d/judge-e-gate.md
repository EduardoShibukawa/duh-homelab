
### 00:21 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 4494731f (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261101T001925.log)
  - FALHA [AC handoff automático (idle/context)] src/handoff/transcript_usage.ts:21 lê event.usage; transcript real do Claude tem message.usage → contextTokens -1, lastApiTs null, nenhum gatilho dispara em uso real
  - FALHA [TASK-05] src/verbs/read.ts:77 inbox não tem item 'promover?' ao fechar o PLAN (pedido em TASK-05 Fazer)
  - FALHA [TASK-12] src/handoff/transcript_usage.ts:21 formato do usage não bate com transcript real (message.usage); fixtures tests/fixtures/transcripts/*.jsonl com usage na raiz mascaram o defeito
  - FALHA [TASK-14] skills/handoff/SKILL.md:10 aponta notes para tests/fixtures/handoff-session/bundle/notes.md e o comando documentado não passa --notes
  - ok [AC handoff sem LLM (ginga handoff <PLAN>)] src/handoff.ts buildHandoff determinístico, tests/handoff*.test.ts verdes
  - ok [AC log.md + LEARNINGS + investigation] src/plan_log.ts:50, router.ts:94, src/lint/learnings.ts, tests/e2e/investigation.test.ts
  - ok [AC learnings promovidos viram LESSON e são achados pelo touch] src/lessons.ts findLessons com title real; src/verbs/learning.ts:36 lista todas, --touch com vírgula
  - ok [TASK-01] src/plan_log.ts:41-75 idempotente por id; gancho em src/notify/router.ts:94
  - ok [TASK-02] src/lint/learnings.ts, src/lint/frontmatter.ts:21 kind change|investigation
  - ok [TASK-03] src/handoff.ts, src/verbs/handoff.ts, registry.ts:62; TASK-16/17 cobertas por handoff_full e cli_verbs verdes
  - ok [TASK-04] tests/e2e/investigation.test.ts com pinga verify real
  - ok [TASK-06] src/lessons.ts findLessons por prefixo/glob e repo; --symbol opcional ausente
  - ok [TASK-08] src/lessons_import.ts idempotente por hash, verbo lessons import em src/verbs/learning.ts:73
  - ok [TASK-10] src/handoff/policy.ts decideHandoff/parseHandoffCfg, src/lint/project_toml.ts valida mode
  - ok [TASK-11] src/handoff.ts truncamento 16000 (l.381), src/handoff/redact.ts, flags em src/verbs/handoff.ts
  - ok [TASK-13] src/handoff/open.ts, open_claude.ts: --bg, sem --resume/--fork-session; evento com trigger fixo 'cache' e depth 0
  - ok [TASK-15] src/install/adapters/claude.ts:12-15 hooks Stop+UserPromptSubmit, contrib/claude-mod-handoff/.claude-plugin e hooks/
  - ok [TASK-16] tests/handoff_full.test.ts verde; src/handoff.ts
  - ok [TASK-17] tests/cli_verbs.test.ts caso handoff verde
  - ok [TASK-18] src/verbs/handoff.ts run: inferPlan, --notes, --from-session; handoff_cli_session verde
  - ok [TASK-19] src/verbs/handoff.ts:22 HANDOFF_HOOK_VERB oculto em registry.ts:30; prepare persiste estado em hook.ts
  - ok [TASK-20] src/verbs/handoff.ts --open/--model chamam openSession; skills/handoff/scripts/handoff.ts parseia string
  - ok [TASK-21] src/install/install.ts sourceSkills/projectSkillsOutput; tests/skill_handoff_install.test.ts verde
  - ok [TASK-22] src/install/adapters/claude.ts:131-133,221-256 owned Stop+UserPromptSubmit e registro do mod
  - ok [TASK-23] tests/install_dryrun_guard.test.ts e tests/install/adapters.test.ts verdes na suíte completa (571 pass, 0 fail)
  - ok [TASK-24] src/verbs/learning.ts:36-52 todas as LESSONs com title, --touch por vírgula
  - ok [TASK-25] src/handoff/hook.ts resolveBundleRoot e model cfg??env??sonnet; src/events/validate.ts:63 aceita idle|manual; docs/events-v1.md:31
- resumo do judge: Suíte completa verde (571 pass, 0 fail) e sem regressão vs main. Reprova por TASK-12/AC handoff automático (grave): transcriptUsage lê usage na raiz, mas transcripts reais do Claude têm message.usage, então idle/context nunca disparam em uso real. Também: TASK-05 sem o item de Inbox 'promover?' e TASK-14 com SKILL.md apontando para caminho de fixture e sem passar --notes.

### 01:11 PLAN-0029-rota-de-falhas-e-disjuntor · manda · plan/0029 · gate 2
- motivo: conflito no merge
- judge: pass no HEAD 60eb4571 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0029-rota-de-falhas-e-disjuntor/judge/manda-20261101T010926.log)
  - ok [AC] 13 arquivos de teste das TASKs: 87 pass/0 fail; bun test completo 388 pass/4 fail, as mesmas 4 falhas da main (judge CLI x2, pipeline/lane x2), sem regressão; nenhum teste existente alterado no diff
  - ok [TASK-01] src/run_state.ts:7-60 classifyRun com probe_ok boolean|null; tests/run_state.test.ts passa. Ressalva: regex /5\d\d/ larga e fallthrough 'ok' por padrão
  - ok [TASK-02] src/probe.ts probeArgv/probe, stdin ignore, timeout 30s; tests/probe.test.ts passa
  - ok [TASK-03] src/breaker.ts model_breaker 10/30/120, half_open ao vencer, recordSuccess; tests/breaker.test.ts passa
  - ok [TASK-04] src/ladder.ts pickModel free primeiro, iceman só com mitRepo, pago só com allowPaid&&capOk; tests/ladder.test.ts passa
  - ok [TASK-05] src/runtime/env.ts runtimeEnv/SPAWN_STDIN aplicado via withDefaults em src/runtime/index.ts; tests/runtime_env.test.ts passa
  - ok [TASK-06] src/free_retry.ts freeRetryWait 15/30/60 e waitForFree com probe e stop; tests/free_retry.test.ts passa
  - ok [TASK-07] src/blocked.ts + src/failure_rules.json + 8 fixtures em tests/fixtures/blocked; tests/blocked.test.ts passa
  - ok [TASK-08] src/judge_pick.ts pula família do executor, breaker open e quota>=100; tests/judge_pick.test.ts passa
  - ok [TASK-09] src/attempt_watch.ts watchAttempt: travado→probe→kill→recordFailure→pickModel→waitForFree, emite attempt; probe ok agora não mata (linhas ~145-152); tests/attempt_watch.test.ts passa
  - ok [TASK-10] src/breaker_cli.ts breakerStatus/breakerReset e subcomando breaker em src/cli.ts; tests/breaker_cli.test.ts passa
  - ok [TASK-11] src/run.ts usa openStateDb/planNextAfterFailure/recordSuccess, next_model no attempt, sem evento duplicado quando a vigia vence; tests/attempt_watch_run.test.ts passa
  - ok [TASK-12] src/run.ts:~505-580 watchAttempt em paralelo com onPid/killByPid, breakerOf pulando modelo aberto em run.ts:~361-367; src/proc_sample.ts procSampler; adapters repassam onPid (pi.ts:202, opencode.ts:113, claude.ts:105, codex.ts:248); tests/attempt_watch_live.test.ts passa
  - ok [TASK-13] src/proc_sample.ts:121-135 probe real no sampler (probe_ok null/true/false, na_fila alcançável); attempt_watch.ts ownsOutcome/onTakeOver preserva waitForFree pós-kill; run.ts:464,523 logPath por tentativa como streamPath, sem GINGA_EVENTS; port.ts:103-133 tee do logPath; tests/attempt_watch_real.tes
- resumo do judge: Todas as TASKs com repo: manda (01-13) estão cumpridas em HEAD e os ACs seguem. Os achados graves do judge anterior (TASK-12) foram corrigidos pela TASK-13. bun test completo dá 388 pass/4 fail, as mesmas 4 falhas da main, sem regressão. Ressalvas menores: o limite de paciência não mata quando o probe passa, e a vigia encerra no primeiro 'ok'.

### 01:51 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD de9b6615 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261101T015027.log)
  - FALHA [TASK-05] promote existe em src/lessons.ts e verbs/learning.ts, mas inbox() em src/verbs/read.ts não gera o item 'promover?' pedido no Fazer (coberto pela TASK-27)
  - FALHA [TASK-12] src/handoff/transcript_usage.ts:17 lê só event.usage da raiz; o transcript real do Claude tem message.usage, então o hook nunca dispara no uso real
  - FALHA [TASK-26] tests/handoff_transcript_real.test.ts: 2 falhas; src/handoff/transcript_usage.ts:17 não lê message.usage (só RED commit 4f3804d)
  - FALHA [TASK-27] tests/inbox_promover.test.ts: 2 falhas; src/verbs/read.ts sem item 'promover?' e src/lessons.ts sem listLearnings (só RED commit de1b6cb)
  - FALHA [AC handoff automático (idle|context)] contextTokens=-1 e lastApiTs=null no transcript real (src/handoff/transcript_usage.ts:17), nenhum gatilho dispara
  - ok [TASK-01] src/plan_log.ts; tests/plan_log.test.ts verde
  - ok [TASK-02] src/lint/learnings.ts; tests/lint_learnings.test.ts verde
  - ok [TASK-03] src/handoff.ts; tests/handoff.test.ts verde
  - ok [TASK-04] tests/fixtures/investigation e e2e verdes
  - ok [TASK-06] findLessons em src/lessons.ts; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts e modo sessão; tests/handoff_session.test.ts verde
  - ok [TASK-13] src/handoff/open.ts e open_claude.ts; tests/handoff_open.test.ts verde
  - ok [TASK-14] skills/handoff/SKILL.md; tests/skill_handoff.test.ts verde
  - ok [TASK-15] src/install/adapters/claude.ts, contrib/claude-mod-handoff; testes de install verdes
  - ok [TASK-16] tests/handoff_full.test.ts verde
  - ok [TASK-17] src/verbs/handoff.ts registrado em registry.ts; testes de verbos verdes
  - ok [TASK-18] tests/handoff_cli_session.test.ts verde
  - ok [TASK-19] tests/handoff_cli_hook.test.ts verde
  - ok [TASK-20] tests/handoff_cli_open.test.ts verde
  - ok [TASK-21] tests/skill_handoff_install.test.ts verde
  - ok [TASK-22] tests/install_handoff_real.test.ts verde
  - ok [TASK-23] tests/install_dryrun_guard.test.ts verde
  - ok [TASK-24] tests/lessons_find_all.test.ts verde
  - ok [TASK-25] tests/handoff_hook_raiz.test.ts verde
  - ok [AC learnings promovidos viram LESSON e Planner acha pelo touch] promote/findLessons em src/lessons.ts, testes verdes
  - ok [AC log.md/LEARNINGS.md e kind investigation] plan_log.ts, lint/learnings.ts e e2e de investigation verdes
- resumo do judge: 575 testes passam e 4 falham, todos nos testes novos das TASK-26 e TASK-27 (só RED, sem implementação). O hook de handoff lê usage na raiz do transcript, e o transcript real do Claude tem message.usage, então o gatilho automático não funciona no uso real (grave). O Inbox não gera o item 'promover?', o que deixa a TASK-05 incompleta. Nenhuma regressão em relação à main.

### 01:55 PLAN-0029-rota-de-falhas-e-disjuntor · manda · plan/0029 · gate 0
- motivo: mergeado dcbeb52
- judge: pass no HEAD 60eb4571 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0029-rota-de-falhas-e-disjuntor/judge/manda-20261101T010926.log)
  - ok [AC] 13 arquivos de teste das TASKs: 87 pass/0 fail; bun test completo 388 pass/4 fail, as mesmas 4 falhas da main (judge CLI x2, pipeline/lane x2), sem regressão; nenhum teste existente alterado no diff
  - ok [TASK-01] src/run_state.ts:7-60 classifyRun com probe_ok boolean|null; tests/run_state.test.ts passa. Ressalva: regex /5\d\d/ larga e fallthrough 'ok' por padrão
  - ok [TASK-02] src/probe.ts probeArgv/probe, stdin ignore, timeout 30s; tests/probe.test.ts passa
  - ok [TASK-03] src/breaker.ts model_breaker 10/30/120, half_open ao vencer, recordSuccess; tests/breaker.test.ts passa
  - ok [TASK-04] src/ladder.ts pickModel free primeiro, iceman só com mitRepo, pago só com allowPaid&&capOk; tests/ladder.test.ts passa
  - ok [TASK-05] src/runtime/env.ts runtimeEnv/SPAWN_STDIN aplicado via withDefaults em src/runtime/index.ts; tests/runtime_env.test.ts passa
  - ok [TASK-06] src/free_retry.ts freeRetryWait 15/30/60 e waitForFree com probe e stop; tests/free_retry.test.ts passa
  - ok [TASK-07] src/blocked.ts + src/failure_rules.json + 8 fixtures em tests/fixtures/blocked; tests/blocked.test.ts passa
  - ok [TASK-08] src/judge_pick.ts pula família do executor, breaker open e quota>=100; tests/judge_pick.test.ts passa
  - ok [TASK-09] src/attempt_watch.ts watchAttempt: travado→probe→kill→recordFailure→pickModel→waitForFree, emite attempt; probe ok agora não mata (linhas ~145-152); tests/attempt_watch.test.ts passa
  - ok [TASK-10] src/breaker_cli.ts breakerStatus/breakerReset e subcomando breaker em src/cli.ts; tests/breaker_cli.test.ts passa
  - ok [TASK-11] src/run.ts usa openStateDb/planNextAfterFailure/recordSuccess, next_model no attempt, sem evento duplicado quando a vigia vence; tests/attempt_watch_run.test.ts passa
  - ok [TASK-12] src/run.ts:~505-580 watchAttempt em paralelo com onPid/killByPid, breakerOf pulando modelo aberto em run.ts:~361-367; src/proc_sample.ts procSampler; adapters repassam onPid (pi.ts:202, opencode.ts:113, claude.ts:105, codex.ts:248); tests/attempt_watch_live.test.ts passa
  - ok [TASK-13] src/proc_sample.ts:121-135 probe real no sampler (probe_ok null/true/false, na_fila alcançável); attempt_watch.ts ownsOutcome/onTakeOver preserva waitForFree pós-kill; run.ts:464,523 logPath por tentativa como streamPath, sem GINGA_EVENTS; port.ts:103-133 tee do logPath; tests/attempt_watch_real.tes
- resumo do judge: Todas as TASKs com repo: manda (01-13) estão cumpridas em HEAD e os ACs seguem. Os achados graves do judge anterior (TASK-12) foram corrigidos pela TASK-13. bun test completo dá 388 pass/4 fail, as mesmas 4 falhas da main, sem regressão. Ressalvas menores: o limite de paciência não mata quando o probe passa, e a vigia encerra no primeiro 'ok'.

### 02:05 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 0
- motivo: mergeado 813274d
- judge: pass no HEAD 61d80d84 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261101T020327.log)
  - ok [TASK-01] src/plan_log.ts + gancho em src/notify/router.ts:90; tests/plan_log.test.ts verde
  - ok [TASK-02] src/lint/learnings.ts, src/lint/index.ts lintPlanLearnings; tests/lint_learnings.test.ts verde
  - ok [TASK-03] src/handoff.ts, src/verbs/handoff.ts; tests/handoff.test.ts verde
  - ok [TASK-04] tests/e2e/investigation.test.ts e tests/fixtures/investigation verdes
  - ok [TASK-05] promote em src/lessons.ts; item 'promover?' em src/verbs/read.ts:84-90; tests/learning_promote.test.ts e inbox_promover.test.ts verdes
  - ok [TASK-06] findLessons em src/lessons.ts; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts, src/lint/project_toml.ts; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts e modo sessão em src/handoff.ts; tests/handoff_session.test.ts verde
  - ok [TASK-12] src/handoff/hook.ts + transcript_usage.ts:19 lê message.usage; tests/handoff_hook.test.ts verde
  - ok [TASK-13] src/handoff/open.ts openSession; tests/handoff_open.test.ts verde. Ressalva: evento do --open sai com trigger 'cache' e depth 0 fixos (open.ts:83), ajuste já adiado pela TASK-25
  - ok [TASK-14] skills/handoff/*; tests/skill_handoff.test.ts verde
  - ok [TASK-15] src/install/adapters/claude.ts, contrib/claude-mod-handoff; tests/install_handoff_claude.test.ts verde
  - ok [TASK-16] src/handoff.ts, src/verbs/handoff.ts; tests/handoff_full.test.ts verde
  - ok [TASK-17] caso handoff em tests/cli_verbs.test.ts; verbo devolve path relativo (src/verbs/handoff.ts relPath)
  - ok [TASK-18] src/verbs/handoff.ts args from_session/notes + inferPlan; tests/handoff_cli_session.test.ts verde
  - ok [TASK-19] HANDOFF_HOOK_VERB em registry.ts HIDDEN_VERBS; tests/handoff_cli_hook.test.ts verde
  - ok [TASK-20] src/verbs/handoff.ts --open chama openSession; tests/handoff_cli_open.test.ts verde
  - ok [TASK-21] sourceSkills em src/install/install.ts:279; tests/skill_handoff_install.test.ts verde
  - ok [TASK-22] src/install/adapters/claude.ts:131,222 (shouldProjectHooks, owned /hooks/Stop); tests/install_handoff_real.test.ts verde
  - ok [TASK-23] src/install/install.ts; tests/install_dryrun_guard.test.ts e tests/install/adapters.test.ts verdes
  - ok [TASK-24] src/verbs/learning.ts:44-51 devolve todas as lições com title; tests/lessons_find_all.test.ts verde
  - ok [TASK-25] resolveBundleRoot em src/handoff/hook.ts:57, model real em hook.ts:237, enum de trigger em src/events/validate.ts:63; tests/handoff_hook_raiz.test.ts verde
  - ok [TASK-26] src/handoff/transcript_usage.ts:19; tests/handoff_transcript_real.test.ts verde
  - ok [TASK-27] src/verbs/read.ts:84-90 e listLearnings em src/lessons.ts; tests/inbox_promover.test.ts verde
  - ok [AC handoff <PLAN> sem LLM] buildHandoff determinístico; tests/handoff.test.ts e handoff_full.test.ts verdes
  - ok [AC log.md + LEARNINGS.md + kind investigation] plan_log.ts, lint/learnings.ts, tests/e2e/investigation.test.ts verdes
  - ok [AC learnings promovidos viram LESSON e Planner acha pelo touch] promote/findLessons/importLessons; verbo devolve todas as lições com title; testes verdes
  - ok [AC handoff automático (idle|context)] decideHandoff + hook + transcriptUsage lendo message.usage + adapter Claude; testes verdes
  - ok [AC toda ação existe como verbo] HANDOFF_VERBS e LEARNING_VERBS no registry; tests/cli_verbs.test.ts cobre handoff, learning promote, lessons find, lessons import
- resumo do judge: bun test no HEAD: 579 pass, 0 fail, sem regressão em relação à main. Os dois graves e simples pendentes do judge anterior (TASK-26 message.usage, TASK-27 inbox promover?) estão implementados. Sobra uma ressalva simples: o evento do --open sai com trigger 'cache' e depth 0 fixos (src/handoff/open.ts:83), ajuste que a TASK-25 já adiou.

### 02:55 PLAN-0013-handoff-e-learnings · manda · plan/0013 · gate 0
- motivo: mergeado 85dd44d
- judge: pass no HEAD ab332abf (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/manda-20261101T025328.log)
  - ok [TASK-07] src/plan_lessons.ts:105 lessonsForTouch (ginga --json com fallback por arquivos, sem importar ginga); src/plan.ts collectTouch/appendLessonsSection + chamada antes do lint; tests/plan_lessons.test.ts 8 pass, inclui com/sem ginga no PATH; suite 396 pass e as mesmas 4 falhas pré-existentes da main (ju
  - ok [AC] AC 'learnings promovidos viram LESSON e o Planner os encontra pelo touch': lado manda coberto por src/plan.ts + src/plan_lessons.ts (seção ## Lessons no PLAN gerado); lado ginga (promote/find) julgado no repo dele
- resumo do judge: TASK-07 (única repo: manda) cumprida: lessonsForTouch com ginga --json e fallback equivalente, seção ## Lessons no PLAN, 8 testes passando. As 4 falhas da suíte completa existem igual na main, então não há regressão.

### 04:14 PLAN-0013-handoff-e-learnings · ginga · plan/0013 · gate 0
- motivo: mergeado eeb6cd5
- judge: pass no HEAD cee4bcc5 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0013-handoff-e-learnings/judge/ginga-20261101T041229.log)
  - ok [TASK-01] src/plan_log.ts:27,60 (formatLogLine/appendPlanLog); tests/plan_log.test.ts verde na suite 582/0
  - ok [TASK-02] tests/lint_learnings.test.ts verde; lint de LEARNINGS/kind presente em src/lint
  - ok [TASK-03] src/handoff.ts:207 buildHandoff; tests/handoff.test.ts verde
  - ok [TASK-04] tests/e2e presente e verde na suite 582/0
  - ok [TASK-05] src/lessons.ts:225 promote; src/verbs/learning.ts; tests/learning_promote.test.ts verde
  - ok [TASK-06] src/lessons.ts:117 findLessons; tests/lessons_find.test.ts verde
  - ok [TASK-08] src/lessons_import.ts:78 importLessons; tests/lessons_import.test.ts verde
  - ok [TASK-10] src/handoff/policy.ts:65,73 parseHandoffCfg/decideHandoff; tests/handoff_policy.test.ts verde
  - ok [TASK-11] src/handoff/redact.ts:11; tests/handoff_session.test.ts verde
  - ok [TASK-12] src/handoff/hook.ts:139 runHook; src/handoff/transcript_usage.ts:7; tests/handoff_hook.test.ts verde
  - ok [TASK-13] src/handoff/open.ts:73 openSession, open_claude.ts:27; tests/handoff_open.test.ts verde
  - ok [TASK-14] skills/handoff presente; tests/skill_handoff.test.ts verde
  - ok [TASK-15] tests/install_handoff_claude.test.ts verde
  - ok [TASK-16] tests/handoff_full.test.ts verde
  - ok [TASK-17] tests/cli_verbs.test.ts verde; src/verbs/registry.ts:62 ...HANDOFF_VERBS
  - ok [TASK-18] tests/handoff_cli_session.test.ts verde
  - ok [TASK-19] tests/handoff_cli_hook.test.ts verde
  - ok [TASK-20] tests/handoff_cli_open.test.ts verde
  - ok [TASK-21] tests/skill_handoff_install.test.ts verde
  - ok [TASK-22] tests/install_handoff_real.test.ts verde
  - ok [TASK-23] tests/install_dryrun_guard.test.ts verde
  - ok [TASK-24] tests/lessons_find_all.test.ts verde
  - ok [TASK-25] tests/handoff_hook_raiz.test.ts verde; src/events/validate.ts:63 enum trigger inclui idle/manual
  - ok [TASK-26] tests/handoff_transcript_real.test.ts verde
  - ok [TASK-27] src/lessons.ts:108 listLearnings exportado; tests/inbox_promover.test.ts verde
  - ok [TASK-28] src/handoff/open.ts:26-27,82-92 e open_claude.ts:43,46 usam o.trigger ?? 'manual' e o.depth ?? 0; src/verbs/handoff.ts:102-103 repassa; tests/handoff_open_trigger.test.ts 3 pass
  - ok [AC] ACs da SPEC cobertos: handoff sem LLM (src/handoff.ts), log.md automático + LEARNINGS (src/plan_log.ts, lint), promote/find (src/lessons.ts), verbos handoff/learning/lessons no registry (src/verbs/registry.ts:62-63); suite 582 pass/0 fail
- resumo do judge: Estado em HEAD cumpre as TASKs ginga do PLAN-0013 (suite completa 582 pass/0 fail). O diff main...HEAD é só a TASK-28 (trigger/depth reais no evento do --open), correto e testado, sem regressão.

### 04:15 PLAN-0028-ciclo-autonomo-sem-operador · ginga · plan/0028 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 6914cefb (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/ginga-20261101T041433.log)
  - FALHA [TASK-07] src/supervisor.ts:445 childArgv é código morto: parseSupervisorConfig (src/supervisor.ts:367) não lê [supervisor] mode e nada chama childArgv; src/tick.ts:330-343 rejeita --loop/--repo (exit 2). Só o teste unitário de childArgv passa
  - FALHA [AC] done_when: bun test do ginga = 581 pass, 0 fail; mas 'supervisor troca o operador pelo ginga tick --loop' não está cumprido (TASK-07)
  - ok [TASK-01] src/plan_phase.ts getPhase/setPhase com tabela plan_phase, transition emitido, replans incrementado; tests/plan_phase.test.ts 1 pass
  - ok [TASK-04] src/tick_plan.ts nextAction pura; src/tick.ts despacha via [commands] e chama setPhase; tests/tick_plan.test.ts 2 pass. cap_ok fixo em true (src/tick.ts), fora do escopo da TASK
  - ok [TASK-08] tests/e2e/autonomo.test.ts 2 pass (não pulado): approved→red→tasks→judge→done com receipt pass e commit na main via gate; falha 3x→replan; src/tick.ts semeia fase approved e lê veredito do judge
- resumo do judge: TASK-01, 04 e 08 cumpridas e a suíte do ginga está verde (581 pass), sem regressão. TASK-07 só entrega childArgv como função morta: o modo [supervisor] mode não é lido e ginga tick não aceita --loop/--repo, então o supervisor ainda não roda o tick.

### 05:45 PLAN-0028-ciclo-autonomo-sem-operador · ginga · plan/0028 · gate 0
- motivo: mergeado eeeb28c
- judge: pass no HEAD a583b6f0 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/judge/ginga-20261101T054331.log)
  - ok [TASK-01] src/plan_phase.ts (getPhase/setPhase); tests/plan_phase.test.ts verde
  - ok [TASK-04] src/tick_plan.ts nextAction pura; src/tick.ts aplica [commands], semeia approved, lê judge; tests/tick_plan.test.ts verde. Obs: red que falha também avança a fase (src/tick.ts ~607-626)
  - ok [TASK-07] src/supervisor.ts:455 childArgv tick/operador; tests/supervisor_tick_mode.test.ts verde
  - ok [TASK-08] tests/e2e/autonomo.test.ts + tests/fixtures/autonomo/ verdes; approved→done sem LLM
  - ok [TASK-20] src/supervisor.ts parseSupervisorConfig mode (padrão tick), spawn via childArgv; src/serve.ts:340 mode: supCfg.mode; src/tick.ts runTick aceita --loop/--repo com filtro e loop; tests/supervisor_tick_mode_wiring.test.ts verde
  - ok [AC] supervisor troca operador por ginga tick --loop (src/supervisor.ts, src/serve.ts, src/tick.ts); bun test completo do ginga: 589 pass, 0 fail
- resumo do judge: Todas as TASKs repo ginga (01, 04, 07, 08, 20) cumpridas em HEAD; suíte completa do ginga verde (589 pass); sem regressão. Observação menor: red que falha avança a fase sem repetir o red.

### 07:12 PLAN-0033-guard-de-segredos · ginga · plan/0033 · gate 0
- motivo: mergeado a6aee75
- judge: pass no HEAD d9111744 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0033-guard-de-segredos/judge/ginga-20261101T071032.log)
  - ok [AC] done_when parte ginga: bun test tests/guard_ => 93 pass/0 fail; unittest hermes 9 OK; bun test completo 685 pass; testes congelados idênticos a red/
  - ok [TASK-01] src/guard/core.ts, src/guard/deny.json; tests/guard_core.test.ts passa com cases.json
  - ok [TASK-02] src/guard/run.ts:17-120 (escopo, modos, guard_error fail-closed, hash sha256 no evento); src/guard/cli.ts check/redact/exit 64; guard_run.test.ts passa
  - ok [TASK-03] contrib/guard/pi.ts; tests/guard_pi.test.ts passa
  - ok [TASK-04] contrib/guard/opencode.ts e opencode-config/plugins/ginga-guard.ts; tests/guard_opencode.test.ts passa
  - ok [TASK-05] contrib/guard/hermes/guard_segredos/__init__.py + plugin.yaml; 9 testes unittest OK
  - ok [TASK-08] src/guard/sweep.ts:36 (só file/line/rule, sem trecho); src/guard/cli.ts verbo sweep exit 3/0; guard_sweep.test.ts passa
- resumo do judge: Todas as TASKs repo:ginga (01,02,03,04,05,08) cumpridas em HEAD; 93 testes TS e 9 Python passam, suíte completa verde (685), testes congelados idênticos aos de red/, diff main...HEAD só adiciona arquivos (+ *.pyc no .gitignore), sem regressão.

### 15:35 PLAN-0033-guard-de-segredos · manda · plan/0033 · gate 2
- motivo: main com mudancas nao commitadas
- judge: fail no HEAD 262ffc79 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0033-guard-de-segredos/judge/manda-20261101T153341.log)
  - FALHA [TASK-07] tests/runtime_guard.test.ts 8/8 pass e suíte sem falha nova (as 4 falhas já existem na main); pi.ts:204-216 e opencode.ts:117-132 passam -e/OPENCODE_CONFIG_DIR e dão guard_missing sem spawn. Mas nada em src/ exporta GINGA_GUARD_LANE=<PLAN-TASK> (env.ts:39 só lê base.GINGA_GUARD_LANE) e src/run.ts:45
  - FALHA [AC] PLAN diz que o manda run deve manter o guard ligado, com falha fechada. Em produção req.env é undefined (run.ts:456-530), então pi.ts:203 e opencode.ts:116 nunca ativam o guard: -e e OPENCODE_CONFIG_DIR não são passados e não há guard_missing
- resumo do judge: A TASK-07 passa nos testes congelados e não regride nada (as 4 falhas da suíte já existem na main), mas só liga o guard se o chamador já puser GINGA_GUARD_LANE no request.env. Nenhum código define essa variável a partir de PLAN-TASK e run.ts não preenche request.env, então o manda run real fica sem guard, sem aviso. Falta derivar GINGA_GUARD_LANE=<PLAN-TASK> em run.ts ou env.ts e passá-la no reque

### 17:32 PLAN-0012-roda-web · ginga · plan/0012 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 358c9ae9 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0012-roda-web/judge/ginga-20261101T173143.log)
  - FALHA [TASK-02] web/index.html, web/app.js, web/style.css têm 1 byte (vazios); src/serve.ts:290 só serve arquivos; tests/web_shell.test.ts passa só com fixtures temporárias; sem nav/sidebar/abas/tema/SSE
  - FALHA [TASK-03] web/inbox.js não existe (touch da TASK); só src/web/render/inbox.ts; botões não ligados a /v1/verbs, contador sem SSE
  - FALHA [TASK-06] src/index_md.ts define renderIndex/writeIndex/checkIndex mas nenhum uso em src/ ou bin/ (grep); sem verbo/CLI 'index' nem '--check', sem regeneração no serve por transition, sem .ginga/index.template.md
  - FALHA [TASK-09] src/web/render/alerts.ts e web/alerts.js existem, mas src/board.ts:24 só declara o tipo 'alerta' e deriveBoard não emite alertas high/critical (grep 'alert' em board.ts); sem tela/navegação de alertas
  - FALHA [AC] AC 'Roda Web mostra Inbox, Quadro e PLAN' e 'index.md gerado substitui o manual' não atendidos: casca vazia (web/index.html 1 byte), inbox.js ausente, verbo index não ligado; AC SPEC-0003 alertas no Inbox: deriveBoard não emite 'alerta'
  - ok [TASK-01] src/board.ts deriveBoard; src/verbs/read.ts:70-82 board/inbox usam deriveBoard; tests/board.test.ts verde
  - ok [TASK-04] src/web/render/board.ts renderBoard + web/board.js; tests/web_board.test.ts verde
  - ok [TASK-05] src/web/render/plan.ts renderPlan + web/plan.js; tests/web_plan.test.ts verde
  - ok [TASK-10] src/status.ts buildStatus, src/alerts.ts listAlerts; verbo status em src/verbs/read.ts:57-65; tests/status_json.test.ts verde
  - ok [TASK-11] commit 8dfdbc4 relógio por db e caminho de eventos igual; tests/status_cli_parity.test.ts e tests/cli_verbs.test.ts verdes
- resumo do judge: bun test passa (704 pass/0 fail) e os módulos puros e o status estão corretos, mas a casca web é vazia, falta web/inbox.js, o verbo index não está ligado e os alertas high/critical não chegam ao Inbox. Os ACs centrais não são atendidos. Também há um .pyc commitado por engano. Sem regressão.

### 19:10 PLAN-0033-guard-de-segredos · manda · plan/0033 · gate 2
- motivo: main com mudancas nao commitadas
- judge: pass no HEAD 6ef79373 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0033-guard-de-segredos/judge/manda-20261101T190945.log)
  - ok [TASK-07] src/runtime/env.ts guardOn/guardDir/runtimeEnv carimba GINGA_GUARD e GINGA_GUARD_LOG; src/runtime/pi.ts:200-218 (-e guardExt, guard_missing sem spawn); src/runtime/opencode.ts:112-131 (OPENCODE_CONFIG_DIR, guard_missing); tests/runtime_guard.test.ts passa
  - ok [TASK-09] src/run.ts:459-477 deriva GINGA_GUARD_LANE (process.env vence, senão plan/task em minúsculas) e preenche request.env via runtimeEnv; tests/run_guard_lane.test.ts 5 casos passam (13 pass nos 2 arquivos de guard)
  - ok [AC] run.ts:463-477 + pi.ts:203-216 + opencode.ts:116-131: manda run real liga o guard por padrão e dá guard_missing sem spawn quando o guard falta; bun test: 409 pass, 4 fail (CLI exit 2 sem relação, as mesmas 4 falham no checkout manda sujo)
- resumo do judge: TASK-07 e TASK-09 cumpridas em HEAD; o achado grave do judge anterior (request.env indefinido, guard inerte no run real) foi corrigido em run.ts. Nenhuma regressão: as 4 falhas da suíte são testes de CLI exit 2 sem relação com o guard e também falham no checkout manda sujo.

### 21:22 PLAN-0033-guard-de-segredos · manda · plan/0033 · gate 0
- motivo: mergeado bbb7402
- judge: pass no HEAD 6ef79373 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0033-guard-de-segredos/judge/manda-20261101T190945.log)
  - ok [TASK-07] src/runtime/env.ts guardOn/guardDir/runtimeEnv carimba GINGA_GUARD e GINGA_GUARD_LOG; src/runtime/pi.ts:200-218 (-e guardExt, guard_missing sem spawn); src/runtime/opencode.ts:112-131 (OPENCODE_CONFIG_DIR, guard_missing); tests/runtime_guard.test.ts passa
  - ok [TASK-09] src/run.ts:459-477 deriva GINGA_GUARD_LANE (process.env vence, senão plan/task em minúsculas) e preenche request.env via runtimeEnv; tests/run_guard_lane.test.ts 5 casos passam (13 pass nos 2 arquivos de guard)
  - ok [AC] run.ts:463-477 + pi.ts:203-216 + opencode.ts:116-131: manda run real liga o guard por padrão e dá guard_missing sem spawn quando o guard falta; bun test: 409 pass, 4 fail (CLI exit 2 sem relação, as mesmas 4 falham no checkout manda sujo)
- resumo do judge: TASK-07 e TASK-09 cumpridas em HEAD; o achado grave do judge anterior (request.env indefinido, guard inerte no run real) foi corrigido em run.ts. Nenhuma regressão: as 4 falhas da suíte são testes de CLI exit 2 sem relação com o guard e também falham no checkout manda sujo.

### 22:17 PLAN-0012-roda-web · ginga · plan/0012 · gate 11
- motivo: judge reprovou (fail)
- judge: fail no HEAD 3bf8492b (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0012-roda-web/judge/ginga-20261101T221449.log)
  - FALHA [TASK-01] src/board.ts:204,262-281 `blocked` fixo em false e PLAN `done` vai para a coluna PLAN, não FEITO; tests/board.test.ts passa só com o fixture
  - FALHA [TASK-06] src/index_md.ts:70-92 writeIndex passa a raiz do workspace a deriveBoard (que espera o bundle .ginga), e renderSection duplica os `## Seção` do template (src/index_md.ts:26-35); Concluído nunca lista PLAN done; global.mkdirSync hack em :2
  - FALHA [TASK-09] src/board.ts não emite itens `alerta` no Inbox; nenhum verbo lista alertas; web/app.js e web/index.html não montam painel (web/alerts.js só exporta helpers de filtro)
  - FALHA [TASK-14] src/verbs/index.ts:14-23 e src/serve.ts:233-238 chamam writeIndex/checkIndex com a raiz do workspace, que deriveBoard lê como bundle (intents/plans em <ws>/ e não <ws>/.ginga/); tests/index_cli.test.ts não verifica o conteúdo gerado
  - FALHA [AC-SPEC0003-alertas] depende da TASK-09: alertas high/critical não chegam ao Inbox nem à UI
  - FALHA [AC-index-gerado] depende da TASK-06/14: o gerador deriva o quadro da raiz errada e duplica cabeçalhos; TASK-07 (duh-homelab) não julgada aqui
  - ok [TASK-02] web/index.html, web/app.js, web/style.css reais; src/serve.ts fallback serve web/; tests/web_shell.test.ts passa
  - ok [TASK-03] src/web/render/inbox.ts renderInbox com data-verb/data-id/data-count; tests/web_inbox.test.ts passa
  - ok [TASK-04] src/web/render/board.ts:41-43 marcas ⚑ ✓? ⟳, filtros repo/trilha; ⚑ depende de card.blocked que o modelo nunca liga (src/board.ts:204)
  - ok [TASK-05] src/web/render/plan.ts:181 renderPlan com botões retry/escalate/pause/cancel; tests/web_plan.test.ts passa
  - ok [TASK-10] src/status.ts buildStatus, src/alerts.ts listAlerts, src/verbs/read.ts:57-65 status; tests/status_json.test.ts passa
  - ok [TASK-11] src/status.ts resolve eventos/relógio de forma determinística; tests/status_cli_parity.test.ts e tests/cli_verbs.test.ts passam
  - ok [TASK-12] web/index.html (nav data-view, scripts), web/app.js (EventSource, /v1/verbs/, data-theme), web/style.css (@media 640px); tests/web_shell_casca.test.ts passa
  - ok [TASK-13] web/inbox.js inboxVerbRequest/invokeInboxVerb/refreshInboxCount/connectInboxSse; tests/web_inbox_js.test.ts passa
- resumo do judge: Sem regressão e com 717 testes passando, mas o index.md gerado deriva o quadro da raiz errada (workspace em vez do bundle .ginga) e duplica cabeçalhos, o painel de alertas não está ligado ao Inbox nem à UI, e o modelo nunca marca blocked nem coloca PLAN done em FEITO.

### 22:59 PLAN-0034-pi-liga-guarda-de-escopo · manda · plan/0034 · gate 0
- motivo: mergeado bc7bd30
- judge: pass no HEAD bd38ef99 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0034-pi-liga-guarda-de-escopo/judge/manda-20261101T225749.log)
  - ok [TASK-01] src/runtime/pi.ts:176-278 (SCOPE_GUARD_EXTENSION, scopeGuardEnabled, taskScope, -e + MANDA_SCOPE_TOUCH/FROZEN/ROOT só com touch); tests/runtime_pi_scope.test.ts 7 casos + runtime_pi_opencode/text verdes (31 pass, 0 fail); suíte completa 416 pass/4 fail, as mesmas 4 falhas também na main (judge CLI x
  - ok [AC] Contrato do runtime cumprido (argv/env, sem touch não liga, scope_guard=false desliga, coexiste com guard de segredos). Ressalva: nenhum chamador (run.ts/dispatch-task.sh) exporta MANDA_TASK_TOUCH/FROZEN ainda, então em execução real via manda run a guarda segue desligada; é pendência explícita fora
- resumo do judge: TASK-01 entrega o runtime pi ligando a guarda de escopo conforme o contrato congelado; testes focados passam e as 4 falhas da suíte já existem na main (sem regressão). Falta um chamador do harness exportar MANDA_TASK_TOUCH/FROZEN, pendência documentada e fora do escopo da TASK.

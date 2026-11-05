# O que foi ao judge e o que o gate decidiu: 2026-10-28

(Backfill dos vereditos finais que mergearam; daqui em diante, o merge-gate.sh grava cada execução.)

### PLAN-0008-manda-routing-e-judge · manda · último veredito
- judge: fail no HEAD 48205a7a
  - FALHA [AC-01] src/run.ts:224-227 injeta provider/model padrão quando a rota não os define; src/routing.ts:72-75 mapeia provider opencode para pi, embora .ginga/models/ROUTING.md:62-65 reserve esses modelos ao opencode run
  - FALHA [AC-02] src/judge.ts:148-151 procura pools.verifier_judge.default, mas .ginga/models/ROUTING.md:16 declara pools.judge; o diff não implementa o selo externo em p-inga
  - FALHA [TASK-03] src/routing.ts:72-75 classifica todo provider não claude/codex/agy como runtime pi; os pools opencode do ROUTING requerem opencode run (.ginga/models/ROUTING.md:62-65)
  - FALHA [TASK-05] src/run.ts:273-275 e 301-303 mantêm scopes aprovados para todas as tentativas e tarefas da execução; a aprovação não é consumida uma vez
  - FALHA [TASK-06] src/cli.ts:47-53 adiciona somente o despacho de manda judge; o diff não inclui implementação de pinga judge --verdict em p-inga
  - FALHA [TASK-07] src/judge.ts:148-151 exige pools.verifier_judge.default, ausente de .ginga/models/ROUTING.md:9-16, então não seleciona candidato do ROUTING entregue
  - FALHA [TASK-09] src/run.ts:224-227 usa glm-5.3-flash-free como fallback implícito para runtime pi sem modelo; isso não resolve a rota fixa a partir da configuração e contradiz a regra de que Pi não usa modelos free (.ginga/models/ROUTING.md:60-65)
  - ok [TASK-01] src/runtime/pi.ts:151-160 falha sem provider e modelo, sem spawn do Pi
  - ok [TASK-02] .ginga/models/ROUTING.md:1-17 adiciona ladder, breaker, pools e budget em frontmatter
  - ok [TASK-04] src/escalation.ts:147-165 impede escalada automática para strong e pula candidatos já tentados; src/run.ts:416-431 conta falhas consecutivas e ignora quota_exhausted/infra
  - ok [TASK-08] src/plan.ts:246-299 resolve o runtime planner por config ou pool; src/plan.ts:112-185 valida campos, DAG e limite de linhas
- resumo: Falham os ACs de roteamento e Judge. Também faltam o selo externo do pinga e a aprovação única de budget; TASK-09 injeta um fallback incompatível com a rota vigente.

### PLAN-0018-sandbox-done-when · p-inga · último veredito
- judge: pass no HEAD 66348e48
  - ok [AC-01] tasks/T74/PLAN.md:10; tests/discord.test.ts:13-26; tests/ux_t52_hardening.test.ts:30-43
  - ok [TASK-01] src/verify.ts, src/prove.ts, src/plan_verify.ts e src/supersede.ts não foram alterados neste diff
  - ok [TASK-02] nenhum arquivo do wrapper ou dispatch-task.sh foi alterado neste diff
  - ok [TASK-03] src/discord.ts:5-7; tests/discord.test.ts:13-26; tests/ux_t52_hardening.test.ts:30-43
  - ok [TASK-04] src/examples.ts, src/prove.ts, src/plan_verify.ts e src/supersede.ts não foram alterados neste diff
  - ok [TASK-05] src/supersede.ts não foi alterado neste diff
  - ok [TASK-06] .ginga/bin/pi-run.sh e o teste de pi-run não foram alterados neste diff
  - ok [TASK-07] src/verify.ts e src/prove.ts não foram alterados neste diff
- resumo: O diff torna T26 e W12 menos dependentes do HOME real. As demais TASKs não são tocadas; não executei testes, pois a revisão foi limitada ao diff.

### PLAN-0004 e PLAN-0018 (parte 1): judges codex7/codex4, só achados novos e simples → merge + follow-ups PLAN-0020/0021

### 14:27 PLAN-0006-install-sai-do-pinga · ginga · plan/0006 · gate 0
- motivo: mergeado 0563295
- judge: fail no HEAD 972971d8 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0006-install-sai-do-pinga/judge/ginga-20261028T142544.log)
  - FALHA [AC-01] src/install/install.ts:165-168 mantém PINGA_PI_HARNESS_DIR como fonte; o diff não inclui alterações no p-inga para remover as referências previstas.
  - FALHA [AC-02] src/cli.ts:132-225 adiciona install/adopt no ginga, mas o diff não inclui a remoção dos comandos e módulos do p-inga prevista na TASK-04.
  - FALHA [TASK-02] src/install/install.ts:165-168, 186-199 e 666 preserva a variável e o plugin padrão do pinga; src/install/adapters/hermes.ts:9-22 e src/install/adapters/opencode.ts:7-9 ainda fixam o nome do plugin.
  - FALHA [TASK-04] src/cli.ts:132-225 adiciona comandos ao ginga; não há arquivos do p-inga no diff para remoção de install/adopt ou mensagem de migração.
  - ok [TASK-01] src/install/install.ts:1-120 e src/install/adopt.ts:1-531 adicionam os módulos; tests/install/install.test.ts e tests/install/adopt.test.ts incluem os testes copiados.
  - ok [TASK-03] src/doctor.ts:251-279 percorre os adapters e probes, e src/doctor.ts:282-367 implementa --only e --json; tests/doctor.test.ts cobre o comando.
- resumo do judge: O diff acrescenta install/adopt e doctor ao ginga, mas mantém referências fixas ao pi-harness e não traz as mudanças exigidas no p-inga. Os itens incompletos são regressions false porque o diff não demonstra falha de comportamento que funcionava na main.

### 14:28 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 2
- motivo: conflito no merge
- judge: fail no HEAD a4731d74 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T142700.log)
  - FALHA [AC] src/serve.ts:128-140 injeta spawn, mas não fetch; src/notify/port.ts:43-45 usa deps.fetch no fallback Discord. O envio de fallback em produção falha quando Hermes falha.
  - FALHA [AC] src/state/ingest.ts:29-60 implementa ingestão, mas src/serve.ts:132-147 roteia sem ingeri-los; também abre o DB pelo cwd, enquanto src/tick.ts:297-300 usa o root configurado.
  - FALHA [TASK-04] src/notify/port.ts:43-45 chama deps.fetch sem padrão; src/serve.ts:137-139 não fornece fetch, então a cadeia de fallback não funciona no serve em produção.
  - FALHA [TASK-05] src/notify/router.ts:71-73 só salva thread_id se send devolver esse valor, mas src/notify/port.ts:17-20, 49-52 nunca o devolve; além disso, src/serve.ts:132-147 não ingere o arquivo antes do roteamento.
  - FALHA [TASK-06] O diff main...HEAD não inclui arquivos do repositório p-inga, embora PLAN-0010/TASK-06-pinga-sem-discord.md:12-18 exija mudanças em src/discord.ts, src/cli.ts e testes.
  - ok [AC] src/tick.ts:125-145, contrib/systemd/ginga-tick.service:14, docs/hermes-cron.md:47
  - ok [TASK-01] src/state/ingest.ts:29-60 lê por offset, valida e grava eventos com inserção idempotente; src/state/db.ts:15-42 cria as tabelas previstas.
  - ok [TASK-02] src/tick.ts:125-155 faz claim transacional; src/tick.ts:180-194 renova o lease durante o despacho; src/tick.ts:297-334 implementa dry-run e JSON.
  - ok [TASK-03] src/serve.ts:150-179 agenda ticks sem sobreposição; src/serve.ts:203-234 configura timer e watch; contrib/systemd/ginga-tick.timer:9-17 e docs/hermes-cron.md:22-47 documentam timer e cron.
- resumo do judge: Há falhas no encadeamento de notificações em produção, na ingestão antes do roteamento e na persistência de threads; TASK-06 não aparece no diff. Não identifiquei regressões em comportamento que já funcionava na main.

### 15:49 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 2
- motivo: conflito no merge
- judge: fail no HEAD a4731d74 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T142700.log)
  - FALHA [AC] src/serve.ts:128-140 injeta spawn, mas não fetch; src/notify/port.ts:43-45 usa deps.fetch no fallback Discord. O envio de fallback em produção falha quando Hermes falha.
  - FALHA [AC] src/state/ingest.ts:29-60 implementa ingestão, mas src/serve.ts:132-147 roteia sem ingeri-los; também abre o DB pelo cwd, enquanto src/tick.ts:297-300 usa o root configurado.
  - FALHA [TASK-04] src/notify/port.ts:43-45 chama deps.fetch sem padrão; src/serve.ts:137-139 não fornece fetch, então a cadeia de fallback não funciona no serve em produção.
  - FALHA [TASK-05] src/notify/router.ts:71-73 só salva thread_id se send devolver esse valor, mas src/notify/port.ts:17-20, 49-52 nunca o devolve; além disso, src/serve.ts:132-147 não ingere o arquivo antes do roteamento.
  - FALHA [TASK-06] O diff main...HEAD não inclui arquivos do repositório p-inga, embora PLAN-0010/TASK-06-pinga-sem-discord.md:12-18 exija mudanças em src/discord.ts, src/cli.ts e testes.
  - ok [AC] src/tick.ts:125-145, contrib/systemd/ginga-tick.service:14, docs/hermes-cron.md:47
  - ok [TASK-01] src/state/ingest.ts:29-60 lê por offset, valida e grava eventos com inserção idempotente; src/state/db.ts:15-42 cria as tabelas previstas.
  - ok [TASK-02] src/tick.ts:125-155 faz claim transacional; src/tick.ts:180-194 renova o lease durante o despacho; src/tick.ts:297-334 implementa dry-run e JSON.
  - ok [TASK-03] src/serve.ts:150-179 agenda ticks sem sobreposição; src/serve.ts:203-234 configura timer e watch; contrib/systemd/ginga-tick.timer:9-17 e docs/hermes-cron.md:22-47 documentam timer e cron.
- resumo do judge: Há falhas no encadeamento de notificações em produção, na ingestão antes do roteamento e na persistência de threads; TASK-06 não aparece no diff. Não identifiquei regressões em comportamento que já funcionava na main.

### 16:06 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 2
- motivo: conflito no merge
- judge: fail no HEAD a4731d74 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T142700.log)
  - FALHA [AC] src/serve.ts:128-140 injeta spawn, mas não fetch; src/notify/port.ts:43-45 usa deps.fetch no fallback Discord. O envio de fallback em produção falha quando Hermes falha.
  - FALHA [AC] src/state/ingest.ts:29-60 implementa ingestão, mas src/serve.ts:132-147 roteia sem ingeri-los; também abre o DB pelo cwd, enquanto src/tick.ts:297-300 usa o root configurado.
  - FALHA [TASK-04] src/notify/port.ts:43-45 chama deps.fetch sem padrão; src/serve.ts:137-139 não fornece fetch, então a cadeia de fallback não funciona no serve em produção.
  - FALHA [TASK-05] src/notify/router.ts:71-73 só salva thread_id se send devolver esse valor, mas src/notify/port.ts:17-20, 49-52 nunca o devolve; além disso, src/serve.ts:132-147 não ingere o arquivo antes do roteamento.
  - FALHA [TASK-06] O diff main...HEAD não inclui arquivos do repositório p-inga, embora PLAN-0010/TASK-06-pinga-sem-discord.md:12-18 exija mudanças em src/discord.ts, src/cli.ts e testes.
  - ok [AC] src/tick.ts:125-145, contrib/systemd/ginga-tick.service:14, docs/hermes-cron.md:47
  - ok [TASK-01] src/state/ingest.ts:29-60 lê por offset, valida e grava eventos com inserção idempotente; src/state/db.ts:15-42 cria as tabelas previstas.
  - ok [TASK-02] src/tick.ts:125-155 faz claim transacional; src/tick.ts:180-194 renova o lease durante o despacho; src/tick.ts:297-334 implementa dry-run e JSON.
  - ok [TASK-03] src/serve.ts:150-179 agenda ticks sem sobreposição; src/serve.ts:203-234 configura timer e watch; contrib/systemd/ginga-tick.timer:9-17 e docs/hermes-cron.md:22-47 documentam timer e cron.
- resumo do judge: Há falhas no encadeamento de notificações em produção, na ingestão antes do roteamento e na persistência de threads; TASK-06 não aparece no diff. Não identifiquei regressões em comportamento que já funcionava na main.

### 20:44 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 12
- motivo: sem receipt done: T19 T20 T21 T22 T23
- judge: fail no HEAD 65bc9339 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T204338.log)
  - FALHA [AC-03] A ingestão e emissão do ginga aparecem em src/state/ingest.ts:12-26 e src/tick.ts:169-178; não há alterações no diff para integrar o pinga à porta de eventos
  - FALHA [TASK-05] src/serve.ts:143-151 chama ingestEvents, que abre o DB via cwd em src/state/ingest.ts:29-31; com --root diferente do cwd, ingestão e roteamento podem usar bancos distintos. No fallback Discord, src/notify/port.ts:61-64 não devolve ID de thread recém-criada
  - FALHA [TASK-06] O diff não altera p-inga/src/cli.ts nem p-inga/src/discord.ts; src/notify/discord.ts:1 é apenas export vazio
  - ok [AC-01] src/tick.ts:125-155,308-327; src/serve.ts:168-194,227-229; contrib/systemd/ginga-tick.service:14; docs/hermes-cron.md:15-16
  - ok [AC-02] src/notify/port.ts:22-77 implementa a cadeia Hermes → Discord → stdout; limitações de thread avaliadas em TASK-05
  - ok [TASK-01] src/state/db.ts:23-50; src/state/ingest.ts:29-60,66-90
  - ok [TASK-02] src/tick.ts:125-155,158-167,197-215,308-327
  - ok [TASK-03] src/serve.ts:214-249; contrib/systemd/ginga-tick.service:14; contrib/systemd/ginga-tick.timer:9-17; docs/hermes-cron.md:15-16
  - ok [TASK-04] src/notify/port.ts:22-77 implementa envio Hermes, fallback Discord e stdout, com registro das tentativas
- resumo do judge: Falha: TASK-05 pode ingerir eventos num banco diferente do usado pelo roteador quando --root diverge do cwd; TASK-06 e a parte correspondente do AC-03 não foram implementadas no diff.

### 20:55 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 0
- motivo: mergeado 5e824a7
- judge: fail no HEAD 1d5479ac (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T205449.log)
  - FALHA [AC-01] PLAN.md:20; src/merge.ts:157-175,203-204 — TASK ausente da fila não é detectada; falha no revert é ignorada
  - FALHA [AC-02] PLAN.md:21; diff sem alteração em src/judge.ts para implementar o veredito JSON com head e regression
  - FALHA [AC-03] PLAN.md:22; diff sem implementação de manda pipeline nem arquivamento dos scripts
  - FALHA [AC-04] PLAN.md:23; diff sem implementação de ginga hooks install/check
  - FALHA [TASK-01] TASK-01-manda-merge.md:16-17; src/merge.ts:157-175,203-204 — TASK ausente da fila passa pelo gate, e o retorno do revert não é verificado
  - FALHA [TASK-03] PLAN.md:22; diff sem implementação de pipeline ou arquivamento
  - FALHA [TASK-04] TASK-04-ginga-hooks-install.md:16-19; diff sem implementação de hooks install/check
  - ok [TASK-02] TASK-02-correcao-gate-tests.md:16-18; tests/merge_gate.test.ts:141-143,158-161,195-199
- resumo do judge: Falha: há lacunas no gate de receipts e no revert, e TASKs do plano não estão implementadas neste diff. Não identifiquei regressão de comportamento que já funcionava na main.

### 20:55 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 0
- motivo: mergeado 57d6c0d
- judge: fail no HEAD 265d199e (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T205430.log)
  - FALHA [TASK-05] TASK-05-event-router.md:15-18 exige thread por PLAN; src/notify/port.ts:56-64 ignora o ID da resposta do Discord e só devolve thread_id se já havia thread de entrada, então o fallback Discord não inicia nem persiste a thread.
  - FALHA [TASK-06] TASK-06-pinga-sem-discord.md:15-20 exige mudanças em p-inga/src/discord.ts e p-inga/src/cli.ts; o diff main...HEAD não inclui esses arquivos.
  - ok [AC-01] src/tick.ts:308-320 faz claim antes do despacho; contrib/systemd/ginga-tick.service:14 e docs/hermes-cron.md:23-25 chamam ginga tick.
  - ok [AC-02] src/notify/port.ts:22-35,37-76 implementa fallback Hermes → Discord → stdout; PLAN.md:30 explicita que a resposta na thread fica para o PLAN-0011.
  - ok [AC-03] src/events/emit.ts:20-22 não escreve quando GINGA_EVENTS está ausente; src/serve.ts:143-149 ingere eventos quando o caminho está definido.
  - ok [TASK-01] src/state/db.ts:24-48 cria as tabelas previstas; src/state/ingest.ts:28-64 valida linhas, ignora IDs repetidos e salva o offset.
  - ok [TASK-02] src/tick.ts:308-320 filtra TASKs open sem dependências e usa claim transacional antes do dispatch; src/tick.ts:119-150 protege o claim com BEGIN IMMEDIATE.
  - ok [TASK-03] src/serve.ts:204-239 configura tick por intervalo e evento; contrib/systemd/ginga-tick.service:14 e docs/hermes-cron.md:23-25 chamam ginga tick.
  - ok [TASK-04] src/notify/port.ts:22-76 implementa a cadeia Hermes, Discord e stdout com registro de falhas.
- resumo do judge: ACs atendidos; TASK-05 não cria thread no fallback Discord e TASK-06 não está implementada neste diff.

### 20:56 PLAN-0020-cost-usd-validation · ginga · plan/0020 · gate 0
- motivo: mergeado f294334
- judge: pass no HEAD 727b4200 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0020-cost-usd-validation/judge/ginga-20261028T205537.log)
  - ok [AC-01] src/events/validate.ts:19 inclui cost_usd entre os números de attempt; tests/events_validate_cost.test.ts:19-30 cobre número aceito e string rejeitada.
  - ok [TASK-01] src/events/validate.ts:19 faz a alteração solicitada; tests/events_validate_cost.test.ts:19-30 verifica os dois casos definidos na tarefa.
- resumo do judge: O diff atende ao objetivo e à TASK-01; não identifiquei regressões em relação à main.

### 21:03 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 0
- motivo: mergeado 837f860
- judge: pass no HEAD 14108f8d (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T210307.log)
  - ok [AC] src/merge.ts:165-174 trata TASKs ausentes da fila ou sem estado done como pendentes, com exit 12; src/merge.ts:202-207 verifica a falha do revert, emite aviso e retorna exit 14.
  - ok [TASK-01] O diff não altera os demais códigos nem o fluxo do gate em src/merge.ts; a mudança no bloco de pendências preserva exit 12.
  - ok [TASK-02] O diff não altera o judge, os vereditos ou a correção dos testes congelados.
  - ok [TASK-03] O diff não altera o pipeline nem os scripts arquivados.
  - ok [TASK-04] O diff não altera instalação, verificação ou proteção de hooks.
  - ok [TASK-05] src/merge.ts:165-174 considera ausente da fila como pendente; src/merge.ts:202-207 detecta falha do revert, avisa e retorna código não zero. tests/merge_followup.test.ts:65-82 cobre TASK ausente e não done.
- resumo do judge: O diff atende ao follow-up sem regressões identificadas. A falha do revert está tratada na implementação, embora não haja teste correspondente no diff.

### 21:06 PLAN-0010-tick-serve-notifier · p-inga · plan/0010 · gate 11
- motivo: 1 item(ns) com regression=true
- judge: fail no HEAD 0e2a07dc (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/p-inga-20261028T210539.log)
  - FALHA [AC-01] src/cli.ts:423 — o diff altera apenas queue --notify; não implementa tick com lease nem serve/timers.
  - FALHA [AC-02] src/discord.ts:9-18 — muda a configuração Discord do P-Ingá; não implementa a porta Hermes → Discord → stdout do Ginga.
  - FALHA [AC-03] src/events.ts:66-89 — adiciona emissão P-Ingá, mas o diff não implementa consumo nem roteamento dos eventos pelo Ginga.
  - FALHA [TASK-01] src/events.ts:66-89 — não há implementação de state.db nem ingestão por offset no diff.
  - FALHA [TASK-02] src/cli.ts:423 — não há implementação de tick, claim ou lease no diff.
  - FALHA [TASK-03] src/cli.ts:423 — não há implementação de serve, timers ou units no diff.
  - FALHA [TASK-04] src/discord.ts:9-18 — não há adapters Hermes, Discord e stdout em cadeia no diff.
  - FALHA [TASK-05] src/events.ts:66-89 — emite blocker, mas não implementa o event router nem as regras de notificação no diff.
  - ok [TASK-06] REGRESSÃO src/cli.ts:423-431,1696-1702 e src/events.ts:66-89 implementam emissão e fallback; src/discord.ts:17 remove a busca de credenciais em ~/.hermes e o canal padrão que funcionavam na main.
- resumo do judge: O diff atende à TASK-06, mas deixa as TASKs 01–05 e os ACs de tick, serve e roteamento sem implementação; também remove o comportamento anterior de configuração Discord por ~/.hermes/canal padrão.

### 21:07 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 11
- motivo: 1 item(ns) com regression=true
- judge: fail no HEAD 9a9c23f9 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T210649.log)
  - FALHA [TASK-02] REGRESSÃO src/cli.ts:60-61 conta valores de --base/--head como posicionais e pode encaminhar `manda judge <PLAN> --base <ref> --head <ref>` para judge_run.ts, quebrando a sintaxe existente de judge.ts.
  - ok [TASK-01] src/cli.ts:59-61 altera apenas o dispatch de judge; o dispatch de merge não foi modificado.
  - ok [TASK-03] src/cli.ts:59-61; o diff não altera o fluxo de pipeline.
  - ok [TASK-04] src/cli.ts:59-61; o diff não altera hooks nem instalação do ginga.
  - ok [TASK-05] src/cli.ts:59-61; o diff não altera o gate de merge nem o tratamento de revert.
- resumo do judge: O PLAN não enumera ACs separadamente. Há regressão na sintaxe existente de `manda judge` com --base/--head: a contagem de posicionais inclui os valores das opções e pode selecionar o novo judge_run.ts.

### 21:07 PLAN-0021-holdout-exit97-test · p-inga · plan/0021 · gate 0
- motivo: mergeado 7362578
- judge: pass no HEAD a64336dd (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0021-holdout-exit97-test/judge/p-inga-20261028T210631.log)
  - ok [AC-01] tests/exec_wrapper_holdout97.test.ts:87-90 configura o wrapper para sair com 97 no holdout; :97-110 verifica receipt blocked/infra.
  - ok [TASK-01] tasks/T76/PLAN.md:3-7 define objetivo, arquivo tocado e comando done_when; tests/exec_wrapper_holdout97.test.ts:97-110 executa o verify e verifica o receipt.
- resumo do judge: O diff adiciona o teste comportamental solicitado e seu contrato; não encontrei regressão em comportamento que funcionava na main.

### 21:08 PLAN-0010-tick-serve-notifier · p-inga · plan/0010 · gate 11
- motivo: 1 item(ns) com regression=true
- judge: fail no HEAD 0e2a07dc (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/p-inga-20261028T210539.log)
  - FALHA [AC-01] src/cli.ts:423 — o diff altera apenas queue --notify; não implementa tick com lease nem serve/timers.
  - FALHA [AC-02] src/discord.ts:9-18 — muda a configuração Discord do P-Ingá; não implementa a porta Hermes → Discord → stdout do Ginga.
  - FALHA [AC-03] src/events.ts:66-89 — adiciona emissão P-Ingá, mas o diff não implementa consumo nem roteamento dos eventos pelo Ginga.
  - FALHA [TASK-01] src/events.ts:66-89 — não há implementação de state.db nem ingestão por offset no diff.
  - FALHA [TASK-02] src/cli.ts:423 — não há implementação de tick, claim ou lease no diff.
  - FALHA [TASK-03] src/cli.ts:423 — não há implementação de serve, timers ou units no diff.
  - FALHA [TASK-04] src/discord.ts:9-18 — não há adapters Hermes, Discord e stdout em cadeia no diff.
  - FALHA [TASK-05] src/events.ts:66-89 — emite blocker, mas não implementa o event router nem as regras de notificação no diff.
  - ok [TASK-06] REGRESSÃO src/cli.ts:423-431,1696-1702 e src/events.ts:66-89 implementam emissão e fallback; src/discord.ts:17 remove a busca de credenciais em ~/.hermes e o canal padrão que funcionavam na main.
- resumo do judge: O diff atende à TASK-06, mas deixa as TASKs 01–05 e os ACs de tick, serve e roteamento sem implementação; também remove o comportamento anterior de configuração Discord por ~/.hermes/canal padrão.

### 21:12 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 0
- motivo: mergeado 62e1789
- judge: pass no HEAD 5c96a42f (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T211129.log)
  - ok [TASK-01] src/pipeline.ts:126 chama runMerge; src/merge.ts não foi alterado no diff
  - ok [TASK-02] tests/merge_gate.test.ts não foi alterado no diff
  - ok [TASK-05] src/merge.ts e tests/merge_followup.test.ts não foram alterados no diff
- resumo do judge: No diff main...HEAD, não há regressão nas TASKs manda avaliadas.

### 21:13 PLAN-0010-tick-serve-notifier · p-inga · plan/0010 · gate 0
- motivo: mergeado 25a9110
- judge: pass no HEAD 62473003 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/p-inga-20261028T211217.log)
  - ok [TASK-06] src/cli.ts:422-434,1696-1704: com GINGA_EVENTS, queue --notify e pinga notify emitem blocker; sem a variável, mantêm o envio ao Discord. src/discord.ts:13-21: usa apenas as duas variáveis de ambiente e não define canal padrão.
  - ok [AC] src/events.ts:69-89: grava evento v1 em GINGA_EVENTS; src/cli.ts:426-433,1698-1704: ambos os comandos emitem o evento quando configurado e preservam o fallback sem a variável.
- resumo do judge: As mudanças atendem à TASK-06 e à parte do AC que depende dela; os comportamentos alterados são explicitamente solicitados.

### 21:14 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 0
- motivo: mergeado 237fb39
- judge: pass no HEAD 2a273832 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T211328.log)
  - ok [TASK-01] src/state/db.ts:1 — não alterado por este diff
  - ok [TASK-02] src/tick.ts:1 — não alterado por este diff
  - ok [TASK-03] src/serve.ts:1 — não alterado por este diff
  - ok [TASK-04] src/notify/port.ts:61-72 — mantém o envio Discord bem-sucedido e retorna o ID da resposta quando não há thread de entrada; falha ao ler JSON não falha o envio
  - ok [TASK-05] src/notify/router.ts:71-72 — persiste e reutiliza thread_id; arquivo não alterado por este diff
  - ok [TASK-07] src/notify/port.ts:63-72 — preserva a thread recebida e extrai o ID da resposta Discord quando não há thread; testes em tests/notify_thread_id.test.ts:9-55
  - ok [AC-01] src/tick.ts:1 e src/serve.ts:1 — não alterados por este diff
  - ok [AC-02] src/notify/port.ts:61-72 — fallback Discord devolve thread_id; src/notify/router.ts:71-72 persiste e reutiliza esse ID
  - ok [AC-03] src/state/ingest.ts:1 e src/notify/router.ts:35-76 — não alterados por este diff
- resumo do judge: O diff atende ao follow-up de thread_id do Discord e não altera os demais comportamentos aplicáveis do PLAN.

### 21:15 PLAN-0022-merge-gate-no-pacote · ginga · plan/0022 · gate 0
- motivo: mergeado 19dc411
- judge: fail no HEAD 18bcaf89 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/ginga-20261028T211431.log)
  - FALHA [TASK-04] src/hooks/index.ts:182-231 implementa `hooks check`, mas src/doctor.ts:38-103 não verifica nem acusa drift dos hooks, como pede TASK-04; o plano T25 também registra essa parte como fora do escopo.
- resumo do judge: Os comandos de instalação e verificação foram adicionados, sem regressão identificada; TASK-04 ainda não está completa porque `ginga doctor` não acusa drift.

### 21:17 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 13
- motivo: falha nova na branch: (fail) manda merge: códigos de saída do gate > 10: veredito de outro HEAD não vale 
- judge: pass no HEAD 1163a904 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T211647.log)
  - ok [TASK-01] src/judge-run.ts:1 (shim removido; src/judge_run.ts permanece); src/merge.ts:144-151 mantém o tratamento dos vereditos e de regression
  - ok [TASK-02] tests/merge_gate.test.ts não foi alterado; tests/judge_module.test.ts:8-9 cobre a remoção do shim
  - ok [TASK-05] src/merge.ts:153-176 mantém a checagem de TASKs ausentes ou não concluídas na fila; tests/merge_followup.test.ts:97-110 permanece inalterado
- resumo do judge: O diff remove o shim src/judge-run.ts e adiciona seu teste de remoção; não encontrei regressão nas TASKs manda avaliadas. Testes não foram executados.

### 21:22 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 0
- motivo: mergeado 4842359
- judge: pass no HEAD 0c00f9aa (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T212127.log)
  - ok [TASK-01] tests/merge_gate.test.ts:110-114 — a sentinela agora garante HEAD diferente; src/merge.ts:144-151 mantém as validações de veredito e regressão.
  - ok [TASK-02] src/cli.ts:70-72 direciona o comando judge à implementação src/judge_run.ts; a remoção do shim não altera esse caminho.
  - ok [TASK-05] src/merge.ts:168-176 mantém a ausência de TASK na fila como pendência; src/merge.ts:201-211 verifica e reporta falha no revert.
- resumo do judge: O diff não introduz regressões nas TASKs repo: manda consideradas; a sentinela do caso 10 evita colisão com hash real.

### 21:23 PLAN-0024-doctor-hooks-drift · ginga · plan/0024 · gate 0
- motivo: mergeado 675099d
- judge: pass no HEAD 766c1974 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0024-doctor-hooks-drift/judge/ginga-20261028T212239.log)
  - ok [TASK-01] src/doctor.ts:234-245 registra hooks.toml ausente como unverified/blocked; src/doctor.ts:253-275 registra drift como broken/fail e marca o doctor para exit 1; src/hooks/index.ts:187-226 detecta hooks ausentes, não arquivo ou diferentes da fonte; tests/doctor_hooks_drift.test.ts:88-118 cobre sem drif
- resumo do judge: A TASK-01 de repo ginga está atendida. Não encontrei regressão no diff.

### 21:31 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado cc15da7
- judge: fail no HEAD e1d096a5 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T213036.log)
  - FALHA [TASK-01] src/events/validate.ts:75-95 adiciona os quatro kinds; tests/events_watch_kinds.test.ts:24-110 cobre validação e fixtures. Porém tests/fixtures/watch/goal_reached.jsonl:1-3 usa repo `duh-homelab`, enquanto o plano lista `ginga` e `manda`, e não demonstra gates de todos os repos.
  - FALHA [TASK-02] O diff não inclui avaliador de regras, comando `ginga watch` nem teste por regra; os arquivos alterados estão listados no diff e tests/events_watch_kinds.test.ts:67-110 só valida as fixtures.
  - FALHA [TASK-03] O diff não altera `src/serve.ts`, `src/install/` ou `contrib/systemd/`, nem inclui `tests/serve_supervisor.test.ts`.
  - FALHA [TASK-04] O diff não inclui fila durável do notifier, alterações em `src/state/db.ts` nem `tests/notify_queue.test.ts`.
- resumo do judge: TASK-01 acrescenta o schema e as fixtures, mas a fixture de conclusão não corresponde aos repos do plano; TASK-02 a TASK-04 não estão implementadas no diff. Nenhum item demonstra regressão em comportamento que funcionava na main.

### 21:44 PLAN-0022-merge-gate-no-pacote · manda · plan/0022 · gate 0
- motivo: mergeado 8291141
- judge: pass no HEAD 485b3cc1 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0022-merge-gate-no-pacote/judge/manda-20261028T214419.log)
  - ok [TASK-07] src/merge.ts:207-216; tests/merge_revert_hook.test.ts:43-60,128-145
  - ok [AC-07-1] src/merge.ts:207-212; tests/merge_revert_hook.test.ts:43-60,128-145
  - ok [AC-07-2] src/merge.ts:213-216
  - ok [AC-07-3] tests/merge_revert_hook.test.ts:43-60,127-145
- resumo do judge: O diff atende à TASK-07: o revert passa MERGE_GATE=1, falha retorna 16 com aviso e há teste do revert com hook reference-transaction.

### 21:54 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado 89461f4
- judge: fail no HEAD d1af9029 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T215328.log)
  - FALHA [TASK-02] src/watch/evaluate.ts:24-29 usa as regras apenas para filtrar IDs; src/watch/evaluate.ts:48-66 ignora janela e threshold, e :85-104 pode alertar sem detectar mudança em main ou dois vereditos para o mesmo HEAD.
  - FALHA [TASK-03] contrib/systemd/ginga-supervisor.service:10-16 define a unit, mas src/install/install.ts:646 não a instala; src/supervisor.ts:135 emite phase=nothing_pending, incompatível com src/events/validate.ts:81-84.
  - FALHA [TASK-04] src/notify/router.ts:44-48 drena itens já enfileirados, mas :50-83 continua encaminhando eventos diretamente; src/notify/queue.ts:73-89 oferece enqueue sem integração que coloque alertas/eventos nessa fila.
  - ok [TASK-01] src/events/validate.ts:75-95 aceita os quatro kinds e seus tipos; tests/events_watch_kinds.test.ts cobre os kinds e as seis fixtures; tests/fixtures/watch/goal_reached.jsonl:1-3 continua válido após a troca dos repositórios.
- resumo do judge: TASK-01 está atendida sem regressão no diff. TASK-02 não aplica as condições configuradas; TASK-03 não instala a unit e emite evento inválido; TASK-04 não conecta a produção de eventos à fila durável.

### 22:00 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado f79de49
- judge: fail no HEAD da72dcc7 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T215946.log)
  - FALHA [TASK-01] src/supervisor.ts:150 emite heartbeat, mas o diff não altera src/events/validate.ts nem inclui as fixtures e o teste exigidos.
  - FALHA [TASK-02] src/watch/evaluate.ts:115-129 avalia lane_dead sem janela temporal ou verificação de pendência; o diff também não altera o schema para validar alert nem inclui o teste por regra.
  - FALHA [TASK-03] src/supervisor.ts:128-131 limita o loop a 10 iterações; o diff não liga o supervisor a ginga serve nem inclui a unidade systemd e sua instalação.
  - FALHA [TASK-04] src/watch/index.ts:70-78 enfileira alertas, mas o diff não implementa o consumo, ack após envio e retry da fila exigidos.
- resumo do judge: As quatro TASKs ginga consideradas não atendem integralmente aos critérios no diff. Não identifiquei regressão de comportamento que funcionava na main.

### 22:11 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 11
- motivo: 1 item(ns) com regression=true
- judge: fail no HEAD 21a822dd (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T221004.log)
  - FALHA [TASK-02] src/watch/evaluate.ts:176 — goal_reached aceita qualquer alvo verde e gates presentes, sem verificar todos os checks nem ausência de pendências; src/events/validate.ts:96 — não valida o tipo de data.actions.
  - FALHA [TASK-03] src/supervisor.ts:128 — limita a supervisão a dez iterações; src/supervisor.ts:131 — pode sair mesmo com pendência e sem falha que acione reinício.
  - FALHA [AC] REGRESSÃO src/notify/router.ts:44 — retries pendentes pelo drain sem persistir thread_id; src/notify/router.ts:89 — só salva thread_id no envio imediato. Uma entrega que falha e depois é recuperada deixa de registrar a thread, comportamento existente em main.
  - ok [TASK-01] src/events/validate.ts:75 — valida os quatro kinds; tests/events_watch_kinds.test.ts:67 — verifica as seis fixtures.
  - ok [TASK-04] src/notify/queue.ts:155 — drena a fila e mantém itens após falha; tests/notify_queue.test.ts:29 — cobre retry, dedupe e digest.
  - ok [TASK-05] src/install/install.ts:991 — copia a unidade do supervisor; tests/install/install_supervisor.test.ts:10 — verifica instalação em HOME falso; src/supervisor.ts:135 — emite reason no_pending.
  - ok [TASK-06] src/notify/router.ts:79 — enfileira notificações; src/notify/router.ts:89 — envia pelo drain da fila; tests/notify_router_queue.test.ts:24 — cobre falha e entrega posterior.
- resumo do judge: TASK-02 e TASK-03 não atendem plenamente às condições do plano. O diff também perde o registro de thread_id em notificações recuperadas após falha. Os testes de schema e regras passaram; testes que criam arquivos temporários não puderam executar neste ambiente somente leitura (EROFS).

### 22:16 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado dcf4dfe
- judge: fail no HEAD f87fa4b7 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T221515.log)
  - FALHA [AC] src/serve.ts:230-280 — o loop do serve não executa ginga watch a cada tick; src/supervisor.ts:147 — heartbeat usa o número de execuções como progress, sem medir efeito real.
  - FALHA [TASK-02] src/watch/evaluate.ts:135-145 — main_moved_outside_gate infere mudança em main por qualquer alteração de progress; src/watch/rules.ts:73 — no_progress configura só kill_and_retry, sem rotate_model.
  - FALHA [TASK-07] src/watch/evaluate.ts:180-186 — qualquer end da lane elimina todos os starts dela; um start posterior ao end pode passar como sem pendência.
  - ok [TASK-01] src/events/validate.ts:75-94 — valida os quatro kinds; tests/events_watch_kinds.test.ts:67 — verifica as fixtures dos seis incidentes.
  - ok [TASK-03] src/serve.ts:255-280 — serve inicia o supervisor pelas lanes configuradas; src/supervisor.ts:129-163 — verifica pendências e reinicia com backoff.
  - ok [TASK-04] src/notify/queue.ts:24-45 — fila persistida em tabela; src/notify/queue.ts:181-202 — confirma após envio e mantém itens que falham.
  - ok [TASK-05] src/install/install.ts:991-1000 — instala a unidade; src/supervisor.ts:132 — emite lane.round end com reason no_pending.
  - ok [TASK-06] src/notify/router.ts:91-117 — enfileira e drena notificações pela fila; tests/notify_router_queue.test.ts:23-42 — cobre falha e entrega posterior.
  - ok [TASK-08] src/supervisor.ts:129-164 — loop sem teto de iterações; encerra por ausência de pendência, stop ou limite de reinícios.
  - ok [TASK-09] src/notify/router.ts:46-55 e 101-109 — drains recuperados persistem thread_id para os planos dos itens entregues.
- resumo do judge: TASK-02 e TASK-07 não cumprem integralmente suas condições; o AC do PLAN também falha porque serve não roda o vigia por tick e heartbeat reporta execuções como progresso. Não identifiquei regressão em relação a main.

### 22:25 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado 910bb84
- judge: fail no HEAD d15dc7de (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T222417.log)
  - FALHA [TASK-02] src/watch/evaluate.ts:134-145 considera qualquer mudança de progress em heartbeat como movimento de main; isso pode disparar alerta crítico sem evidência de mudança em refs/heads/main
  - FALHA [TASK-07] src/watch/evaluate.ts:181-183 considera uma lane encerrada se houver qualquer evento end para ela; uma sequência start, end, start da mesma lane passa indevidamente como sem pendência. A validação de data.actions está em src/events/validate.ts:96-103 e :178-184
  - ok [TASK-01] src/events/validate.ts:72-103; tests/events_watch_kinds.test.ts:67-99; tests/fixtures/watch/ contém as seis fixtures
  - ok [TASK-03] src/supervisor.ts:107-169 supervisiona lanes, reinicia após falha com backoff e para sem pendência; contrib/systemd/ginga-supervisor.service:10-16; src/install/install.ts:991-1000
  - ok [TASK-04] src/notify/queue.ts:24-45 cria fila durável com dedupe; :155-209 mantém falhas pendentes, confirma entregas e agrupa itens por destino; tests/notify_queue.test.ts:16-66
  - ok [TASK-05] src/install/install.ts:991-1000 instala a unidade em HOME; src/supervisor.ts:131-135 emite lane.round end com reason no_pending
  - ok [TASK-06] src/notify/router.ts:44-60 drena pendências pela fila; :91-119 enfileira e drena cada envio; tests/notify_router_queue.test.ts:23-44
  - ok [TASK-08] src/supervisor.ts:130-165 mantém o loop enquanto houver pendência, sem teto de iterações; tests/supervisor_iterations.test.ts:6-31
  - ok [TASK-09] src/notify/router.ts:46-55 grava thread_id para planos recuperados no drain; :101-109 persiste thread_id também após entrega do evento; tests/notify_router_thread_persist.test.ts:23-45
  - ok [TASK-10] src/serve.ts:181-195 executa runWatch após cada tick; src/watch/index.ts:65-86 evita reemitir e reenfileirar dedupe_keys já presentes; tests/serve_watch_tick.test.ts:63-76
  - ok [TASK-11] src/supervisor.ts:20-21 define progressCheck; :147-149 emite o valor retornado, com default 0, sem usar runs; tests/supervisor_progress_effect.test.ts:7-46
- resumo do judge: Falha: TASK-02 pode gerar alerta crítico sem mudança comprovada em main; TASK-07 pode ignorar uma rodada pendente após um end anterior da mesma lane.

### 22:31 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado 657c4af
- judge: fail no HEAD 3f4edfa5 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T222953.log)
  - FALHA [TASK-12] src/watch/evaluate.ts:151-159 compara SHA quando disponível, mas ainda usa progress como fallback quando não há SHA; a TASK exige comparar SHA, não progress.
  - ok [TASK-01] src/events/validate.ts:72-103 define os kinds e campos exigidos; tests/events_watch_kinds.test.ts:67-110 cobre as seis fixtures válidas.
  - ok [TASK-02] src/watch/index.ts:20-97 carrega eventos e regras, avalia e emite alertas; tests/watch_rules.test.ts:50-87 cobre as seis regras.
  - ok [TASK-03] src/serve.ts:264-289 inicia o supervisor configurado; src/supervisor.ts:125-165 trata pendências e backoff.
  - ok [TASK-04] src/notify/queue.ts:73-99 implementa fila persistente e dedupe; linhas 155-198 mantêm itens após falha e confirmam após envio.
  - ok [TASK-05] src/install/install.ts:955-1000 instala a unidade; src/supervisor.ts:131-135 emite lane.round end com reason no_pending.
  - ok [TASK-06] src/notify/router.ts:44-60 drena itens pendentes; linhas 91-119 enfileiram cada envio e drenam pela fila.
  - ok [TASK-07] src/watch/evaluate.ts:202-218 exige gates e checks positivos e pareia starts/ends por ordem temporal; src/events/validate.ts:96-103 valida actions como lista de strings.
  - ok [TASK-08] src/supervisor.ts:130-165 mantém o loop enquanto há pendência e encerra por ausência de pendência, stop ou excesso de reinícios.
  - ok [TASK-09] src/notify/router.ts:46-55 e 101-110 persistem thread_id retornado nos drains, incluindo itens recuperados da fila.
  - ok [TASK-10] src/watch/index.ts:65-89 evita reemitir dedupe_key já presente nos eventos; serve integra o tick em src/serve.ts:245-254.
  - ok [TASK-11] src/supervisor.ts:20-21 declara progressCheck; linhas 147-150 emitem o valor retornado, com padrão 0, sem usar contagem de iterações.
- resumo do judge: 11 TASKs cumpridas; TASK-12 falha porque a regra ainda pode inferir mudança em main pela variação de progress quando os eventos não trazem SHA. Isso não é regressão em relação a main.

### 22:44 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 13
- motivo: falha nova na branch: (fail) serve watch tick > 2 ticks com fixture no_progress geram 1 alerta 
- judge: fail no HEAD 031a5457 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T224316.log)
  - FALHA [TASK-02] src/watch/evaluate.ts:112-131 dispara lane_dead só por lane.round start sem end; não verifica ausência de heartbeat nem pendência, condições exigidas pela regra. A fixture tests/fixtures/watch/lane_dead.jsonl contém heartbeats.
  - ok [TASK-01] src/events/validate.ts:72-108 define os quatro kinds; tests/events_watch_kinds.test.ts:15-95 valida schema e fixtures dos seis incidentes.
  - ok [TASK-03] src/serve.ts:280-289 inicia o supervisor configurado; src/supervisor.ts:130-165 verifica pendência e aplica backoff crescente; contrib/systemd/ginga-supervisor.service existe.
  - ok [TASK-04] src/notify/queue.ts:24-43 cria tabela durável e src/notify/queue.ts:155-209 mantém falhas na fila, confirma envios e agrupa por destino; tests/notify_queue.test.ts cobre retry, dedupe e digest.
  - ok [TASK-05] src/install/install.ts:955-965 e 991-1001 copia a unit para HOME; src/supervisor.ts:132-134 emite lane.round end com reason no_pending.
  - ok [TASK-06] src/notify/router.ts:91-116 enfileira e drena notificações pela fila; tests/notify_router_queue.test.ts cobre falha e recuperação no próximo drain.
  - ok [TASK-07] src/watch/evaluate.ts:200-225 exige gates e checks do ALVO verdes e nenhuma lane pendente; src/events/validate.ts:95-98 valida actions como lista de strings.
  - ok [TASK-08] src/supervisor.ts:130-165 mantém o loop enquanto houver pendência e encerra por no_pending, stop ou maxRestarts excedido; tests/supervisor_iterations.test.ts cobre mais de dez iterações.
  - ok [TASK-09] src/notify/router.ts:46-55 e 101-109 persiste thread_id nos planos dos itens entregues, inclusive no drain de retries; tests/notify_router_thread_persist.test.ts cobre recuperação.
  - ok [TASK-10] src/serve.ts:172-190 executa runWatch depois de runTick; tests/serve_watch_tick.test.ts cobre dois ticks emitindo um alerta.
  - ok [TASK-11] src/supervisor.ts:147-149 obtém progress via progressCheck (default 0), sem usar contagem de iterações; tests/supervisor_progress_effect.test.ts cobre progresso constante.
- resumo do judge: TASK-02 não cumpre as condições de lane_dead. Os demais TASKs ginga avaliados estão implementados. O diff main...HEAD não introduz regressão.

### 22:47 PLAN-0008-manda-routing-e-judge · manda · plan/0008 · gate 2
- motivo: main com mudancas nao commitadas
- judge: fail no HEAD 22b68e67 (log /tmp/scratchpad/judge/0008-manda.log)
  - FALHA [TASK-09] src/run.ts:224-227 injeta opencode/glm-5.3-flash-free quando o runtime escolhido é pi sem modelo; src/runtime/pi.ts:148-165 deixa de aplicar esse padrão no adapter, mas o fallback persiste no chamador.
  - ok [TASK-01] src/runtime/pi.ts:148-165 falha sem provider e modelo explícitos; tests/runtime_pi_opencode.test.ts:265-301 cobre esse contrato.
  - ok [TASK-03] src/routing.ts:104-169 prioriza [runtimes], depois ROUTING e resolve runtime/provider/modelo; src/routing.ts:174-223 expõe route --json.
  - ok [TASK-04] src/escalation.ts:145-164 limita strong a tier explícito e ignora candidatos já tentados; src/run.ts:416-454 implementa breaker e bloqueio após esgotar tentativas.
  - ok [TASK-05] src/run.ts:245-309 aplica tetos, avisos e aprovação para claude; src/budget.ts:176-179 registra gasto.
  - ok [TASK-07] src/judge.ts:172-190 exige família conhecida e seleciona juiz de família distinta; src/judge.ts:197-225 monta bundle limitado aos artefatos previstos; src/judge.ts:247-271 grava e sela o veredito.
  - ok [TASK-08] src/plan.ts:246-299 resolve o Planner; src/plan.ts:310-366 valida, tenta novamente e grava planos como draft.
- resumo do judge: Seis TASKs avaliadas como cumpridas. TASK-09 falha porque mantém provider/modelo implícitos no caminho de runtime fixo. O diff main...HEAD altera apenas src/judge.ts e não causa regressão identificada.

### 22:47 PLAN-0023-vigia-e-supervisor · manda · plan/0023 · gate 2
- motivo: main com mudancas nao commitadas
- judge: pass no HEAD 27fa2d4c (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/manda-20261028T224719.log)
- resumo do judge: Nenhuma TASK-*.md deste PLAN tem repo: manda; todas têm repo: ginga. Portanto, não há TASKs nem ACs dependentes dentro do escopo solicitado para este repo.

### 22:48 PLAN-0008-manda-routing-e-judge · manda · plan/0008 · gate 0
- motivo: mergeado 42f4057
- judge: fail no HEAD 22b68e67 (log /tmp/scratchpad/judge/0008-manda.log)
  - FALHA [TASK-09] src/run.ts:224-227 injeta opencode/glm-5.3-flash-free quando o runtime escolhido é pi sem modelo; src/runtime/pi.ts:148-165 deixa de aplicar esse padrão no adapter, mas o fallback persiste no chamador.
  - ok [TASK-01] src/runtime/pi.ts:148-165 falha sem provider e modelo explícitos; tests/runtime_pi_opencode.test.ts:265-301 cobre esse contrato.
  - ok [TASK-03] src/routing.ts:104-169 prioriza [runtimes], depois ROUTING e resolve runtime/provider/modelo; src/routing.ts:174-223 expõe route --json.
  - ok [TASK-04] src/escalation.ts:145-164 limita strong a tier explícito e ignora candidatos já tentados; src/run.ts:416-454 implementa breaker e bloqueio após esgotar tentativas.
  - ok [TASK-05] src/run.ts:245-309 aplica tetos, avisos e aprovação para claude; src/budget.ts:176-179 registra gasto.
  - ok [TASK-07] src/judge.ts:172-190 exige família conhecida e seleciona juiz de família distinta; src/judge.ts:197-225 monta bundle limitado aos artefatos previstos; src/judge.ts:247-271 grava e sela o veredito.
  - ok [TASK-08] src/plan.ts:246-299 resolve o Planner; src/plan.ts:310-366 valida, tenta novamente e grava planos como draft.
- resumo do judge: Seis TASKs avaliadas como cumpridas. TASK-09 falha porque mantém provider/modelo implícitos no caminho de runtime fixo. O diff main...HEAD altera apenas src/judge.ts e não causa regressão identificada.

### 22:51 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 13
- motivo: falha nova na branch: (fail) ingestEvents usa o root informado > grava no state.db do root, não do cwd 
- judge: pass no HEAD 657c4aff (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T224953.log)
  - ok [TASK-01] src/state/db.ts:23-49 cria as tabelas exigidas; src/state/ingest.ts:29-60 valida e ingere linhas completas por offset, com deduplicação em :82-90.
  - ok [TASK-02] src/tick.ts:140-165 faz claim transacional com lease; :308-325 filtra tarefas abertas e desbloqueadas, despacha e grava o resultado.
  - ok [TASK-03] src/serve.ts:170-205 chama runTick e enfileira ticks sem sobreposição; :239-255 agenda por intervalo e por evento. contrib/systemd/ginga-tick.service:12-14 e docs/hermes-cron.md:27-33 chamam ginga tick.
  - ok [TASK-04] src/notify/port.ts:22-35 tenta Hermes e registra falha; :37-85 aplica fallback Discord e stdout. src/serve.ts:157-159 fornece o spawn de Hermes na integração.
  - ok [TASK-05] src/notify/rules.ts:13-21 define os canais padrão; src/notify/router.ts:62-120 roteia eventos e marca cada ID, e :125-139 persiste e reutiliza a thread por PLAN e target.
  - ok [TASK-07] src/notify/port.ts:61-72 extrai o id da resposta Discord sem thread de entrada e o retorna como thread_id; src/notify/router.ts:106-108 persiste esse valor.
  - ok [AC] src/tick.ts:308-320 filtra e despacha com claim; src/serve.ts:239-255 usa o mesmo runner por timer e evento; contrib/systemd/ginga-tick.service:14 e docs/hermes-cron.md:30 chamam ginga tick.
  - ok [AC] src/serve.ts:157-159 liga o router à porta com spawn de Hermes e fetch Discord; src/notify/port.ts:22-85 implementa Hermes → Discord → stdout.
  - ok [AC] src/events/emit.ts:24-31 faz append em GINGA_EVENTS e retorna sem erro quando a variável não está definida; src/state/ingest.ts:29-90 consome, valida e deduplica eventos.
- resumo do judge: As TASKs do repo ginga e os ACs correspondentes estão atendidos no estado de HEAD. TASK-06 é de outro repo e ficou fora do julgamento. git diff main...HEAD está vazio; não há regressão atribuível a este diff.

### 22:51 PLAN-0020-cost-usd-validation · ginga · plan/0020 · gate 0
- motivo: mergeado 657c4af
- judge: pass no HEAD 727b4200 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0020-cost-usd-validation/judge/ginga-20261028T205537.log)
  - ok [AC-01] src/events/validate.ts:19 inclui cost_usd entre os números de attempt; tests/events_validate_cost.test.ts:19-30 cobre número aceito e string rejeitada.
  - ok [TASK-01] src/events/validate.ts:19 faz a alteração solicitada; tests/events_validate_cost.test.ts:19-30 verifica os dois casos definidos na tarefa.
- resumo do judge: O diff atende ao objetivo e à TASK-01; não identifiquei regressões em relação à main.

### 22:53 PLAN-0023-vigia-e-supervisor · ginga · plan/0023 · gate 0
- motivo: mergeado 5a0a231
- judge: fail no HEAD 8cc6f473 (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/ginga-20261028T225145.log)
  - FALHA [TASK-06] HEAD não contém os scripts legados nem diretório _archive/ com MANIFEST; `git ls-tree -r --name-only HEAD` lista apenas as unidades systemd, sem esses artefatos.
  - FALHA [TASK-07] src/watch/evaluate.ts:234 converte code com num(), aceitando também string "0", embora TASK-07 exija code===0; tests/watch_goal_reached_strict.test.ts:9-35 não cobre esse caso.
  - FALHA [TASK-13] src/watch/evaluate.ts:164-174 só emite o alerta warn sem SHA quando progress muda; TASK-13 exige resultado unknown e alerta sem usar progress como condição.
  - ok [TASK-01] src/events/validate.ts:72-103 define os quatro kinds; tests/events_watch_kinds.test.ts:67-110 verifica fixtures e validação.
  - ok [TASK-02] src/watch/index.ts:20-97 carrega eventos/regras, avalia, emite alertas e deduplica; tests/watch_rules.test.ts cobre as regras.
  - ok [TASK-03] src/serve.ts:264-280 inicia o supervisor configurado; src/supervisor.ts:130-165 supervisiona lanes com backoff; contrib/systemd/ginga-supervisor.service:10-16.
  - ok [TASK-04] src/notify/queue.ts:24-45 cria fila persistente com dedupe; src/notify/queue.ts:155-209 mantém falhas e confirma entregas bem-sucedidas.
  - ok [TASK-05] src/install/install.ts:954-966, 991-1001 instala a unidade; src/supervisor.ts:130-135 emite lane.round end com reason no_pending.
  - ok [TASK-08] src/supervisor.ts:130-165 mantém o loop enquanto há pendência e encerra por no_pending, stop ou maxRestarts excedido.
  - ok [TASK-09] src/notify/router.ts:44-56 persiste thread_id ao drenar itens pendentes; src/notify/router.ts:101-110 faz o mesmo na entrega por evento.
  - ok [TASK-10] src/serve.ts:182-193 chama watch após cada tick; src/watch/index.ts:65-89 evita reemitir dedupe_keys já presentes.
  - ok [TASK-11] src/supervisor.ts:21 declara progressCheck; src/supervisor.ts:147-149 usa seu valor no heartbeat, com default 0; tests/supervisor_progress_effect.test.ts:4-46 cobre progresso constante.
  - ok [TASK-12] src/watch/evaluate.ts:157-183 compara SHA de main e emite kill_and_retry + rotate_model em no_progress; src/watch/evaluate.ts:220-240 pareia rounds por ordem temporal.
- resumo do judge: Falham TASK-06, TASK-07 e TASK-13. As falhas são descumprimentos novos dos critérios; nenhuma foi classificada como regressão em main...HEAD.

### 23:11 PLAN-0010-tick-serve-notifier · ginga · plan/0010 · gate 0
- motivo: mergeado 5a0a231
- judge: pass no HEAD 657c4aff (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0010-tick-serve-notifier/judge/ginga-20261028T224953.log)
  - ok [TASK-01] src/state/db.ts:23-49 cria as tabelas exigidas; src/state/ingest.ts:29-60 valida e ingere linhas completas por offset, com deduplicação em :82-90.
  - ok [TASK-02] src/tick.ts:140-165 faz claim transacional com lease; :308-325 filtra tarefas abertas e desbloqueadas, despacha e grava o resultado.
  - ok [TASK-03] src/serve.ts:170-205 chama runTick e enfileira ticks sem sobreposição; :239-255 agenda por intervalo e por evento. contrib/systemd/ginga-tick.service:12-14 e docs/hermes-cron.md:27-33 chamam ginga tick.
  - ok [TASK-04] src/notify/port.ts:22-35 tenta Hermes e registra falha; :37-85 aplica fallback Discord e stdout. src/serve.ts:157-159 fornece o spawn de Hermes na integração.
  - ok [TASK-05] src/notify/rules.ts:13-21 define os canais padrão; src/notify/router.ts:62-120 roteia eventos e marca cada ID, e :125-139 persiste e reutiliza a thread por PLAN e target.
  - ok [TASK-07] src/notify/port.ts:61-72 extrai o id da resposta Discord sem thread de entrada e o retorna como thread_id; src/notify/router.ts:106-108 persiste esse valor.
  - ok [AC] src/tick.ts:308-320 filtra e despacha com claim; src/serve.ts:239-255 usa o mesmo runner por timer e evento; contrib/systemd/ginga-tick.service:14 e docs/hermes-cron.md:30 chamam ginga tick.
  - ok [AC] src/serve.ts:157-159 liga o router à porta com spawn de Hermes e fetch Discord; src/notify/port.ts:22-85 implementa Hermes → Discord → stdout.
  - ok [AC] src/events/emit.ts:24-31 faz append em GINGA_EVENTS e retorna sem erro quando a variável não está definida; src/state/ingest.ts:29-90 consome, valida e deduplica eventos.
- resumo do judge: As TASKs do repo ginga e os ACs correspondentes estão atendidos no estado de HEAD. TASK-06 é de outro repo e ficou fora do julgamento. git diff main...HEAD está vazio; não há regressão atribuível a este diff.

### 23:16 PLAN-0023-vigia-e-supervisor · manda · plan/0023 · gate 0
- motivo: mergeado 23ec9be
- judge: pass no HEAD b05c565a (log /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-0023-vigia-e-supervisor/judge/manda-20261028T231619.log)
- resumo do judge: Nenhum TASK-*.md deste PLAN tem `repo: manda` no frontmatter; os itens encontrados são de `repo: ginga` e ficam fora deste julgamento.

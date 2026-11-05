# Log

## 2026-10-27

- O bundle `.ginga/` foi criado (PLAN-0002). O design do revamp foi movido para `knowledge/design/ginga-revamp/` e o legado da raiz para `_archive/` (ver `_archive/MANIFEST.md`).
- Os INTENTs 0001–0003 e a SPEC-0001 (draft) foram registrados. O INTENT antigo `deepen` foi migrado como INTENT-0004.
- Criado o registro de modelos (`models/`) com os 6 providers e a política de roteamento e budget do Zen.
- O PLAN-0003 (worktrees) foi aberto em draft, esperando o dono.
- Worktrees `p-inga-ux`, `p-inga-enq` e `p-inga-exec` removidas, junto com as branches (`task/ux-unificado`, `work/enqueue`, `work/exec`), com OK do dono.
- Fontes de quota: Codex (rollout JSONL `rate_limits`, plano go, janela de 30d); Claude (statusline `rate_limits` five_hour/seven_day). AGY e OpenCode Go ainda são manuais.
- DECISION-0001 (nomes: proposta B-Erimbau para o orquestrador, Roda para o console) e design 05 (interface) registrados; SPEC-0001 atualizada.
- DECISION-0002 aceita: Hermes como adapter de mensageria; fila fora do Hermes (`ginga tick` idempotente); `ginga serve` num host por workspace.
- Protótipos clicáveis da Roda publicados (Web, Discord, Telegram, TUI); fontes em `knowledge/design/ginga-revamp/prototipos/`.
- Protótipos SPEC aberta, Ledger/Bench e Onboarding adicionados ao canvas.
- Dashboard de Métricas adicionado ao canvas e documentado no 05.
- INTENT-0005 (handoff e learnings) e design 06 registrados; 04 ganhou LEARNINGS.md, `kind: investigation` e `handoffs/`; SPEC-0001 ganhou ACs de handoff.
- Revisão independente (subagente) aplicada: nome Manda-CARU (DECISION-0001 aceita), nota de transição no CLAUDE.md/AGENTS.md da raiz, Codex só como judge, escalada redefinida, donos de lease/judge/escrita, schema de eventos (07), TASK com goal/mode, tasks/T<N> como legado, docs e protótipos atualizados.
- SPEC-0001 aprovada (ACs completos, riscos registrados). Próximo: Planner.
- Planner gerou os PLANs draft da SPEC-0001: PLAN-0004 a PLAN-0015 (12 PLANs, 78 TASKs, 2 em `strong`), todos `status: draft`, com dúvidas e riscos registrados no `index.md` e em cada PLAN. Nenhum código alterado.
- Dúvidas do Planner resolvidas pelo dono (aceitas as recomendações): numeração sequencial (doc 04), repos irmãos `ginga/` e `manda/` sob o pinga, `mode` = mvp|padrao|completo, campo `repo:` com os PLANs no `.ginga/` do workspace, testes de `tests_frozen` escritos numa passada do Planner antes do despacho, `kind: verify` → `receipt` com `check: bdd`, frontmatter de máquina no ROUTING.md.
- Runbook de execução da SPEC-0001 (design 08) e prompts em `.ginga/prompts/` (planner-red, executor, judge, replan).
- Ondas 1–2 seguem o passo a passo manual (`prompts/PASSO-A-PASSO.md`), por escolha do dono; usar o pi-harness como orquestrador ficou registrado como alternativa. Corrigida a nota de legado do ROUTING.md.
- Triagem da passada RED das ondas 1–2: touch da 0005/TASK-05 corrigido, texto da 0007/TASK-04 corrigido, `.git/info/exclude` em ginga/ e manda/ (runs/, .pinga/, .worktrees/, node_modules/, sidecars). Pendente: .gitignore versionado e fixtures reais.
- 2026-10-27 20:28 Dono confirmou: Zen (free + deepseek-v4-pro pago) no lugar do Go. Registrado em models/ROUTING.md.
- 2026-10-27 21:06 Ondas 1–2: causa dos 'pass ocos' = restore() do dispatch apagava o trabalho não commitado das TASKs anteriores; corrigido (snapshot da árvore inteira) e reexecutado. PLAN-0004 7/7 e PLAN-0005 7/7 GREEN; PLAN-0007 4/8 (03 bloqueada: Zen 'Policy budget exceeded' na conta + 429 no free; 04/06/07 dependem dela). Teste congelado 0004-07 corrigido (walk). Touch 0005-03 +src/cli.ts. Teto pago 0,50/2,00 checado antes. Pago total US$0,5396. Sem commit/merge/push.
- 2026-10-27 21:41 INTENT-0006: pesquisa em knowledge/research/sandbox-ai.md. Prova prática: opencode run em bwrap (HOME falso, /usr ro) respondeu 'ok' com glm-5.3-flash-free; achado: managed service na porta 49374 visível com --share-net. Recomendação: sandbox-run.sh no dispatch (fase 1 share-net, fase 2 unshare-net + proxy), outbox validado pelo host, porta Sandbox no manda.
- 2026-10-27 22:37 Dono: sandbox opção A (wrapper do done_when no pinga, após merge do 0005); INTENT-0007: bench/ na raiz (llm + docs), só estrutura.
- 2026-10-27 22:51 DECISION-0003: tudo open source (OSI). Phoenix descartado (ELv2); observabilidade via OpenTelemetry com backend OSI.
- 2026-10-27 22:53 PLAN-0016 (draft, investigation): validar a palestra de code mode (H1–H6). DECISION-0003 adendo: backend OTLP próprio, Phoenix opcional.
- 2026-10-27 23:xx Pesquisa GitHub de sandboxes (sandbox-ai.md §7): achado `opencode run --standalone` roda no bwrap fase 1 (rc 0, 3,6 s); destrava o executor sem o serviço da 49374.
- 2026-10-27 23:06 Pesquisa GitHub: opencode --standalone destrava executor no bwrap e elimina o SPOF da 49374; aplicar no dispatch (com timeout) após a rodada atual.
- 2026-10-28 merge PLAN-0004 (ginga + pi-harness): judge fail simples (cost_usd validation) sem regressão → merge + follow-up; ledger ok 367; worktrees removidas, branches plan/0004 mantidas.
- 2026-10-28 merge PLAN-0018 (p-inga): judge fail simples (holdout exit 97 teste comportamental) sem regressão → merge + follow-up; ledger ok 367; worktree removida, branch plan/0018 mantida.
- 2026-10-28 PLAN-0008 (manda): T10-T14 implementados e verificados (T10 3 tentativas, T11 3, T12 2, T13 2, T14 3); merge plan/0008; ledger ok 374. E2E two_runtimes 4 falhas por fail-closed do T9 (follow-up).
- 2026-10-29 23:5x INTENT-0012, SPEC-0004 e PLAN-0030 (experimento de acurácia do Jev, 6 TASKs), PLAN-0031 (Jev nos classificadores do manda, 7 TASKs, depende do go do 0030) e PLAN-0032 (guarda de escopo no Pi, 5 TASKs) criados em draft a partir da avaliação do jev-gateway (research/jev-gateway-2026-10-29.md). Nada aprovado, nada executado; `ginga lint` sem erro nos arquivos novos.
- 2026-10-29 Dono aprovou SPEC-0004, PLAN-0030 (código, sem a Fase 2) e PLAN-0032. PLAN-0031 segue draft até o go da Fase 2. `ginga lint` sem erro novo.

# PLAN-0023 · Vigia e supervisor no g-inga

- **Rodada 5 (2026-10-28, operador)**: TASK-01..04 escritas (ganca). TASK-01 executada nesta rodada: worktree `ginga-plan-0023` (branch `plan/0023`, a partir da main 19dc411), RED + despacho + verify + `ready/ginga.json`.
- Regra do operador para este PLAN: **uma TASK por rodada** (TASK-02 na próxima).
- TASK-05 (manda) e TASK-06 (corte)ficam para fora da lane ginga (TASK-05 é repo `manda`; TASK-06 só depois das TASKs 01–04).
- **Rodada 6 (2026-10-28, operador)**: TASK-01 selada — a implementação do executor (despacho interrompido pós-executor) foi committada: `fix(T28)` 0cfa3eb (validate.ts + 6 fixtures) e `fix(T28)` touch com caminhos exatos (matcher do guard é exato; `tests/fixtures/watch/` como dir causava scope_drift espúrio — caso T25). `pinga verify tasks/T28/PLAN.md` = **pass** (ledger seq 488); `bun test` events (5 arquivos): 34 pass / 0 fail. `ready/ginga.json` = `{"branch":"plan/0023"}`. TASK-02 (`ginga watch`) na próxima rodada.
- 2026-10-28T21:31:47-03:00 merge-gate ginga plan/0023: exit 0 (mergeado cc15da7)
- 2026-10-28T21:54:41-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 89461f4)
- 2026-10-28T22:00:59-03:00 merge-gate ginga plan/0023: exit 0 (mergeado f79de49)
- 2026-10-28T22:11:09-03:00 merge-gate ginga plan/0023: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T22:16:58-03:00 merge-gate ginga plan/0023: exit 0 (mergeado dcf4dfe)
- 2026-10-28T22:25:46-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 910bb84)
- 2026-10-28T22:31:27-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 657c4af)
- 2026-10-28 22:40 Claude: checklist do corte (TASK-06), feito pelo Claude, em ordem e com verificação:
  1. paridade do `manda lane` mergeada (backlog-manda) + follow-up 9 do ginga mergeado + judge final do PLAN inteiro sem regressão;
  2. `ginga` e `manda` no PATH do systemd do usuário (hoje nenhum dos dois está no PATH; a unit usa `/usr/bin/env ginga serve`). **Precisa do dono** (instala binário/wrapper persistente);
  3. `.ginga/project.toml` na raiz com `[supervisor]` (lanes: ginga/p-inga/manda → `manda lane <repo>`);
  4. **sombra:** `ginga serve` rodando em paralelo com o timer `ginga-vigia` por um ciclo, comparando alertas (os dois devem detectar o mesmo `lane_dead`/`no_progress` numa lane de teste);
  5. troca: `ginga install` habilita o `ginga-supervisor.service` (**dono**); parar o timer `ginga-vigia` e as units `ginga-lane-*`;
  6. arquivar `.ginga/bin/{lane,vigia,notify,pipeline,autoloop,judge-run,merge-gate}.sh` em `_archive/` com MANIFEST (o dispatch-task.sh e o sandbox-* ficam).
- 2026-10-28T22:44:47-03:00 merge-gate ginga plan/0023: exit 13 (falha nova na branch: (fail) serve watch tick > 2 ticks com fixture no_progress geram 1 alerta )
- 2026-10-28T22:47:39-03:00 merge-gate manda plan/0023: exit 2 (main com mudancas nao commitadas)
- 2026-10-28T22:53:38-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 5a0a231)
- 2026-10-28T23:16:55-03:00 merge-gate manda plan/0023: exit 0 (mergeado 23ec9be)
- 2026-10-28T23:17:49-03:00 judge-run manda: FORCE_REJUDGE no HEAD b05c565ad93c3a873b6204a455643b8817e07a6f
2026-10-29 TASK-15 opencode/qwen3.8-flash tentativa paga 1: US$0.012399529999999999 (custo medido; sessão ses_e7a67a28effew1hhaENnN23FXY; TASK acumulado US$0.012400; total das TASKs US$0.047351)
2026-10-29 TASK-15 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29 operador-manda-r1: TASK-15 (T102) follow-up do judge 14(b): `[supervisor] models` lido do project.toml e vigia com tick anterior; receipt pass seq 567; suíte 170/0; `ready/manda.json` gravado (plan/0023). Executor qwen3.8-flash, custo US$0,0124.
- 2026-10-29T00:26:49-03:00 merge-gate manda plan/0023: exit 0 (mergeado a9dd179)
2026-10-29 TASK-16 opencode/qwen3.8-flash tentativa paga 1: US$0.00842111 (custo medido; sessão ses_e7a42fc3affe7jjPXcn99SVb2X; TASK acumulado US$0.008421; total das TASKs US$0.186492)
2026-10-29 TASK-16 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-17 opencode/qwen3.8-flash tentativa paga 1: US$0.00978864 (custo medido; sessão ses_e7a420f85ffe75s5fsPY5IPKv1; TASK acumulado US$0.009789; total das TASKs US$0.196280)
2026-10-29 TASK-17 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29 operador-ginga-r1: TASK-16 (T107) e TASK-17 (T108) follow-ups do judge: receipts pass, bun test 313/0 em ginga-plan-0023 (plan/0023, ae49015); ready/ginga.json gravado. Executor opencode/qwen3.8-flash (US$0,0084 + US$0,0098).
- 2026-10-29T00:52:59-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 8ad2346)
2026-10-29 TASK-18 opencode/qwen3.8-flash tentativa paga 1: US$0.01463514 (custo medido; sessão ses_e7a32f404ffewf1ir22x1HMF1R; TASK acumulado US$0.014635; total das TASKs US$0.210915)
2026-10-29 TASK-18 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-19 opencode/qwen3.8-flash tentativa paga 1: US$0.018192260000000002 (custo medido; sessão ses_e7a301958ffeT421xMuztpusCN; TASK acumulado US$0.018192; total das TASKs US$0.229108)
2026-10-29 TASK-19 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-20 opencode/qwen3.8-flash tentativa paga 1: US$0.013850690000000002 (custo medido; sessão ses_e7a2cb828ffedrayADFihiE44H; TASK acumulado US$0.013851; total das TASKs US$0.242958)
2026-10-29 TASK-20 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29 operador-ginga-r1 (lane 0054): follow-ups do judge 00:51 — TASK-18 (T109, lane_dead pareia start/end), TASK-19 (T110, SHA de main por lane), TASK-20 (T111, heartbeat periódico enquanto o filho roda). RED provado (base 8ad2346), executor opencode/qwen3.8-flash tentativa 1 cada (US$0,0146 + 0,0182 + 0,0139), `pinga verify` = pass nas 3, bun test 322/0 em ginga-plan-0023 (plan/0023). ready/ginga.json gravado.
- 2026-10-29T01:08:46-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 910ae11)
2026-10-29 TASK-21 opencode/qwen3.8-flash tentativa paga 1: US$0.0063546 (custo medido; sessão ses_e7a25b20fffeWZVG22SPJoMZDE; TASK acumulado US$0.006355; total das TASKs US$0.249313)
2026-10-29 TASK-21 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-22 opencode/qwen3.8-flash tentativa paga 1: US$0.016427889999999997 (custo medido; sessão ses_e7a246becffeRlaOY9Cso5rdXP; TASK acumulado US$0.016428; total das TASKs US$0.265741)
2026-10-29 TASK-22 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29 operador-ginga-lane-0109-r1: TASK-21 (T112) e TASK-22 (T113), follow-ups do judge 01:07; receipts pass, bun test 326/0 em ginga-plan-0023; ready/ginga.json gravado (plan/0023 af193a8).
- 2026-10-29T01:18:40-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 39b2a1a)
- 2026-10-29 corte-task06 (sessão claude, sonnet-5-5) — **CORTE NÃO FEITO; parado no passo 3** (regra: sem paridade do `manda lane`, não corta).
  1. pré-condição ok: backlogs sem `- [ ]`, sem `ready/*.json`, nenhuma `ginga-lane-*` ativa.
  2. `manda install` rodado: `~/.local/bin/manda` -> `manda/bin/manda.ts` (`manda version` = 0.1.0). `ginga install` **não** foi rodado: ele exige `GINGA_PLUGIN_SOURCE` e regrava as configs de claude/opencode/pi/hermes (fora do escopo; proibido mexer em pi-harness/`~/.pi`) e só instala a unit/link como efeito colateral; além disso `ginga/bin/ginga.ts` está em modo 644, então o link dele não executaria. No lugar, wrapper `~/.local/bin/ginga` (`exec bun .../ginga/bin/ginga.ts "$@"`, igual ao do `pinga`): `ginga --version` = 0.1.0. PATH do systemd do usuário já inclui `~/.local/bin` e os shims do mise (bun, claude, opencode), então `/usr/bin/env ginga serve` resolve. Reverter: `rm ~/.local/bin/ginga ~/.local/bin/manda`.
  3. **bloqueio**: `manda lane` (`manda/src/pipeline.ts`) não tem paridade com `lane.sh` + `lane.env`: (a) operador sempre `opencode run`, sem `claude/*` (o operador atual é `claude/claude-sonnet-5-5`); (b) nada mapeia `EXEC_MODELS`→`MODELS` do executor nem `ALLOW_PAID`/`SPEND_FILE`/`TOTAL_CAP` do project.toml; (c) sem pausa por cota free esgotada (`.free-esgotado`, exit 4); (d) rodada sem progresso sai 0 (o `lane.sh` saía 3); (e) o posicional `[rodadas]` é ignorado. No supervisor do ginga (`src/supervisor.ts`): saída 0 com pendência religa sem espera (laço quente de operador LLM); exit 20/4 tratados como falha comum; após `max_restarts` (padrão 50 ms–1 s, 3 falhas) a lane com pendência morre para sempre, ao contrário do vigia que religava a cada 10 min; a pendência só olha a fila do pinga, não `backlog-*.md` + `ready/*.json`.
     `.ginga/project.toml` **não foi criado** (config parcial só enganaria o `manda lane`, que já lê `[supervisor] models`). Rascunho para quando a paridade existir: `[supervisor] operator_models=["claude/claude-sonnet-5-5"]`, `executor_models=["opencode/qwen3.8-flash"]` (glm-free na frente quando a cota voltar), `[supervisor.env] ALLOW_PAID=1, SPEND_FILE=<paid-spend-2026-10-28-noite.tsv>, TOTAL_CAP=1.80`, lanes ginga/p-inga/manda → `manda lane <repo>`.
  TASKs criadas: `backlog-manda.md` (PLAN-0023 TASK-23, paridade 2) e `backlog-ginga.md` (PLAN-0023 TASK-24, a–f). Nada mudou no resto: timer `ginga-vigia` e `.ginga/bin/*.sh` intactos e ativos; sem `ready/`, sem arquivamento, `index.md` sem alteração. Retomar o corte (passos 3–8) depois que TASK-23/24 passarem pelo judge e pelo gate.
2026-10-29 TASK-23 opencode/qwen3.8-flash tentativa paga 1: US$0.03306702 (custo medido; sessão ses_e7a11d94cffe5Ma9CIWLNslDmX; TASK acumulado US$0.033067; total das TASKs US$0.298808)
2026-10-29 TASK-23 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-23 opencode/qwen3.8-flash tentativa paga 1: US$0 (custo medido; sessão ses_e7a11e3f5ffee6pU4SU5zp8LHw; TASK acumulado US$0.033067; total das TASKs US$0.298808)
2026-10-29 TASK-23 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29 operador-manda-lane-0130-r1: TASK-23 (T113, manda lane paridade 2): RED provado (base 0ded7ed), executor opencode/qwen3.8-flash tentativa 1 (US$0), `pinga verify` = pass; ready/manda.json gravado (plan/0023).
- 2026-10-29T01:43:35-03:00 merge-gate manda plan/0023: exit 0 (mergeado 00dd2df)
2026-10-29 TASK-24 opencode/qwen3.8-flash tentativa paga 1: US$0.019059769999999997 (custo medido; sessão ses_e7a09c014ffer7OVN5SuXcGyu0; TASK acumulado US$0.019060; total das TASKs US$0.317868)
2026-10-29 TASK-24 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-25 opencode/qwen3.8-flash tentativa paga 1: US$0.01825303 (custo medido; sessão ses_e7a0595b6ffeL65yA55Ssx95YS; TASK acumulado US$0.018253; total das TASKs US$0.336121)
2026-10-29 TASK-25 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-26 opencode/qwen3.8-flash tentativa paga 1: US$0.013165540000000002 (custo medido; sessão ses_e7a02716affeypJ7ym9Vkp11LG; TASK acumulado US$0.013166; total das TASKs US$0.349286)
2026-10-29 TASK-26 opencode/qwen3.8-flash tentativa 1 pass
2026-10-29 TASK-28 opencode/qwen3.8-flash tentativa paga 1: US$0.022665479999999995 (custo medido; sessão ses_e79ff7929ffeJa0XJ8WwgperaD; TASK acumulado US$0.022665; total das TASKs US$0.371952)
2026-10-29 TASK-28 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29 operador-ginga-r1: TASK-23..28 (T114..T119) = sub-itens (a)–(f) do backlog TASK-24 (lacunas do corte). prove-red RED + verify `pass` em cada uma; `bun test` na plan/0023: 341 pass / 0 fail. ready/ginga.json gravado. Pré-requisito do corte (TASK-06) cumprido após o merge.
2026-10-29 TASK-29 opencode/qwen3.8-flash tentativa paga 1: US$0.02101014 (custo medido; sessão ses_e79fe4084ffeE1MprP2ITxJcBo; TASK acumulado US$0.021010; total das TASKs US$0.392962)
2026-10-29 TASK-29 opencode/qwen3.8-flash tentativa 1 pass
- 2026-10-29T01:58:01-03:00 merge-gate ginga plan/0023: exit 0 (mergeado 03e9af5)
- 2026-10-29 operador-manda-lane-0150-r1: TASK-29 (T114, manda plan x ginga lint real): RED provado (base 0ad74b8), executor opencode/qwen3.8-flash tentativa 1 (US$0.021), `pinga verify` = pass; bun test 205/4 (as 4 falhas são o guard exit 30 de judge/pipeline/lane sem args, por rodar sob ancestral LLM; fora do LLM passam); ready/manda.json gravado (plan/0023).
- 2026-10-29T01:59:10-03:00 merge-gate manda plan/0023: exit 0 (mergeado 664ebd3)

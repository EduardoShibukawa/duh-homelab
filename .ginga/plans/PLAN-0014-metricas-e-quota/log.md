# Log — PLAN-0014

## 2026-10-27

- PLAN criado em draft pelo Planner a partir da SPEC-0001.

## 2026-10-29

- Aprovado pelo dono em 2026-10-29; atualizado pelo Planner: sem pi-harness (repos só `ginga`; A/B no `src/bench/` do ginga, sem `bench/` na raiz até a lacuna 9 ter PLAN); custo pelo `opencode.db` (TASK-07); emendas da SPEC-0003 (TASK-08); interfaces no PLAN.md.

## 2026-11-02 r2 lane-ginga-20261102-0420-r2 (operador)
- Gate de dependência aberto: PLAN-0012 (d12bf50) e PLAN-0013 (eeb6cd5/813274d) mergeados na main do ginga; worktree `ginga-plan-0014` (branch `plan/0014`) criada a partir da main.
- **replan necessário (não despachei nada do 0014 nesta rodada):** TASK-01 (`metrics` em `src/verbs/read.ts`), TASK-03 (`quota` em `src/verbs/registry.ts`) e TASK-07 (`cost` em `src/verbs/registry.ts`) criam verbos públicos, e `tests/cli_verbs.test.ts:112-114` exige um caso por verbo do registro — porém `tests/cli_verbs.test.ts` não está no `touch` dessas TASKs. Sem emendar o `touch` (adicionar `tests/cli_verbs.test.ts`), o executor toma `scope_drift` ou quebra a suíte cheia no gate. Pendência do Planner/dono: emendar o touch das TASK-01/03/07 (ou afrouxar o contrato de cobertura). Ids livres reservados: T342–T349 (TASK-01→T342 … TASK-08→T349; máx. no ledger = T341).

## 2026-11-02 r5 lane-ginga-20261102-0942-r5 (operador)
- Worktree `ginga-plan-0014` alinhada à main `b8c18a8` (PLAN-0012 e PLAN-0013 já mergeados; dependências liberadas).
- TASK-07 → T348 (primeiro id livre global acima do ledger T351). RED `ea2a22c`: `tests/cost_opencode_db.test.ts` + `tests/fixtures/opencode-db.sql`; `pinga prove-red tasks/T348/PLAN.md` pass (receipt `fa5b1d31`, RED exit 1).
- Pendência de escopo preservada: o executor só pode alterar os `touch`; a cobertura pública de `tests/cli_verbs.test.ts` será tratada na TASK-07 sem tocar nesse frozen alheio (verbos públicos её postponed apenas se não couber no contrato).
2026-11-02 TASK-07 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"command_failed"
2026-11-02 TASK-02 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass

## 2026-11-02 r6 lane-ginga-20261102-1111-r6 (operador)
- Bloqueio de gate: a `main` do `ginga/` tinha somente `contrib/hermes-plugin/__pycache__/__init__.cpython-314.pyc` modificado. A cópia e o patch foram arquivados em `.ginga/_archive/2026-11-02-main-suja-ginga-pycache/` com MANIFEST; o arquivo foi restaurado ao HEAD e `git -C ginga status --porcelain` ficou vazio.
- TASK-02 → T342: RED inicial `1c089d9`; base refeita `12c00bc` após corrigir o import `copyFileSync` do próprio teste; `pinga prove-red` pass (seq 1831, base `12c00bc`); dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 1ª tentativa (seq 1833); feat `f05df2f`; `pinga verify` final pass (seq 1834).
- `bun test tests/quota_codex.test.ts`: 3 pass / 0 fail. `bun test` completo na `plan/0014`: 764 pass / 3 fail; as 3 falhas são `tests/cli_verbs.test.ts` para os verbos `cost` da T348, já registradas como pendência de replan do `touch` (o arquivo congelado alheio não foi alterado).
- `ready/ginga.json` não gravado: as TASKs restantes do PLAN-0014 ainda não têm `pass`.
2026-11-02 TASK-06 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass

## 2026-11-02 r7 lane-ginga-20261102-1254-r2 (operador)
- TASK-06 → T352: RED inicial `8a2cf0b`; base refeita `cd42371` depois de corrigir no fixture criado nesta rodada os IDs de evento, que tinham 25 caracteres em vez dos 26 exigidos pelo ULID v1. `pinga prove-red` final pass (seq 1839, base `cd42371`).
- Dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 1ª tentativa; implementação commitada em `9ca3d6d`; a importação passou a validar os envelopes pelo schema v1 global em `3c2565b`; `pinga verify` final pass (seq 1842).
- `bun test tests/bench_handoff_ab.test.ts`: 4 pass / 0 fail. `bun test` completo na `plan/0014`: 768 pass / 3 fail; as 3 falhas continuam sendo a cobertura de `tests/cli_verbs.test.ts` para os verbos `cost` da T348.
- TASK-01 não foi iniciada: o `touch` atual não inclui `src/verbs/registry.ts`, necessário para `ginga metrics --json`, nem `tests/cli_verbs.test.ts`, cujo frozen exige um caso por verbo público. Pendência de replan já registrada; fica para o Planner/dono.
- `ready/ginga.json` não gravado: as TASKs restantes do PLAN-0014 ainda não têm `pass`.
2026-11-02 TASK-09 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass

## 2026-11-02 r2 lane-ginga-20261102-1445-r2 (operador)
- TASK-09/T353 criada como correção do gate: os verbos públicos `cost sync` e `cost` da T348 estavam sem casos em `tests/cli_verbs.test.ts`.
- RED `20a4ffd`; `pinga prove-red tasks/T353/PLAN.md` pass (seq 1843, RED exit 1); dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 1ª tentativa; feat `80fb540`; `pinga verify` final pass (seq 1847).
- `bun test tests/cost_cli_coverage.test.ts tests/cli_verbs.test.ts`: 42 pass / 0 fail. `bun test` completo na `plan/0014`: 772 pass / 0 fail.
- A worktree reportou ` M contrib/hermes-plugin/__pycache__/__init__.cpython-314.pyc` após a suíte; o arquivo e o patch foram arquivados em `.ginga/_archive/2026-11-02-worktree-suja-ginga-pycache-t353/` com MANIFEST e restaurados ao HEAD. `git -C ginga status --porcelain` e `git -C ginga-plan-0014 status --porcelain` ficaram vazios.
- TASK-01/03/04/05/08 permanecem abertas; TASK-01 continua aguardando replan do `touch` pelo Planner/dono. `ready/ginga.json` não foi gravado porque nem todas as TASKs do PLAN têm `pass`.
2026-11-02 TASK-03 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass
2026-11-02 TASK-10 pi:nvidia/minimaxai/minimax-m3.1-flash quota/rate limit (429); pula para o próximo modelo, não conta como tentativa
2026-11-02 TASK-10 pi:nvidia/stepfun-ai/step-5-preview tentativa 1 pass

## 2026-11-02 r2 lane-ginga-20261102-1743-r2 (operador)
- TASK-03 → T354: RED `748542e`; `pinga prove-red tasks/T354/PLAN.md` pass (seq 1848); dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 1ª tentativa; feat `ca7ceab`; `pinga verify` final pass (seq 1852).
- TASK-10/T355 criada para a cobertura pública do novo verbo `quota`: RED `5d4c351`; `pinga prove-red tasks/T355/PLAN.md` pass (seq 1853); dispatch `pi:nvidia/stepfun-ai/step-5-preview` pass; feat `14d5cae`; `pinga verify` final pass (seq 1855).
- `bun test tests/quota.test.ts`: 4 pass / 0 fail. `bun test tests/quota_cli_coverage.test.ts tests/cli_verbs.test.ts`: 43 pass / 0 fail. `bun test` completo na `plan/0014`: 778 pass / 0 fail.
- O `__pycache__` modificado pela suíte foi restaurado ao HEAD; `git -C ginga status --porcelain` e `git -C ginga-plan-0014 status --porcelain` ficaram vazios. `pinga ledger verify`: `ok 1855`.
- TASK-01 continua aguardando replan do `touch` pelo Planner/dono; TASK-04/05/08 permanecem abertas. `ready/ginga.json` não foi gravado porque nem todas as TASKs do PLAN têm `pass`.
2026-11-02 TASK-01 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass
2026-11-02 TASK-11 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass
2026-11-02 TASK-04 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail BLOCKED BLOCKED: `tests/metrics_repeat.test.ts:75` prepara 5 placeholders, mas cada `insert.run` envia 4 val
2026-11-02 TASK-04 pi:nvidia/minimaxai/minimax-m3.1-flash quota/rate limit (429); pula para o próximo modelo, não conta como tentativa
2026-11-02 TASK-04 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"tests_frozen_changed"
2026-11-02 TASK-04 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 2 fail "reason_code":"tests_frozen_changed"
2026-11-02 TASK-08 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"command_failed"
2026-11-02 TASK-08 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 2 pass

## 2026-11-03 r3 lane-ginga-20261102-2226-r3 (operador)
- TASK-04/T358: `pinga prove-red tasks/T358/PLAN.md --base afa2040` pass (seq 1876); implementação recuperada do executor e commitada em `ba8a5b4`; `pinga verify tasks/T358/PLAN.md --base afa2040` pass (seq 1877). `bun test tests/metrics_repeat.test.ts`: 2 pass / 0 fail.
- TASK-08/T359: RED `1198288`; `pinga prove-red tasks/T359/PLAN.md` pass (seq 1878); dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 2ª tentativa; feat `5f3e8dd`; `pinga verify tasks/T359/PLAN.md` pass (seq 1884). `bun test tests/metrics_alerts.test.ts`: 2 pass / 0 fail.
- `bun test` completo na `plan/0014`: 787 pass / 0 fail. `pinga ledger verify`: `ok 1884`.
- O `__pycache__` modificado pela suíte foi arquivado em `.ginga/_archive/2026-11-03-worktree-suja-ginga-pycache-t359/` com MANIFEST e restaurado ao HEAD; main e worktree ficaram limpas.
- `ready/ginga.json` não foi gravado: a TASK-05 do PLAN-0014 ainda está aberta.

## 2026-11-03 r4 lane-ginga-20261102-2305-r4 (operador)
- TASK-12/T360 (correção do payload): RED `d550e29`; `pinga prove-red tasks/T360/PLAN.md` pass (seq 1886); dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 1ª tentativa; feat `17a2bec`; `pinga verify tasks/T360/PLAN.md` pass (seq 1889).
- TASK-05/T361: RED inicial `5bd9845`; o dispatch não resolveu (2 falhas `command_failed` e 1 tentativa interrompida por `context_length`), então o operador implementou dentro do `touch`. O teste RED próprio foi rebaselineado em `1652132` e `3506358` para corrigir apenas a extração/normalização numérica; `pinga prove-red tasks/T361/PLAN.md` final pass (seq 1896); feat `dcc243a`; `pinga verify tasks/T361/PLAN.md` pass (seq 1897).
- `bun test tests/web_metrics.test.ts`: 4 pass / 0 fail. `bun test` completo na `plan/0014`: 793 pass / 0 fail. `pinga ledger verify`: `ok 1897`.
- O `__pycache__` modificado pela suíte foi arquivado em `.ginga/_archive/2026-11-03-worktree-suja-ginga-pycache-t361/` com MANIFEST e restaurado ao HEAD; main e worktree ficaram limpas.
- Todas as 12 TASKs do PLAN têm receipt `pass`; `ready/ginga.json` gravado com `{"branch":"plan/0014"}`.
2026-11-02 TASK-12 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass
2026-11-03 TASK-05 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"command_failed"
2026-11-03 TASK-05 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 2 fail "reason_code":"command_failed"

## 2026-11-03 r5 lane-ginga-20261103-0031-r5 (operador)
- O achado do gate da TASK-05/T361 já estava coberto pela implementação `dcc243a`; novo `pinga verify tasks/T361/PLAN.md` na worktree `ginga-plan-0014`: receipt `pass` seq 1898.
- `bun test`: 793 pass / 0 fail. `pinga ledger verify`: `ok 1898`.
- O `__pycache__` modificado pela suíte foi restaurado ao HEAD; main e worktree ficaram limpas.
- As 12 TASKs do PLAN têm receipt `pass`; `ready/ginga.json` foi regravado com `{"branch":"plan/0014"}`.
2026-11-03 TASK-13 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"scope_drift"
2026-11-03 TASK-13 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 2 pass

## 2026-11-03 r1 lane-ginga-20261103-0050-r1 (operador)
- Achado grave do judge 2026-11-03T00:38 (gate 11): TASK-05/T361 não ligava as telas na casca (VIEWS sem metrics/quota; index.html sem script/nav/hosts). TASK-13 nova com RED, id T362 (máx do ledger 361 + 1).
- RED `2101cbf` (`test(T362): RED`); `pinga prove-red tasks/T362/PLAN.md` pass (RED no base). Dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass na 2ª tentativa. Feat `5d9bd11` (operador commitou: VIEWS + metrics/quota, script /metrics.js, nav e seções com [data-metrics]/[data-quota]). `pinga verify tasks/T362/PLAN.md` pass (2 receipts, seq até 1906).
- `bun test tests/web_metrics_wired.test.ts`: 3 pass / 0 fail. `bun test` completo na `plan/0014`: 796 pass / 0 fail. `pinga ledger verify`: `ok 1906`.
- As 13 TASKs do PLAN (T342, T348, T352–T362) têm receipt `pass` no `pinga queue --json`; `ready/ginga.json` regravado com `{"branch":"plan/0014"}`.
- Pendente (não bloqueia, judge não reprovou): instrução da statusline do Claude no README (ressalva simples da TASK-03) e a decisão do PLAN de `ginga quota` alimentar o stub de quota do `tick`.
2026-11-03 TASK-14 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass
2026-11-03 TASK-15 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"scope_drift"
2026-11-03 TASK-15 pi:nvidia/minimaxai/minimax-m3.1-flash quota/rate limit (429); pula para o próximo modelo, não conta como tentativa
2026-11-03 TASK-15 pi:nvidia/stepfun-ai/step-5-preview tentativa 2 fail "reason_code":"scope_drift"
2026-11-03 TASK-15 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass

## 2026-11-03 r2 lane-ginga-20261103-0251-r2 (operador)
- Achados pendentes do judge 2026-11-03T02:50 (gate não bloqueia, mas eram os itens desta rodada) viraram TASKs com RED:
  - TASK-14/T363 (README: instrução de ativar a statusline do Claude em `~/.claude/settings.json`, ativar é ação do dono). RED `7a57729`; prove-red pass (seq base 7a57729, done_when exit 1); dispatch `pi:nvidia/minimaxai/minimax-m3.1-flash` pass 1ª; verify pass; feat `70d700f`; `bun test tests/readme_statusline.test.ts` 4/0.
  - TASK-15/T364 (`ginga quota` alimenta o stub do tick): `quotaCapOk` puro em `src/quota/index.ts` (automático com used_pct >= 100 bloqueia; manual/unavailable/stale não) e `cap_ok: quotaCapOk(readQuotas({home, db}))` no lugar de `cap_ok: true` em `src/tick.ts:593` (só no fluxo por fase). RED `7a57729`; marcador de base refeito em `02ce855` (após o feat(T363); o 1º marcador `fd25b37` ficou antes do feat e causou scope_drift falso em 2 despachos); prove-red pass na base 02ce855; dispatch pass 1ª (`pi:nvidia/minimaxai/minimax-m3.1-flash`); verify pass (receipt ff d943ee, attempts 13); feat `636fa42`; `bun test tests/quota_cap.test.ts tests/tick_plan.test.ts tests/tick.test.ts` 15/0.
- `bun test` completo na `plan/0014`: 806 pass / 0 fail. `pinga ledger verify`: `ok 1927`.
- `pinga queue --json --root ginga-plan-0014`: T342, T348, T352–T364 todas `done`/`pass` (15 TASKs). `ready/ginga.json` regravado com `{"branch":"plan/0014"}`.
- Worktree suja de `__pycache__` (pós-suíte) arquivada em `.ginga/_archive/2026-11-03-worktree-suja-ginga-pycache-r2b/` com MANIFEST; worktree e main limpas.
- Pendentes resolvidos: instrução da statusline no README e `ginga quota` → stub do tick. Nada pendente nesta rodada.
- 2026-11-03T04:06:51-03:00 merge-gate ginga plan/0014: exit 11 (judge reprovou (fail))
2026-11-03 TASK-16 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"scope_drift"
2026-11-03 TASK-16 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 2 pass
2026-11-03 r1 lane-ginga-20261103-0410-r1: TASK-16 → T365, prove-red RED dd50efb, dispatch pass (2ª), feat a0c2b33, verify pass seq 1938, bun test 812/0, ready/ginga.json regravado (achado judge 04:05: web/metrics.js agora monta failures_by_reason + cost_by + SVG/tabela irmã)
- 2026-11-03T05:36:53-03:00 merge-gate ginga plan/0014: exit 11 (judge reprovou (fail))
2026-11-03 TASK-17 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"scope_drift"
2026-11-03 TASK-17 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 fail "reason_code":"command_failed"
2026-11-03 TASK-17 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 2 fail "reason_code":"command_failed"
2026-11-03 TASK-17 pi:nvidia/stepfun-ai/step-5-preview tentativa 3 fail "reason_code":"command_failed"
2026-11-03 TASK-17 pi:nvidia/stepfun-ai/step-5-preview tentativa 4 fail "reason_code":"scope_drift"
2026-11-03 TASK-17 pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b tentativa 5 pass
2026-11-03 r2 lane-ginga-20261103-0741-r2 (operador): TASK-17/T366 resolvida pelo operador após 5 dispatches falharem (command_failed x3, scope_drift x1 por __pycache__ rastreado, 1 bloqueado). Implementação própria em 850c83b (syncCost ts=session.created + planTaskForDirectory + resolve em costSync); pinga verify tasks/T366/PLAN.md pass (seq 1948); bun test 816/0; ready/ginga.json regravado {"branch":"plan/0014"}; ledger ok 1949.

## 2026-11-03 r3 lane-ginga-20261103-0813-r3 (operador)
- Achados do judge do prompt (TASK-07 ts=sync, AC plan/task nulos) já estavam resolvidos em HEAD `850c83b` (T366, r2); judge 08:11 verdict pass (17 itens + AC, 816/0). Re-verificado: `bun test tests/cost_sync_ts.test.ts` 4/0; `pinga verify tasks/T366/PLAN.md` pass (seq 1950); ledger ok 1950; fila T342–T366 toda done/pass; `ready/ginga.json` = {"branch":"plan/0014"}.
- Bloqueio real: main do ginga suja com WIP de executor da T366 (07:42). Arquivada em `.ginga/_archive/2026-11-03-main-suja-ginga-r3/` (MANIFEST) e main restaurada (`git status --porcelain` vazio). Worktree limpa. Registrado em decisoes.md e no REPORT .d/lane-ginga-20261103-0813-r3.md.
- Backlog: 0 itens abertos.
2026-11-03 TASK-18 pi:nvidia/minimaxai/minimax-m3.1-flash tentativa 1 pass

## 2026-11-03 r1 lane-ginga-20261103-1130-r1 (operador)
- Achado grave do judge 11:23 (gate fail, AC/TASK-02): `resets_at` epoch numérico nos rollouts reais do Codex não era aceito por `src/quota/codex.ts`/`src/quota/claude.ts` (só string) → quota `stale` com dados reais, sem evento `quota`, `cap_ok` sem bloquear. Achados do prompt (TASK-07 ts do syncCost, plan/task nulos) já estavam resolvidos em HEAD `850c83b` (T366) e o judge 11:23 confirma TASK-07 ok.
- TASK-18 criada no PLAN (`TASK-18-quota-resets-epoch.md`, `pinga_task: T367` = máx ledger 366 + 1); RED `tests/quota_resets_epoch.test.ts` commitado `01c60ce`, `pinga prove-red` pass (RED no base). Dispatch pass na 1ª (pi:nvidia/minimax-m3.1-flash); feat `0a38eb3` (`normalizeResetsAt` nos dois parsers, epoch s/ms → ISO); `pinga verify tasks/T367/PLAN.md` pass seq 1960 (attempt 7, após `git checkout --` do pyc sujo em `contrib/hermes-plugin/__pycache__`); `bun test` focado 19/0; suíte completa 822/0; fila 150 done/pass; ledger ok 1960; `ready/ginga.json` = `{"branch":"plan/0014"}` regravado.
- Backlog: 0 itens abertos.

## 2026-11-03 r2 lane-ginga-20261103-1202-r2 (operador)
- Achados do judge do prompt (TASK-07 ts do syncCost, AC plan/task nulos) já resolvidos em HEAD `0a38eb3` (T366 `850c83b`, T367 `0a38eb3`): judge 120117 verdict pass; fila 150 done/0 open; `bun test` 822/0 (focado cost/quota 23/0); `ready/ginga.json` = `{"branch":"plan/0014"}` regravado; pyc sujo da worktree revertido. Backlog: 0 abertos. Relatório em `.ginga/handoffs/REPORT-2026-10-28.d/lane-ginga-20261103-1202-r2.md`.
- 2026-11-03T14:45:47-03:00 merge-gate ginga plan/0014: exit 0 (mergeado 2c5f516)

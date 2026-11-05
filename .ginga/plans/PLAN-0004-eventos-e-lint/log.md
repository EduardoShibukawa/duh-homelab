# Log — PLAN-0004

## 2026-10-27

- PLAN criado em draft pelo Planner a partir da SPEC-0001.
- 2026-10-27 status: draft → approved (aprovado pelo dono ao pedir a passada RED do PLAN-0004, PLAN-0005 e PLAN-0007).
- 2026-10-27 passada RED: TASK-01 → T1, TASK-02 → T2, TASK-03 → T3, TASK-05 → T4, TASK-06 → T5, TASK-07 → T6 (repo `ginga`, worktree `../ginga-plan-0004`, branch `plan/0004`); TASK-04 → T57 (repo `pi-harness`, worktree `../pi-harness-plan-0004`). prove-red RED (pass no ledger) nas sete, base = `chore: init` do ginga / HEAD do pi-harness. T3 e T57 reprovadas (attempts 2) depois de endurecer o helper de leitura.
- 2026-10-27 notas do Planner (nada de `touch`/`done_when`/`goal` mudou): (1) a TASK não fixa a assinatura, então o teste fixa: `emitEvent(ev)` em `src/events/emit.ts`, `validateEvent(ev) → {ok, errors}` em `src/events/validate.ts`, `ginga events migrate <in> --out <out>` imprime a contagem de linhas inválidas, `ginga lint` com `--json` → `{ok, errors:[{file,field,message}]}` e `ginga lint <dir> --export okf <saida>`. (2) "IDs sequenciais" (TASK-06): o teste só exige unicidade, porque o próprio bundle do workspace não tem PLAN-0001 e falharia numa regra de "sem buracos". (3) `tests/fixtures/bundle-ok|bad` e `pi-harness-events.jsonl` são do Planner; o fixture de eventos usa linhas reais do `state/events.jsonl` (mais um verify com failed>0 e uma linha inválida, sintéticos). (4) No `tasks/T4/PLAN.md` o diretório `tests/fixtures/bundle-*` foi expandido em arquivos, porque o `prove-red` copia `tests_frozen` com `copyFileSync`.
2026-10-27 TASK-01 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-02 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-03 opencode-go/kimi-k3 tentativa 1 fail {"v":1,"type":"task.receipt","id":"08148efa-b40a-4085-a728-af82246217c1","task":"T3","repo":"/home/shibuka/Projetos/duh-
2026-10-27 TASK-03 opencode-go/kimi-k3 tentativa 2 fail {"v":1,"type":"task.receipt","id":"8d64bb54-e643-466c-8307-55fb03b791f1","task":"T3","repo":"/home/shibuka/Projetos/duh-
2026-10-27 TASK-03 opencode-go/glm-5.3 tentativa 3 fail {"v":1,"type":"task.receipt","id":"d9384cff-a37f-48fa-9ebc-e5dbf8fe2b9f","task":"T3","repo":"/home/shibuka/Projetos/duh-
2026-10-27 TASK-03 opencode-go/glm-5.3 tentativa 4 fail {"v":1,"type":"task.receipt","id":"6d72e77d-e56d-41a6-8686-4cebee047e60","task":"T3","repo":"/home/shibuka/Projetos/duh-
2026-10-27 TASK-03 opencode-go/qwen3.8-max tentativa 5 fail {"v":1,"type":"task.receipt","id":"573542e2-7126-4213-ba3d-bdfe8b7e4ecd","task":"T3","repo":"/home/shibuka/Projetos/duh-
2026-10-27 TASK-03 opencode-go/qwen3.8-max tentativa 6 fail {"v":1,"type":"task.receipt","id":"284a3f5e-53c8-4fe2-a357-4e911e39c413","task":"T3","repo":"/home/shibuka/Projetos/duh-
2026-10-27 TASK-04 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-05 blocked (dep: TASK-03-eventos-migrar)
2026-10-27 TASK-06 blocked (dep: TASK-05-lint-frontmatter)
2026-10-27 TASK-07 blocked (dep: TASK-06-lint-relacoes)
- 2026-10-27 breaker da TASK-03 (T3 do ginga): o `attempts: 8` é só a contagem de receipts (`1 + receipts da task no escopo do repo`, `verify.ts:151`; T3 do ginga tem 2 passes antigos, seq 195/215, mais 6 fails seq 220-225). O breaker (`breaker.ts`, `shouldTrip`) só dispara com a MESMA `failure_signature` (exit + sha256 da saída + reason_code) em falhas consecutivas: as 6 assinaturas dos seq 220-225 são todas diferentes (81a6ecf7, fafe4785, c2662c7c, 1985bbb3, 62c0c9cd, 10d64e11), e todos os receipts são `fail/command_failed`, nenhum `blocked`/`breaker_same_failure`. `pinga queue` mostra T3 `open` (receipt seq 225 fail), não `blocked`; não há teto de tentativas no verify. Conclusão: nada a destravar, não precisou de `supersede`. Risco ao retomar: se uma nova tentativa falhar com a MESMA assinatura de uma falha imediatamente anterior, o breaker dispara (exit 4); aí o caminho oficial é `pinga supersede T3 --reason ...`.
2026-10-27 TASK-03 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-27 TASK-03 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-27 TASK-03 opencode/deepseek-v4.1-flash-free tentativa 3 fail BLOCKED BLOCKED: o repo só contém `tests/` — não existem `bin/ginga.ts`, `src/cli.ts` nem `src/events/valida
2026-10-27 TASK-03 opencode/deepseek-v4.1-flash-free tentativa 4 fail BLOCKED BLOCKED: o repo só contém `tests/` — não existem `bin/ginga.ts`, `src/cli.ts` nem `src/events/valida
2026-10-27 TASK-03 opencode/deepseek-v4-pro tentativa paga 1: US$0.13801709 (custo medido; sessão ses_e807502d9ffe097GNGeDbdNX6d; TASK acumulado US$0.138017; total das TASKs US$0.138017)
2026-10-27 TASK-03 opencode/deepseek-v4-pro tentativa 5 fail BLOCKED BLOCKED: T3 depende de T1/T2 não implementados — `bin/ginga.ts`, `package.json`, `src/events/validat
2026-10-27 TASK-03 opencode/deepseek-v4-pro tentativa paga 2: US$0.13430247999999997 (custo medido; sessão ses_e80743d59ffeMUmnq9in5MPW3W; TASK acumulado US$0.272320; total das TASKs US$0.272320); abortada: estourou o teto
2026-10-27 TASK-05 blocked (dep: TASK-03-eventos-migrar)
2026-10-27 TASK-06 blocked (dep: TASK-05-lint-frontmatter)
2026-10-27 TASK-07 blocked (dep: TASK-06-lint-relacoes)
- 2026-10-27 20:23 RERUN: a restore() antiga apagou o código das TASKs já pass (nada commitado); dispatch corrigido (snapshot da árvore inteira, teto 0,50/2,00 checado antes). Reexecução do PLAN inteiro.
2026-10-27 TASK-01 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-02 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-03 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-27 TASK-03 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-27 TASK-03 opencode/deepseek-v4.1-flash-free tentativa 3 pass
2026-10-27 TASK-05 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-27 TASK-05 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-27 TASK-05 opencode/deepseek-v4.1-flash-free tentativa 3 pass
2026-10-27 TASK-06 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-27 TASK-06 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-27 TASK-06 opencode/deepseek-v4.1-flash-free tentativa 3 pass
2026-10-27 TASK-07 opencode/glm-5.3-flash-free tentativa 1 fail BLOCKED BLOCKED: os 2 fails restantes são um bug da própria suíte frozen — `walk()` usa `relative(dir, p)` c
- 2026-10-27 20:55 TASK-07: bug no teste congelado (walk() usava relative(dir) da recursão, arquivos aninhados ficavam sem prefixo e a suíte era insatisfazível); corrigido para relative(root); prove-red refeito. Execução anterior (glm, tentativa 1 BLOCKED correta) interrompida.
2026-10-27 TASK-07 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-07 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 judge (Codex gpt-6-luna + Gemini 3.8 flash; argon sem cota): fail simples → TASKs de fix criadas (ver TASK-08/09). Correção do teste da TASK-07 (0004) confirmada legítima pelos dois.
2026-10-27 TASK-08 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-27 TASK-09 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 judge rodada 2: fail simples → TASK-10-fix-okf-e-numeracao.
2026-10-27 TASK-10 opencode/glm-5.3-flash-free tentativa 1 fail "reason_code":"command_failed"
- 2026-10-27 TASK-10 tentativa travada de novo no serviço 49374 (0% CPU, 8 min); dispatch abortado pelo operador, worktree restaurada do snapshot. Script agora usa --standalone + timeout 1200s. Redespachado.
2026-10-27 TASK-10 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 judge rodada 3: flash pass, Codex fail (simples): validate.ts aceita data impossível (2026-02-30); TASK-foo.md sem type: task escapa do lint de nome. Limite de 2 rodadas de fix atingido -> blocked, decisão do dono.
- 2026-10-27 dono: "boraa" (fazer tudo) → rodada 3 de fix autorizada: TASK-11 (T9).
2026-10-27 TASK-11 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 judge rodada 4 (Codex): fail simples — TASK-*.md sem frontmatter só recebe erro genérico, não o de nome → TASK-12 (T10).
2026-10-27 TASK-12 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-27 TASK-12 opencode/glm-5.3-flash-free tentativa 1 pass (dispatch). Operação passada ao Pi: .ginga/prompts/pi-operador-2026-10-27.md
- 2026-10-27 judge rodada 5 (Codex gpt-6-luna): TASK-12 ok (nome de TASK sem frontmatter corrigido), mas fail com 2 achados NOVOS (simples): (1) src/events/validate.ts:32-39 limita transition.data.by a owner/system, mas docs/events-v1.md:26 admite <papel> (qualquer papel); (2) pi-harness src/harness/events.ts appendEvent emite sem limite de 4 KiB (docs/events-v1.md:9 exige < 4 KiB). Limite de rodadas de fix esgotado → status: blocked, aguardando dono.
- 2026-10-28 passada RED (Planner Pi, rodada 5 fix): TASK-13 → T18 (ginga, `by` aceita <papel>), TASK-14 → T60 (pi-harness, 4 KiB). prove-red "sem base" (sem commit `test(T<N>): RED`); RED demonstrado à mão: ginga events_fix2 4 fail (planner/judge/red-team/executor), pi-harness harness_events_v1_fix2 1 fail (linha >= 4 KiB não recusada).
2026-10-28 TASK-13 opencode/glm-5.3-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-13 opencode/deepseek-v4.1-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-13 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-28 TASK-13 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-28 TASK-13 opencode/deepseek-v4-pro tentativa paga 1: US$0.07305205 (custo medido; sessão ses_e7e0eae6cffeIjCok5POP22sZT); pass (free esgotado, despacho manual)
2026-10-28 TASK-14 opencode/deepseek-v4-pro tentativa paga 1: US$0.13004211 (custo medido; sessão ses_e7e0e051dffertNgZtazPfOamM); pass (free esgotado, despacho manual)

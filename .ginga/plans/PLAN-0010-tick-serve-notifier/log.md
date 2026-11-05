# Log — PLAN-0010

## 2026-10-27

- PLAN criado em draft pelo Planner a partir da SPEC-0001.

## 2026-10-28

- passada RED (ginga, worktree `ginga-plan-0010`): TASK-01 → T13, TASK-02 → T14, TASK-03 → T15, TASK-04 → T16, TASK-05 → T17; prove-red RED em todos.
- **replan necessário (TASK-06, p-inga):** o `done_when` roda `tests/discord.test.ts`, cujo caso 1 exige o canal fixo `<DISCORD_HOME_CHANNEL_ID>` e um token vindo de `~/.hermes` — exatamente o que o goal manda remover. Com o contrato novo esse teste não pode passar, e `tests/discord.test.ts` não está no `touch` nem em `tests_frozen`. Escrevi `tests/discord_events.test.ts` em `p-inga-plan-0010` (RED confirmado, 5 falhas de 8), mas **não** materializei `tasks/T<N>/PLAN.md` nem escrevi `pinga_task`. Opções: incluir `tests/discord.test.ts` no `touch` (e atualizar o caso 1) ou tirá-lo do `done_when`.
- Notas: `ginga-plan-0010` nasceu do commit `chore: init`, sem o código do PLAN-0004 (`src/events/validate.ts`, `bin/ginga.ts`); o RED de hoje vem de arquivos inexistentes, e o executor deve rebasear `plan/0010` sobre o PLAN-0004 primeiro. A TASK-02 diz "PLAN não pausado", mas não define onde a pausa é guardada (05 só cita o verbo `pause`): não há teste para isso. Na TASK-05, "aprovação" foi codificada como `transition` de spec/plan para `awaiting_approval`. Contratos escolhidos nos testes: `lease_until` em epoch ms; despacho com exit 0 → `status: dispatched` (não repete), exit ≠ 0 → `failed` (repete); fila via `[commands].queue`; ingestão pula linha inválida com exit 0; `routeEvents(db, {send, targets, mention?, rules?})`.
- 2026-10-28 replan TASK-06 (Planner Pi): `tests/discord.test.ts` caso 1 usava o `~/.hermes` real + canal fixo, contradizendo o goal. Decisão: usar HOME falso (env `DISCORD_BOT_TOKEN`/`DISCORD_CHANNEL_ID`). `tests/discord.test.ts` entra no `touch` e em `tests_frozen`; o "Fazer" ganha a atualização do caso 1.
2026-10-28 TASK-01 opencode/deepseek-v4.1-flash-free quota/rate limit (Free usage limit); pula para o próximo modelo, não conta como tentativa
2026-10-28 TASK-01 opencode/nemotron-3-ultra-free tentativa 1 fail "reason_code":"command_failed"
2026-10-28 TASK-01 opencode/nemotron-3-ultra-free tentativa 2 fail "reason_code":"command_failed"
2026-10-28 TASK-01 opencode/deepseek-v4-pro pago NÃO tentado (paid_tries=0, estimativa=2.0166, gasto TASK=0.000000, total=3.526930, folga=-1.5269)
2026-10-28 TASK-01 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-28 TASK-02 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-28 TASK-03 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-28 TASK-05 opencode/glm-5.3-flash-free tentativa 1 pass
2026-10-28 TASK-06 opencode/glm-5.3-flash-free tentativa 1 fail 
2026-10-28 TASK-06 opencode/glm-5.3-flash-free tentativa 2 fail 
2026-10-28 TASK-06 opencode-go/beam-free tentativa 3 fail 
2026-10-28 TASK-06 opencode-go/beam-free tentativa 4 fail 
2026-10-28 TASK-06 opencode-go/iceman-contributor-free tentativa 5 fail 
2026-10-28 TASK-06 opencode-go/iceman-contributor-free tentativa 6 fail 
2026-10-28 TASK-06 opencode/deepseek-v4.1-flash-free tentativa 7 fail 
2026-10-28 TASK-06 opencode/deepseek-v4.1-flash-free tentativa 8 fail 
- 2026-10-28T14:28:10-03:00 merge-gate ginga plan/0010: exit 2 (conflito no merge)
- 2026-10-28T15:49:31-03:00 merge-gate ginga plan/0010: exit 2 (conflito no merge)
- 2026-10-28T16:06:00-03:00 merge-gate ginga plan/0010: exit 2 (conflito no merge)
- 2026-10-28T20:44:24-03:00 merge-gate ginga plan/0010: exit 12 (sem receipt done: T19 T20 T21 T22 T23)
## 2026-10-28 (rodada 2, operador GLM)
- receipts T19–T23 selados em `pass` no ginga-plan-0010 (T19 via claim baseline; T20–T23 direto), T16 do PLAN-0006 re-verificado no `ginga` main (tick tinha selado scope_drift espúrio).
- TASK-06 materializada como **T23 no p-inga** (id livre fila p-inga): RED (e6707c7, c729274), implementação (392abf9), receipt seq 448 `pass`. `pinga notify` e `queue --notify` agora só emitem evento `blocker` v1 em $GINGA_EVENTS; `resolveDiscordConfig` só ambiente; frozen `discord.test.ts` caso 1 no HOME falso (commit RED c729274, conforme replan do Planner Pi de 2026-10-28).
- ready/ginga.json regravado. Suíte p-inga 458 pass / 0 fail; suíte ginga (PLAN-0010) 47 pass / 0 fail.
- 2026-10-28T20:55:37-03:00 merge-gate ginga plan/0010: exit 0 (mergeado 57d6c0d)
- 2026-10-28T21:06:31-03:00 merge-gate p-inga plan/0010: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T21:08:57-03:00 merge-gate p-inga plan/0010: exit 11 (1 item(ns) com regression=true)
- 2026-10-28T21:08:58-03:00 judge-run p-inga: FORCE_REJUDGE no HEAD 0e2a07dc67930977d6a071746c14be8c6c635ad9
- 2026-10-28T21:10:08-03:00 judge-run p-inga: FORCE_REJUDGE no HEAD 0e2a07dc67930977d6a071746c14be8c6c635ad9
- 2026-10-28T21:10:30-03:00 Claude: veredito p-inga do PLAN-0010 com prompt corrompido movido para judge/invalid/ (não pode ser usado pelo gate)
- 2026-10-28T21:12-03:00 TASK-07 criada (follow-up do judge da 20:55, TASK-05 → T26): RED committado 5043550 (`tests/notify_thread_id.test.ts` novo, fora do frozen legado; tests_frozen = o próprio teste novo, preced. T24), `pinga prove-red` pass (done_when exit 1 no base). Executor despachado (`TASK-07-discord-thread-id.md`, escada free). Merge main→plan/0010 ok (só f294334/T24 entrou).
2026-10-28 TASK-07 opencode/glm-5.3-flash-free tentativa 1 pass
- 2026-10-28T21:20-03:00 TASK-07 (T26): executor glm-free tentativa 1 `pass` (paid_cost 0); fix 2a27383 (`fallback Discord extrai o id da resposta e devolve thread_id`). receipt T26 seq 478 `pass`. Suite: 214 pass / 0 fail. `pinga ledger verify`: ok 478. Fila: done 24 / open 0. `ready/ginga.json` = `{"branch":"plan/0010"}`.
- 2026-10-28T21:13:30-03:00 merge-gate p-inga plan/0010: exit 0 (mergeado 25a9110)
- 2026-10-28T21:14:31-03:00 merge-gate ginga plan/0010: exit 0 (mergeado 237fb39)
- 2026-10-28T22:50:35-03:00 Claude: ready/p-inga.json recriado às 22:48 por processo não identificado, com a branch sem commits além da main (já mergeado); movido para ready/done
- 2026-10-28T22:51:13-03:00 merge-gate ginga plan/0010: exit 13 (falha nova na branch: (fail) ingestEvents usa o root informado > grava no state.db do root, não do cwd )
- 2026-10-28T23:11:29-03:00 merge-gate ginga plan/0010: exit 0 (mergeado 5a0a231)

Você é o operador do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). O dono disse em 2026-10-28: **"fixe tudo"**.

Leia antes:
- `.ginga/handoffs/HANDOFF-2026-10-28-onda-3.md` e `HANDOFF-2026-10-27-ondas-1-2.md`;
- `.ginga/prompts/operador.md` e `.ginga/prompts/planner-red.md`.

## Regras

- **Tudo pelo harness:** TASK + teste RED congelado + despacho + `pinga verify` + judge + merge. Nenhuma edição direta.
- **Planner = você** (Pi), **não** `claude -p`: a quota do Claude acabou.
- **Executor:** free pelo `.ginga/bin/dispatch-task.sh` (ou `manda run` quando houver `[runtimes]`).
- **Judge:** Codex `gpt-6-luna`, `-s read-only`.
- **Nunca** push nem `opencode-go`. Nunca apagar: `_archive/` com MANIFEST. Commit com caminhos explícitos.
- **Discord** a cada etapa (`HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<msg>"`). Só marque algo como crítico se precisar do dono.
- **Uma TASK por repo de cada vez.** Antes de atribuir T<N>, confira no ledger que o id está livre naquele repo.
- **Regra nova do dono:** esta é a última rodada de fix para os achados atuais. Se depois dela o judge trouxer itens **novos** (não regressões da fix), **faça o merge** e abra os itens novos como TASKs de follow-up num PLAN novo (draft). Só uma **regressão** bloqueia o merge.

## Fila

1. **PLAN-0004** (`ginga-plan-0004` + `pi-harness-plan-0004`): TASK-13, fix dos 2 achados da rodada 5.
   - `src/events/validate.ts:32-39`: `transition.data.by` aceita `<papel>`, conforme `docs/events-v1.md:26`.
   - pi-harness `src/harness/events.ts` `appendEvent`: recusa ou trunca eventos com 4 KiB ou mais (`events-v1.md:9`). Precisa de um sidecar no pi-harness com id livre.
   - Depois: judge e **merge** nos dois repos (ginga e pi-harness), `pinga ledger verify`, `runs/` para o repo principal, remover as worktrees (as branches ficam), `status: done`.
2. **PLAN-0018** (`p-inga-plan-0018`): TASK-07, fix dos 2 achados da rodada 3.
   - Holdout do `verify` com exit 97 → `blocked/infra`, não `overfit_holdout/fail`.
   - `prove` no exit 97 grava `blocked`, não `not run`.
   - Depois: judge e merge em `p-inga/main`, como acima. Depois do merge, rode as suítes de ginga e manda via `PINGA_EXEC_WRAPPER=.ginga/bin/sandbox-done-when.sh` para confirmar.
3. **PLAN-0010 TASK-06:** replan. O `done_when` não pode depender de `tests/discord.test.ts` (que usa o `~/.hermes` real): use HOME falso, como em `tests/helpers/home.ts`, ou tire esse teste do `done_when`. Registre no `log.md`.
4. **Onda 3:**
   - **PLAN-0008:** TASK-02 a TASK-08, no p-inga uma de cada vez. Crie `.ginga/project.toml` com `[runtimes]` quando a TASK correspondente pedir, e passe a despachar com `manda run`.
   - **Depois do merge do 0004:** PLAN-0006 e PLAN-0010, recriando as worktrees do ginga a partir da main nova.
   - Fechar com judge e merge.
5. **Fim:**
   - atualize `.ginga/index.md` (o quadro) e um handoff novo;
   - mande um resumo de 5 linhas no Discord: o que foi mergeado, o que ficou blocked e o que precisa do dono.

Se uma etapa travar por motivo que não seja de código (cota, infra, decisão), avise no Discord e siga para a próxima.

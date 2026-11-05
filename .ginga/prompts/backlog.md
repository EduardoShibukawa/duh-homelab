# SUBSTITUÍDO em 2026-10-28 15:20 por backlog-<repo>.md (lanes paralelas, .ginga/bin/lane.sh)
- [x] PLAN-0006 (ginga): mergeado pelo gate em 0563295 (ginga 162/0).
- worktree: ginga-plan-0006
- [ ] PLAN-0010 (ginga): o gate deu exit 2 (conflito). O 0006 já ocupou T13–T16 e T18 no ginga, e a `plan/0010` usa T13–T18: os ids colidem. Faça `git merge main` na `plan/0010` e renumere as TASKs do 0010 para ids livres (T19+, conferindo no `pinga queue`), atualizando o `pinga_task` dos `TASK-*.md`. Re-verifique cada uma (`pinga verify`) e corrija os achados do judge (fetch no serve, ingest antes de rotear, thread_id). A TASK-06 é do p-inga: use uma worktree `p-inga-plan-0010` separada, com `ready/p-inga.json` próprio. Depois, o `ready`.
- worktree: p-inga-plan-0010
- worktree: ginga-plan-0010
- [ ] PLAN-0020 (ginga): validar `cost_usd` em eventos v1 (follow-up do judge do 0004). Crie a TASK + o RED, despache, verify e grave o `ready`.
- [ ] PLAN-0021 (p-inga): teste comportamental do holdout com exit 97 (follow-up do judge do 0018).
- [ ] PLAN-0022 (manda + ginga): TASK-01 `manda merge` e TASK-04 `ginga hooks install|check`. As TASK-02/03 vêm depois. Só despache quando o PLAN-0018 sair do `ready` no p-inga (uma TASK por repo).
- [ ] PLAN-0017: pi-harness sai. **Não edite o pi-harness/.** Confira se o host adapter `pi` no manda cobre o que o `pi-run.sh` e o fluxo atual usam; liste as lacunas no `log.md` do PLAN. O arquivamento é feito pelo Claude depois.

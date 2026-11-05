# Relatório operador — lane manda, rodada 2 (2026-10-31, após gate 20:20)

Escopo: só repo `manda`. Achados do judge primeiro; backlog depois (máx. 2 itens).

## Item 1 (achados do judge, PLAN-0029, gate exit 11 às 20:20) — RESOLVIDO

Achados (`judge/manda-20261031T201921.log`): TASK-09/TASK-11 graves — `watchAttempt` existia mas nada em `src/run.ts` o chamava; o laço de `attemptSpecs` não consultava `breakerOf`; sem amostragem de /proc, probe nem kill pelo pid no run real. AC: os 4 fails do `bun test` são os mesmos da main (não regressivos).

- TASK nova criada: `.ginga/plans/PLAN-0029-rota-de-falhas-e-disjuntor/TASK-12-ligar-vigia-ao-vivo-no-run.md` (pinga_task T309, id livre na fila).
- RED: `manda-plan-0029/tests/attempt_watch_live.test.ts` (novo, congelado da T309) + `tasks/T309/PLAN.md`; commit `test(T309): RED` = `9d662a4` em `plan/0029`.
- `pinga prove-red tasks/T309/PLAN.md`: pass — RED falha no base (done_when exit 1; os 2 testes novos falham nas assertions esperadas, congelados passam).
- Dispatch `.ginga/bin/dispatch-task.sh TASK-12-*.md`: `{"status":"pass","model":"pi:nvidia/stepfun-ai/step-5-preview","attempts":1,"paid_cost_usd":0}`.
- GREEN: `onPid` em `RunRequest`/`SpawnFn`/`defaultSpawn` + adapters opencode/pi/claude/codex; `src/proc_sample.ts` novo (sampler real); `watchAttempt` em paralelo ao `adapter.run` (run.ts:481); `breakerOf` pula disjuntor aberto (run.ts:330); `killByPid` pelo pid (run.ts:256). Commit `feat(T309)` = `2ee2fbd` em `plan/0029` (o executor deixou o diff sem commit; commitei como operador dentro da TASK com RED).
- `pinga verify tasks/T309/PLAN.md`: **pass** (receipt aeeb86eb). Focado (live+watch+watch_run): 8/0. Suíte: `bun test` **341 pass / 4 fail** (4 preexistentes da main). `pinga ledger verify`: ok 1508. Fila: T309 done, 0 open.
- `ready/manda.json` regravado: `{"branch":"plan/0029"}`.

## Item 2 (backlog) — BLOQUEADO, nada feito

- PLAN-0013 TASK-07: `git -C ginga log main` não tem PLAN-0013 (grep 0).
- PLAN-0033 TASK-07: `git -C ginga cat-file -e main:contrib/guard/pi.ts` falha (guard ausente).
- PLAN-0034 TASK-01: manda main tem PLAN-0028 e PLAN-0032, mas não PLAN-0029 (ainda barrado no gate) nem 0033-T07.

## Fatos diversos

- Decisão registrada em `.ginga/handoffs/REPORT-2026-10-28.d/decisoes.md` (criação da TASK-12/T309, coberta pela regra de TASK de correção nova).
- PLAN.md do PLAN-0029 ganhou a TASK-12 na lista; log.md do PLAN atualizado.
- Não rodei judge/gate/merge; não toquei em main; não editei tests_frozen existentes.

## Observação (não minha): `git -C manda status` mostra `?? src/ladder.ts` e `?? tests/ladder.test.ts` (untracked, mtime 2026-10-31 04:09 -03:00, rodada anterior). Não toquei no diretório main do manda (regra). O gate pode sair com exit 2 por isso — fora do meu escopo.

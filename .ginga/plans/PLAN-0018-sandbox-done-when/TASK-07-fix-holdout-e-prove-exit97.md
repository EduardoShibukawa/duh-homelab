---
type: task
mode: mvp
goal: "exit 97 no holdout do verify e no prove grava blocked/infra, não overfit_holdout nem not run"
title: Fix do judge (rodada 3)
plan: PLAN-0018-sandbox-done-when
repo: p-inga
pinga_task: T75
depends_on: [TASK-05-fix-supersede-exit97]
tier: free
touch: [src/verify.ts, src/prove.ts, tests/exec_wrapper_fix3.test.ts]
done_when: "bun test tests/exec_wrapper_fix3.test.ts tests/exec_wrapper_fix2.test.ts tests/exec_wrapper_fix.test.ts tests/exec_wrapper.test.ts tests/verify.test.ts tests/prove.test.ts tests/plan_verify.test.ts"
tests_frozen: [tests/exec_wrapper_fix3.test.ts]
---
## Fazer
- `src/verify.ts` (ramo do holdout, ~linha 460-500): quando `hRun.exit === WRAPPER_UNAVAILABLE_EXIT` (97), selar `blocked` com `reason_code: infra` (e `cliExit = PROVE_EXIT.infra`), em vez de cair em `overfit_holdout/fail` ou no disjuntor.
- `src/prove.ts` (~linha 525-530): quando o done_when sai 97 (prova inconclusiva por sandbox indisponível), selar `blocked` com `reason_code: infra`, em vez de `not run`.
## Não fazer
- Não alterar testes frozen nem `REASON_CODES`. Não mudar o caminho do exit 0 nem o do exit != 0 comum.
## Contexto
- Judge Codex (rodada 3): (1) verify.ts holdout com exit 97 cai em overfit_holdout/fail; (2) prove.ts sela "not run" no exit 97. Teste RED em `tests/exec_wrapper_fix3.test.ts` (frozen).

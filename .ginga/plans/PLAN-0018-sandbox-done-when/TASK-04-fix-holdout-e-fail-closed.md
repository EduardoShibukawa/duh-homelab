---
type: task
mode: mvp
goal: "holdout passa pelo wrapper e prove/plan_verify/supersede são fail-closed (exit 97 = infra com precedência)"
title: Fix do holdout e fail-closed (judge Codex)
plan: PLAN-0018-sandbox-done-when
repo: p-inga
pinga_task: T72
depends_on: [TASK-01-exec-wrapper]
tier: free
touch: [src/examples.ts, src/prove.ts, src/plan_verify.ts, src/supersede.ts, tests/exec_wrapper_fix.test.ts]
done_when: "bun test tests/exec_wrapper_fix.test.ts tests/exec_wrapper.test.ts tests/verify.test.ts tests/plan_verify.test.ts tests/queue.test.ts"
tests_frozen: [tests/exec_wrapper_fix.test.ts]
---
## Fazer
- `src/examples.ts` `runHoldout` (~linha 486): trocar o `Bun.spawnSync(["bun", "test", ...])` nu por `doneWhenArgv(\`bun test ./${runnerRel}\`, workDir)` (importar `doneWhenArgv` de `./exec`); o `cwd` continua `workDir`.
- `src/prove.ts`, `src/plan_verify.ts`, `src/supersede.ts`: chamar `wrapperProblem()` logo no início (antes de qualquer `Bun.spawnSync` do done_when), como em `src/verify.ts:113`; se retornar problema, imprimir a mensagem (cita `PINGA_EXEC_WRAPPER`) e sair != 0 sem rodar nada (prove/plan_verify: `PROVE_EXIT.infra`; supersede: `SUPERSEDE_EXIT.command_failed`).
- `src/prove.ts` `combineProof`: quando o done_when é `inconclusive` (inclui exit 97 = `WRAPPER_UNAVAILABLE_EXIT`), ele tem precedência sobre o veredito do holdout — o holdout não pode transformar um infra em `test_passed_on_base`.
## Não fazer
- Não alterar testes frozen nem `REASON_CODES`. Não rodar o pinga em si dentro do wrapper.
## Contexto
- Judge Codex reprovou a TASK-01: o holdout contornava o wrapper e prove/plan_verify/supersede não eram fail-closed. Teste RED em `tests/exec_wrapper_fix.test.ts` (frozen).

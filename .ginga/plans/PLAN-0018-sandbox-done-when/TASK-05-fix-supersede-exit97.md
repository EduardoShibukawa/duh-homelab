---
type: task
mode: mvp
goal: "supersede sela receipt blocked/infra quando o wrapper sai 97"
title: Fix do supersede exit 97 (judge Codex rodada 2)
plan: PLAN-0018-sandbox-done-when
repo: p-inga
pinga_task: T73
depends_on: [TASK-04-fix-holdout-e-fail-closed]
tier: free
touch: [src/supersede.ts, tests/exec_wrapper_fix2.test.ts]
done_when: "bun test tests/exec_wrapper_fix2.test.ts tests/exec_wrapper_fix.test.ts tests/exec_wrapper.test.ts tests/verify.test.ts tests/plan_verify.test.ts tests/queue.test.ts"
tests_frozen: [tests/exec_wrapper_fix2.test.ts]
---
## Fazer
- `src/supersede.ts` (~linha 127): quando o done_when sai 97 (`WRAPPER_UNAVAILABLE_EXIT`), selar um receipt `blocked` com `reason_code: infra` (evidence com o exit 97 e o artefato já escrito) e imprimi-lo via `console.log(JSON.stringify(receipt))`, em vez de só retornar `SUPERSEDE_EXIT.command_failed` sem selar nada. O exit do CLI continua != 0.
## Não fazer
- Não alterar testes frozen nem `REASON_CODES`. Não mudar o caminho do exit 0 (superseded) nem o do exit != 0 comum (command_failed sem receipt).
## Contexto
- Judge Codex (rodada 2): supersede retorna erro no exit 97 sem selar receipt blocked/infra, contrariando PLAN.md:18. Teste RED em `tests/exec_wrapper_fix2.test.ts` (frozen).

---
type: task
mode: mvp
goal: "done_when roda via PINGA_EXEC_WRAPPER (fail-closed) em verify, prove, plan_verify e supersede"
title: Wrapper de execução do done_when
plan: PLAN-0018-sandbox-done-when
repo: p-inga
pinga_task: T71
depends_on: []
tier: free
touch: [src/exec.ts, src/verify.ts, src/prove.ts, src/plan_verify.ts, src/supersede.ts, tests/exec_wrapper.test.ts]
done_when: "bun test tests/exec_wrapper.test.ts tests/verify.test.ts tests/plan_verify.test.ts tests/queue.test.ts tests/receipt_events_v1.test.ts"
tests_frozen: [tests/exec_wrapper.test.ts]
---
## Fazer
- Criar `src/exec.ts` com `export function doneWhenArgv(cmd: string, root: string, env = process.env): string[]`: sem `PINGA_EXEC_WRAPPER` (ou vazio), `["sh","-c",cmd]`; com ele, `[wrapper, root, "sh", "-c", cmd]`.
- Trocar os `Bun.spawnSync(["sh", "-c", plan.done_when]` de `src/verify.ts:359`, `src/prove.ts:363`, `src/plan_verify.ts:259` e `src/supersede.ts:101` por `doneWhenArgv(...)`, com a raiz do repo (ou o worktree do base no prove) como `root`.
- **Fail-closed** em verify: com o wrapper definido e inexistente ou não executável, não rodar nada; mensagem com `PINGA_EXEC_WRAPPER` e exit != 0.
- Exit 97 do wrapper: receipt `status: blocked`, `reason_code: infra` (já existe em `REASON_CODES`).
- Testes RED do Planner em `tests/exec_wrapper.test.ts` (frozen).
## Não fazer
- Não alterar testes frozen nem `REASON_CODES`. Não rodar o pinga em si dentro do wrapper.

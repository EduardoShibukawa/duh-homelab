---
type: task
mode: padrao
goal: "supersede, mode, examples, maestro e os sidecars usam taskRef; o legado continua em tasks/T<N>/"
title: taskRef nos demais comandos e sidecars
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T64
depends_on: [TASK-02-task-ref]
tier: medium
touch: [src/task_ref.ts, src/supersede.ts, src/mode.ts, src/examples.ts, src/maestro.ts, src/guards.ts, src/queue.ts, src/verify.ts, src/cli.ts, tests/task_ref_sidecar.test.ts]
done_when: "bun test tests/task_ref_sidecar.test.ts tests/guards.test.ts tests/queue.test.ts tests/maestro.test.ts tests/mode.test.ts"
tests_frozen: [tests/task_ref_sidecar.test.ts]
---
## Fazer
- `taskSidecarDir(ref)`: legado `tasks/T<N>/`; formato novo `<pasta do PLAN>/.pinga/TASK-NN/`.
- Usar em `guards.ts:47` (EXEC/EVAL), `queue.ts:344` (`baselinePath`) e no `baselineFile` do `verify.ts`.
- Trocar o `basename(dirname)` de `supersede.ts:61`, `mode.ts:219`, `examples.ts:314`, `maestro.ts:149`.
## Não fazer
- Não renomear nada já selado. `supersede T<N>` continua aceitando o id legado.
## Contexto
- `src/cli.ts:565` monta `tasks/${id}/PLAN.md` no `supersede`: aceitar também um caminho.

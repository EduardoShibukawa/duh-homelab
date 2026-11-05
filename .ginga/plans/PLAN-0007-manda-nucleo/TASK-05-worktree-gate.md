---
type: task
mode: padrao
goal: "Worktree por TASK, gate verify_cmd genérico e proteção de tests_frozen antes do gate"
title: Worktree, gate genérico e tests_frozen
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T5
depends_on: [TASK-02-leitor-bundle]
tier: medium
touch: [src/worktree.ts, src/gate.ts, tests/worktree_gate.test.ts]
done_when: "bun test tests/worktree_gate.test.ts"
tests_frozen: [tests/worktree_gate.test.ts]
---
## Fazer
- Portar `createWorktree`, `removeWorktree`, `mergeWorktreeToTrunk` de `pi-harness/.pi/extensions/worktree.ts`.
- `gate.ts`: roda `[commands].verify` com placeholders `{task}`, `{plan}`, `{repo}`, `{worktree}`; sem config, roda o `done_when`.
- Antes do gate: se o diff da worktree toca um `tests_frozen`, restaura da base e devolve `tests_frozen_changed` (tentativa falha).
## Não fazer
- Não chamar `pinga` diretamente no código (só via `verify_cmd`).
## Contexto
- `p-inga/src/guards.ts` (`tests_frozen_changed`) como referência de comportamento.

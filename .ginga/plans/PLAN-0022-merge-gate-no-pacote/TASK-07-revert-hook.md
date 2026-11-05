---
type: task
mode: padrao
goal: "Revert automático do merge usa MERGE_GATE=1 e retorna 16 (CRÍTICO) se falhar, compatível com hook reference-transaction"
title: fix revert merge-gate sem MERGE_GATE=1 (hook reference-transaction)
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T100
touch: [src/merge.ts, tests/merge_revert_hook.test.ts, tasks/T100/PLAN.md]
done_when: "bun test tests/merge_revert_hook.test.ts"
tests_frozen: [tests/merge_revert_hook.test.ts]
---

## Fazer
- Em src/merge.ts, passar env `{...process.env, MERGE_GATE: "1"}` no `git revert` (via Bun.spawnSync).
- Se o revert falhar, retornar exit 16 (CRÍTICO), não 14.
- Adicionar teste RED com fixture repo contendo hook reference-transaction.
## Não fazer
- Não alterar merge-gate.sh (fonte canônica, já correto).

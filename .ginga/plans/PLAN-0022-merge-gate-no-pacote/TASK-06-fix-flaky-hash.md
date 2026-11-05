---
type: task
mode: padrao
goal: "Tornar determinístico o caso 10 do merge_gate (HEAD sentinela não colide com hash real)"
title: fix flaky hash collision no caso 10 do gate
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T22
touch: [tests/merge_gate.test.ts, tasks/T22/PLAN.md]
done_when: "bun test tests/merge_gate.test.ts"
tests_frozen: [tests/merge_gate.test.ts]
---

## Fazer
- Substituir sentinela `"0" + wtHead().slice(1)` (colide quando HEAD começa em 0) por 40 'f' (hash impossível).
## Não fazer
- Não tocar em src/merge.ts.
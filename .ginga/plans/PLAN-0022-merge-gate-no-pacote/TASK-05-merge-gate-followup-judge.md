---
type: task
mode: padrao
goal: "manda merge: TASK do diff ausente da fila do pinga conta como pendente (exit 12); falha no git revert não é ignorada (exit != 0, com aviso)"
title: follow-up judge: ausência na fila e revert não ignorado
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T18
touch: [src/merge.ts, tests/merge_followup.test.ts, tasks/T18/PLAN.md]
done_when: "bun test tests/merge_followup.test.ts tests/merge_gate.test.ts"
tests_frozen: ["tests/merge_gate.test.ts"]
---
## Fazer
- No bloco 12, uma TASK de `tasks/T\d+/` no diff main...HEAD que não apareça na `pinga queue` (ou não esteja `done`) conta como pendente (exit 12).
- No bloco 14, o resultado de `git revert -m 1` é verificado; se falhar, emite aviso e retorna código != 0 (não ignora).
## Não fazer
- Não alterar tests/merge_gate.test.ts (frozen T17).

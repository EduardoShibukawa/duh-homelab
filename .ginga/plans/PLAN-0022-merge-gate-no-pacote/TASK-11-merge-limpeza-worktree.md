---
type: task
mode: padrao
goal: "manda merge com exit 0 remove a worktree da branch (WIP sem commit arquivado antes) e roda git branch -d"
title: manda merge limpa worktree e branch após o merge
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-09-merge-passe-vazio]
tier: free
pinga_task: T112
touch: [src/merge.ts, tests/merge_cleanup.test.ts, tasks/T112/PLAN.md]
done_when: "bun test tests/merge_cleanup.test.ts tests/merge_gate.test.ts tests/merge_followup.test.ts tests/merge_revert_hook.test.ts tests/merge_empty_pass.test.ts"
tests_frozen: [tests/merge_cleanup.test.ts]
---

## Fazer
- Em `src/merge.ts`, só no `finish(0, ...)` final (depois do ledger verify), chamar um helper `cleanupAfterMerge(repo, wt, branch, plan)`:
  1. Se `git status --porcelain` da worktree `wt` tiver WIP (mudança/untracked): `git add -A` na worktree e gravar `git diff --cached --binary HEAD` em `<plan>/wip/<branch com / trocado por ->-<timestamp>.patch` (cria o dir).
  2. `git worktree remove --force <wt>` (a partir do `repo`).
  3. `git branch -d <branch>` (nunca `-D`).
- Pular a limpeza (com aviso em stderr) se `process.cwd()` estiver dentro de `wt`. Falha de qualquer passo: aviso em stderr (`AVISO: limpeza pos-merge ...`), exit continua 0, mergeado continua true.
- Nos exits ≠ 0 nada é removido.
## Não fazer
- Não alterar testes existentes; não usar `branch -D`.

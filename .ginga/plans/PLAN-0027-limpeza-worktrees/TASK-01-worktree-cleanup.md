---
type: task
mode: padrao
goal: "o vigia arquiva o WIP e remove worktrees cuja branch já é ancestral da main e sem ready apontando para ela; as demais ficam"
title: vigia worktree_cleanup
plan: PLAN-0027-limpeza-worktrees
repo: ginga
depends_on: []
tier: free
pinga_task: T105
touch: [src/watch/worktrees.ts, src/watch/index.ts, src/watch/rules.ts, tests/watch_worktree_cleanup.test.ts, tasks/T105/PLAN.md]
done_when: "bun test tests/watch_worktree_cleanup.test.ts"
tests_frozen: [tests/watch_worktree_cleanup.test.ts]
---
## Fazer
- Novo `src/watch/worktrees.ts` exportando `sweepWorktrees(root: string, now = new Date()): Alert[]` (tipo `Alert` de `./evaluate.ts`). Repos = subpastas de `<root>` com `.git` DIRETÓRIO (checkouts principais; worktrees têm `.git` arquivo). Para cada repo, `git worktree list --porcelain`; ignore a worktree principal, as sem branch (detached), as `locked` e a que contém `process.cwd()`.
- Candidata = branch `refs/heads/X` onde `git merge-base --is-ancestor X main` é verdadeiro E a ponta de X ≠ ponta da main (salvaguarda: branch recém-criada não sai) E nenhum `<root>/.ginga/plans/*/ready/<repo>.json` (só em `ready/`, nunca `ready/done/`) tem `"branch": "X"`.
- Para cada candidata, nesta ordem: (1) arquivar em `<root>/.ginga/_archive/<YYYY-MM-DD>-worktrees/<basename-da-worktree>/`: `wip.patch` (`git diff HEAD --binary` na worktree, só se não vazio), `untracked/<caminho-relativo>` (cópia de `git ls-files --others --exclude-standard`) e `MANIFEST` (texto: repo, branch, sha, path original, data, lista de arquivos arquivados); (2) `git worktree remove --force <path>`; (3) `git branch -d X` (NUNCA `-D`; se falhar, o alerta vira `warn` dizendo que a branch ficou). Se o arquivamento falhar, NÃO remove nada.
- Alerta por worktree limpa: `{rule_id:"worktree_cleanup", severity:"info", entity:"<repo>/<basename>", summary, dedupe_key:"worktree_cleanup:<repo>/<basename>", actions:["archive_and_remove"]}`. Idempotente (2ª chamada: nada a fazer).
- `src/watch/rules.ts` `defaultRules()`: NÃO alterar (contagem congelada em testes). `src/watch/index.ts` `watchCmd`: depois do `sweepReady`, chamar `sweepWorktrees(base)` sob o mesmo `hasRule("worktree_cleanup")`, com try/catch e os alertas entrando no mesmo caminho de emissão/fila/`--json`.
## Não fazer
- Não alterar `evaluateWatch`, `defaultRules()` nem tests_frozen existentes. Nunca `git branch -D`, nunca `reset --hard`.

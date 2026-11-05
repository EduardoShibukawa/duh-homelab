# operador-ginga-r2 (2026-10-29)

- Achado do judge PLAN-0026 (gate exit 11, regression): `src/install/install.ts` revert removia qualquer symlink em `~/.local/bin/ginga`.
- TASK-02-revert-so-nosso-link (T106): RED `a`: commit "test(T106)", `pinga prove-red` pass (done_when exit 1 no base 1477222). Executor opencode/qwen3.8-flash, tentativa 1 pass. Commit fix(T106) em plan/0026.
- `pinga verify` T106: pass (seq 595). T104: pass (seq 597, re-verificado em abb5968; o verify em HEAD tinha dado blocked/scope_drift seq 596, superado pelo 597).
- `bun test` na worktree ginga-plan-0026: 285 pass / 0 fail.
- `pinga queue`: 40 done, 0 blocked/open.
- `ready/ginga.json` regravado (branch plan/0026).
- Backlog: todos os itens já estavam `[x]`; nada pendente (PLAN-0027 tem ready/done/ginga-0030.json).

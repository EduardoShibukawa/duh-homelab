---
type: task
mode: padrao
goal: "ginga install --revert só remove ~/.local/bin/ginga se o symlink aponta para o entrypoint do repo (preserva link do usuário)"
title: revert remove só o link criado pelo ginga
plan: PLAN-0026-install-bin-link
repo: ginga
depends_on: [TASK-01-install-bin-link]
tier: free
pinga_task: T106
touch: [src/install/binlink.ts, src/install/install.ts, tests/install/install_bin_link_revert.test.ts, tasks/T106/PLAN.md]
done_when: "bun test tests/install/install_bin_link_revert.test.ts tests/install/install_bin_link.test.ts"
tests_frozen: [tests/install/install_bin_link_revert.test.ts]
---
## Fazer
- Em `src/install/binlink.ts` exportar `removeBinLink(home: string): boolean`: remove `<home>/.local/bin/ginga` SOMENTE se for symlink cujo `readlinkSync` é igual ao alvo (`join(import.meta.dir,"..","..","bin","ginga.ts")`, o mesmo de `ensureBinLink`). Retorna true se removeu.
- Em `src/install/install.ts` (bloco `opts.mode === "revert"`, ~l.700-705) trocar o `isSymlinkAt` + `rmSync` por `removeBinLink(opts.home)`. Remover `isSymlinkAt` se ficar sem uso.
## Não fazer
- Não alterar tests_frozen existentes (install_bin_link.test.ts).

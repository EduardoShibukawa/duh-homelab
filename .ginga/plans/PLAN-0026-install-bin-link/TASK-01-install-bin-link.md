---
type: task
mode: padrao
goal: "ginga install --apply cria o link <HOME>/.local/bin/ginga para bin/ginga.ts (idempotente, avisa PATH) e ginga --version roda por ele"
title: ginga install cria link ~/.local/bin/ginga
plan: PLAN-0026-install-bin-link
repo: ginga
depends_on: []
tier: free
pinga_task: T104
touch: [src/install/binlink.ts, src/install/install.ts, src/cli.ts, tests/install/install_bin_link.test.ts, tasks/T104/PLAN.md]
done_when: "bun test tests/install/install_bin_link.test.ts"
tests_frozen: [tests/install/install_bin_link.test.ts]
---
## Fazer
- Novo `src/install/binlink.ts` exportando `ensureBinLink(home: string, envPath: string | undefined): { path: string; created: boolean; onPath: boolean }`. Alvo: `join(home,".local/bin/ginga")` → symlink para `join(import.meta.dir,"..","..","bin","ginga.ts")` (absoluto). `mkdirSync` recursivo do diretório. Idempotente: se já é symlink para o mesmo alvo, não mexe (`created:false`); se é symlink para outro alvo, recria; se é arquivo regular, NÃO sobrescreve (stderr avisa, `created:false`). `onPath`: `<home>/.local/bin` está em `envPath.split(":")`.
- Em `src/install/install.ts`, nos DOIS pontos onde `opts.mode === "apply"` instala a unidade systemd do supervisor (no-op e pós-validação), chamar `ensureBinLink(opts.home, opts.env?.PATH)` dentro do mesmo try; se `!onPath`, `console.error("aviso: ~/.local/bin não está no PATH")`.
- Em `src/cli.ts` `run`: `args[0]==="--version"` imprime `ginga 0.1.0` (usar `VERSION.version`) e retorna 0.
## Não fazer
- Não escrever no HOME real nos testes; não alterar tests_frozen existentes.

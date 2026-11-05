---
type: task
mode: padrao
goal: "manda install cria o link ~/.local/bin/manda (idempotente) e avisa se ~/.local/bin não está no PATH; manda --help roda"
title: manda install (link em ~/.local/bin)
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T111
touch: [src/install.ts, src/cli.ts, bin/manda.ts, tests/install.test.ts, tasks/T111/PLAN.md]
done_when: "bun test tests/install.test.ts"
tests_frozen: [tests/install.test.ts]
---

## Fazer
- Criar `src/install.ts` exportando `installLink(home = process.env.HOME)` → `{ link, target, created, onPath }`: cria `<home>/.local/bin/` se faltar, faz `chmod 755` em `<pacote>/bin/manda.ts` e um symlink `<home>/.local/bin/manda` → esse arquivo. Idempotente: link já correto → mantém; link ou arquivo errado → substitui.
- `src/cli.ts`: `run(["install"])` chama `installLink`, imprime 1 linha JSON no stdout e, se `<home>/.local/bin` não estiver em `process.env.PATH`, escreve um aviso com a palavra "PATH" em stderr. Exit 0.
- `run(["--help"])` e `run(["-h"])` tratam como `help` (exit 0, texto "Usage: manda"). Acrescente `install` à lista de comandos do texto de uso.
## Não fazer
- `install` não entra em `GUARDED_COMMANDS`. Não alterar `tests/install.test.ts`.

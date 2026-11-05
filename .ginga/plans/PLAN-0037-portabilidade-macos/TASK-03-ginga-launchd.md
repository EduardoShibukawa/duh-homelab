---
type: task
mode: padrao
goal: "ginga ganha contrib/launchd (equivalente macOS do contrib/systemd) e o teste e2e acha o manda sem caminho do autor"
title: ginga launchd e e2e sem path do autor
plan: PLAN-0037-portabilidade-macos
repo: ginga
depends_on: []
tier: free
touch: [contrib/launchd/dev.ginga.serve.plist, contrib/launchd/dev.ginga.tick.plist, contrib/launchd/README.md, tests/e2e/autonomo.test.ts, tests/launchd_contrib.test.ts, tests/e2e/manda_path.test.ts]
done_when: "bun test tests/launchd_contrib.test.ts tests/e2e/manda_path.test.ts"
tests_frozen: [tests/launchd_contrib.test.ts, tests/e2e/manda_path.test.ts]
---
## Fazer
- `contrib/launchd/dev.ginga.serve.plist`: LaunchAgent com `Label` `dev.ginga.serve`, `ProgramArguments` `["/usr/bin/env","ginga","serve"]`, `RunAtLoad` e `KeepAlive` true. `dev.ginga.tick.plist`: `Label` `dev.ginga.tick`, `["/usr/bin/env","ginga","tick"]`, `StartInterval` 600. Espelhe os comandos reais de `contrib/systemd/ginga-serve.service` e `ginga-tick.service` (leia-os e copie os argumentos).
- `contrib/launchd/README.md`: 6 a 10 linhas: copiar para `~/Library/LaunchAgents/`, `launchctl bootstrap gui/$(id -u) <arquivo>`, `launchctl bootout`; sem caminho absoluto do autor.
- `tests/e2e/autonomo.test.ts` (linhas 36 a 40): o fallback para o manda deixa de ser `/home/shibuka/Projetos/duh-homelab/manda`. Ordem de resolução: `process.env.MANDA_BIN`, depois `<ROOT>/../manda` se existir `bin/manda.ts`, senão lançar `Error("manda não encontrado; defina MANDA_BIN")`. Mantenha tudo dentro desse arquivo (ele não exporta nada novo).
## Interface
- `tests/launchd_contrib.test.ts`: cada plist existe, começa com `<?xml`, contém `<key>Label</key>` com os nomes acima, `ProgramArguments` e (tick) `StartInterval`; nenhum contém `/home/`; o README não contém `/home/`.
- `tests/e2e/manda_path.test.ts`: lê `tests/e2e/autonomo.test.ts` como texto e exige que não contenha `/home/shibuka`, que contenha `MANDA_BIN`, `bin/manda.ts` e a mensagem `defina MANDA_BIN`, e que `MANDA_BIN` apareça antes de `bin/manda.ts` no arquivo.
## Não fazer
- Não alterar `contrib/systemd/` nem o comportamento do e2e quando o manda existe.
## Contexto
- `ginga/contrib/systemd/*.service|*.timer`, `ginga/tests/e2e/autonomo.test.ts`.

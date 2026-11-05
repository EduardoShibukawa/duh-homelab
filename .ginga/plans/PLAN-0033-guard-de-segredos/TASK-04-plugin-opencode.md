---
type: task
mode: padrao
goal: "o plugin opencode lança erro em tool.execute.before para cat .env e cat ~/.pi/agent/auth.json (tool shell), deixa cat README.md passar e redige output em tool.execute.after; fora de lane retorna {}"
title: Plugin opencode do guard
plan: PLAN-0033-guard-de-segredos
repo: ginga
pinga_task: T303
depends_on: [TASK-02-run-e-cli]
tier: free
touch: [contrib/guard/opencode.ts, contrib/guard/opencode-config/plugins/ginga-guard.ts, tests/guard_opencode.test.ts]
done_when: "bun test tests/guard_opencode.test.ts"
tests_frozen: [tests/guard_opencode.test.ts]
---
## Fazer
- `export const GingaGuard = async (_ctx, env = process.env)` devolvendo `{ "tool.execute.before", "tool.execute.after" }` (ou `{}` se `mode(env) === "off"`). `before` recebe `(input:{tool}, output:{args})` e **lança** `Error("guard-segredos: … [regra]")`; `after` reescreve `output.output` (string) com `guardResult`.
- `opencode-config/plugins/ginga-guard.ts` só reexporta o plugin, para `OPENCODE_CONFIG_DIR=<repo>/contrib/guard/opencode-config` carregar sem tocar `~/.config/opencode`.
## Interface
- Protótipo: [ref/ginga/contrib/guard/opencode.ts](../ref/ginga/contrib/guard/opencode.ts). O nome da tool não importa (o core olha as chaves do `input`); nos `runs/` reais ela aparece como `shell`, `read`, `edit`, `grep`, `glob`.
## Não fazer
- Não tocar tests_frozen. Não editar `~/.config/opencode`. Não assumir o serviço compartilhado: o guard só vale em `opencode run --standalone` (plugin no processo da sessão); o `lane.sh`, o `dispatch-task.sh` e o runtime do manda já usam `--standalone`.
## Contexto
- Que `OPENCODE_CONFIG_DIR` seja lido em opencode 2.2.2 **não foi verificado** (o binário instalado é um wrapper). A Fase 2 do PLAN confirma; a escolha fica isolada em `guard_opencode_env()` da TASK-06.

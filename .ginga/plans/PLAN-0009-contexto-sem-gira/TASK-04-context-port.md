---
type: task
mode: padrao
goal: "manda context <cap> <arg> --json resolve o provider do project.toml e normaliza a saída do gira num schema único"
title: manda context + adapter gira
plan: PLAN-0009-contexto-sem-gira
repo: manda
pinga_task: T150
depends_on: []
tier: medium
touch: [src/context/port.ts, src/context/gira.ts, src/cli.ts, tests/context_port.test.ts, tests/fixtures/context/]
done_when: "bun test tests/context_port.test.ts"
tests_frozen: [tests/context_port.test.ts, tests/fixtures/context/]
---
## Fazer
- Provider: `[context].provider` (`gira|rg|<comando>`); `gira` sem binário → cai para `rg` com aviso no stderr.
- Schema: `{schema_version, provider, capability, items:[{path, line, symbol, kind, text}]}`.
- Capacidade ausente → `{items:[], unsupported:true}` (degrada, não quebra). Extras com namespace (`gira:tour`).
## Não fazer
- Não implementar o rg aqui (TASK-05).
## Contexto
- `pi-harness/.pi/extensions/gira.ts` (`fetchGiraSlice`, `fetchGiraImpact`) como referência de chamada.

---
type: task
mode: mvp
goal: "Criar o repo manda/ (Bun/TS) com a CLI manda (alias mandacaru) e manda version --json"
title: Repo manda/ + CLI
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T1
depends_on: []
tier: free
touch: [package.json, tsconfig.json, mise.toml, bin/manda.ts, src/cli.ts, README.md, tests/cli.test.ts]
done_when: "bun test tests/cli.test.ts"
tests_frozen: [tests/cli.test.ts]
---
## Fazer
- `git init` em `duh-homelab/manda/` (repo a criar); `bin` com `manda` e `mandacaru`.
- `manda version --json` → `{"schema_version":1,"name":"manda",...}`; comando desconhecido → exit 2.
- README com "Name origin" (Manda-CARU, DECISION-0001).
## Não fazer
- Nenhuma dependência de `@earendil-works/*`, `p-inga/` ou `ginga/`.
## Contexto
- `.ginga/knowledge/decisions/DECISION-0001-nomes.md`.

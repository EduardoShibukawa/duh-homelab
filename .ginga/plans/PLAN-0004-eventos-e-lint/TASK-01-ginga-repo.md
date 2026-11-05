---
type: task
mode: mvp
goal: "Criar o repo ginga/ (Bun/TS) com a CLI ginga e ginga version --json"
title: Repo ginga/ + CLI mínima
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T1
depends_on: []
tier: free
touch: [package.json, tsconfig.json, mise.toml, bin/ginga.ts, src/cli.ts, README.md, tests/cli.test.ts]
done_when: "bun test tests/cli.test.ts"
tests_frozen: [tests/cli.test.ts]
---
## Fazer
- `git init` em `duh-homelab/ginga/` (repo a criar), `package.json` com `bin.ginga`.
- `ginga version --json` → `{"schema_version":1,"name":"ginga","version":"0.1.0"}`; comando desconhecido → exit 2.
- README com seção "Name origin" (DECISION-0001).
## Não fazer
- Nenhum import de `p-inga/` ou `pi-harness/`.
## Contexto
- Estrutura de referência: `p-inga/package.json`, `p-inga/bin/pinga.ts`, `p-inga/src/cli.ts`.

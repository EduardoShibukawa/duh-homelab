---
type: task
mode: mvp
goal: "Cada verbo do registro é chamável como ginga <verbo> com --json, sem código por verbo na CLI"
title: CLI gerada do registro
plan: PLAN-0011-verbos-api-auth
pinga_task: T121
repo: ginga
depends_on: [TASK-01-registro-verbos]
tier: free
touch: [src/cli.ts, tests/cli_verbs.test.ts]
done_when: "bun test tests/cli_verbs.test.ts"
tests_frozen: [tests/cli_verbs.test.ts]
---
## Fazer
- Dispatch genérico: `ginga <verbo> [sub] args... [--json] [--via cli]`; `--help` lista o registro.
- Teste: para todo nome do registro, a CLI aceita e devolve o mesmo JSON que `run` direto.
## Não fazer
- Não duplicar validação de argumentos (vem do registro).
## Contexto
- `src/verbs/registry.ts` (TASK-01).

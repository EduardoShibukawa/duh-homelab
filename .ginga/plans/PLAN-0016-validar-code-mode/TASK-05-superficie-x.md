---
type: task
mode: mvp
goal: "A superfície X expõe search_tools e execute(script), com o script rodando dentro do bwrap (mínimo ou FS inteiro) e a saída truncada"
title: Superfície X (search_tools + execute no bwrap)
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-01-tasks-oracle]
tier: free
touch: [bench/code-mode/surfaces/x.ts, bench/code-mode/surfaces/x1.md, tests/code_mode/surface_x.test.ts]
done_when: "bun test tests/code_mode/surface_x.test.ts"
tests_frozen: [tests/code_mode/surface_x.test.ts]
pinga_task: T340
---
## Fazer
- `search_tools(query)`: devolve as assinaturas da API de leitura disponível ao script (os mesmos 12 nomes da TASK-03, como funções).
- `execute(script)`: grava o script e roda `bwrapArgv(...)`; `minimal: true` monta só `/usr` + o snapshot read-only + um tmp; `false` monta o FS inteiro read-only. Sem rede (`--unshare-net`). Saída por `truncate`.
- `x1.md`: as instruções da 1ª versão (o X2 é escrito pelo Planner na rodada H2).
## Interface
- `bwrapArgv`, `truncate` (PLAN.md); `execute(script: string, o: { snapshot: string; minimal: boolean; run: (argv: string[]) => Promise<string> }): Promise<string>`. Teste: argv exato nos dois modos (contém `--unshare-net` e `--ro-bind <snapshot>`); `truncate` de 10000 chars → 8000 + marcador; `run` injetado (sem bwrap real).
## Não fazer
- Não executar bwrap no teste.
## Contexto
- Doc 10 (sandbox); `.ginga/bin` do sandbox do `done_when` (PLAN-0018) como referência de argv.

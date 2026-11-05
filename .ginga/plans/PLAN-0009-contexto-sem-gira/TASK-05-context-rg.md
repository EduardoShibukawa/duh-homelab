---
type: task
mode: padrao
goal: "O provider rg + git atende outline, slice e impact com o mesmo schema e os mesmos caminhos do gira no fixture"
title: Fallback rg + git
plan: PLAN-0009-contexto-sem-gira
repo: manda
pinga_task: T151
depends_on: [TASK-04-context-port]
tier: medium
touch: [src/context/rg.ts, src/context/port.ts, tests/context_rg.test.ts, tests/fixtures/context/]
done_when: "bun test tests/context_rg.test.ts tests/context_port.test.ts"
tests_frozen: [tests/context_rg.test.ts]
---
## Fazer
- `outline <path>`: regex de definição por linguagem (ts, go, java, py) via `rg -n`.
- `slice <símbolo>`: definição + N linhas; `impact <path|símbolo>`: `git grep -l` + co-change de `git log --name-only`.
- Teste: no fixture, `slice` via rg e via gira (saída gravada) têm o mesmo schema e o mesmo conjunto de `path`.
## Não fazer
- Sem dependência além de `rg` e `git`.
## Contexto
- Doc 02 §2; `pinga` e manda são os consumidores reais.

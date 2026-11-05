---
type: task
mode: padrao
goal: "Um PLAN aprovado de fixture vai de approved a done só com código: RED, executor falso, verify, judge falso e merge"
title: e2e sem humano nem LLM
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: ginga
pinga_task: T320
depends_on: [TASK-07-supervisor-sem-operador]
tier: medium
touch: [tests/e2e/autonomo.test.ts, tests/fixtures/autonomo/]
done_when: "bun test tests/e2e/autonomo.test.ts"
tests_frozen: [tests/e2e/autonomo.test.ts, tests/fixtures/autonomo/]
---
## Fazer
- Fixture: bundle com PLAN `approved` de 1 TASK e o teste em `frozen/`; repo git temporário; `[commands]` apontando para `manda` real com runtime `stub` (escreve a solução) e judge `stub` (pass).
- Rodar `ginga tick` até `done` (máx. 10 ticks): fases na ordem, receipt `pass`, commit na `main` via gate; caso 2: executor que sempre falha → `replan` depois de 3 falhas.
## Interface
- Nenhuma nova: usa TASK-01 a TASK-07.
## Não fazer
- Sem rede, sem modelo real.
## Contexto
- `tests/e2e/` existente.

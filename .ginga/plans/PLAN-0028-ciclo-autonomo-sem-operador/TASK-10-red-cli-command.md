---
type: task
mode: padrao
goal: "manda red fica disponivel na CLI e herda o ambiente do processo para o pinga falso"
title: Correcao do comando manda red na CLI
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-03-manda-red]
tier: medium
touch: [src/cli.ts, tests/red_cli.test.ts, tasks/T160/PLAN.md]
done_when: "bun test tests/red_cli.test.ts"
tests_frozen: [tests/red_cli.test.ts]
pinga_task: T160
---
## Fazer
- Ligar `manda red` na CLI com o runner existente.
- Passar `env: process.env` ao Bun.spawnSync do pinga e do git.

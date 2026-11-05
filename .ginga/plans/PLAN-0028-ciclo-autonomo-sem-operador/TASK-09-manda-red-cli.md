---
type: task
mode: padrao
goal: "manda red <PLAN> executa a materialização RED pela CLI e valida cada arquivo de tests_frozen"
title: manda red integrado à CLI
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-03-manda-red]
tier: medium
touch: [src/red.ts, src/cli.ts, tests/red_cli.test.ts]
done_when: "bun test tests/red_cli.test.ts"
tests_frozen: [tests/red_cli.test.ts]
pinga_task: T159
---
## Fazer
- `manda red <PLAN> --repo <repo> [--root <dir>]` chama `redPlan`; a fila usa `pinga queue --json` e o resultado JSON lista as TASKs.
- Antes de materializar, valida individualmente cada `tests_frozen`; arquivo ausente falha citando o caminho.
- Mantém o clone/cópia e o commit `test(T<N>): RED` de `redPlan`.
## Não fazer
- Não alterar `tests/red.test.ts` nem as fixtures congeladas de T156.

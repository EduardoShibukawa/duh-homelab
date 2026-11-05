---
type: task
mode: padrao
goal: "manda red <PLAN> copia os tests_frozen escritos pelo Planner para a worktree, materializa tasks/T<N>/PLAN.md, prova o RED e commita, sem LLM"
title: manda red
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-02-alocar-pinga-task]
tier: medium
touch: [src/red.ts, src/cli.ts, tests/red.test.ts, tests/fixtures/red/]
done_when: "bun test tests/red.test.ts"
tests_frozen: [tests/red.test.ts, tests/fixtures/red/TASK-01-a.md, tests/fixtures/red/TASK-02-b.md, tests/fixtures/red/frozen.test.ts, tests/fixtures/red/case.txt]
pinga_task: T156
---
## Fazer
- Para cada TASK do `repo` sem `pinga_task`: aloca id (TASK-02), copia `plans/PLAN-NNNN/frozen/<repo>/<tests_frozen>` para a worktree `<repo>-plan-NNNN` (cria a partir da `main` se faltar), gera `tasks/T<N>/PLAN.md` (`mode`, `goal`, `done_when`, `touch`, `tests_frozen`), roda `pinga prove-red`, grava `pinga_task: T<N>` na TASK e commita `test(T<N>): RED`.
- Teste já passando na base → `red: false` e a TASK fica `blocked` com motivo `test_passed_on_base`. Teste ausente em `frozen/` → erro com o caminho.
## Interface
- `redPlan(o)` (PLAN.md); `type Runner = (argv: string[], cwd: string) => { code: number; stdout: string }`. Teste: fixture de bundle + repo git temporário, `pinga` falso → 2 TASKs com ids novos, 1 commit por TASK.
## Não fazer
- Não escrever teste (quem escreve é o Planner).
## Contexto
- `prompts/planner-red.md` (o passo manual que este código substitui).

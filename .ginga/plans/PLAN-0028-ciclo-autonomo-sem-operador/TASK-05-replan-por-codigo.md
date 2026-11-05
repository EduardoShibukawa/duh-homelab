---
type: task
mode: padrao
goal: "manda replan monta o contexto da falha de forma determinística e chama o Planner configurado; o PLAN reescrito só entra se passar no ginga lint"
title: Replan disparado por código
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-03-manda-red]
tier: medium
touch: [src/replan.ts, src/cli.ts, tests/replan.test.ts, tests/fixtures/replan/]
done_when: "bun test tests/replan.test.ts"
tests_frozen: [tests/replan.test.ts, tests/fixtures/replan/]
pinga_task: T157
---
## Fazer
- `buildReplanContext`: TASK.md, os 3 últimos receipts (`reason_code`), achados do judge, `git diff main...plan/NNNN --stat` + diff truncado em 20000 chars, LEARNINGS do PLAN. Mesma entrada → mesmos bytes.
- `manda replan <PLAN> <TASK>`: chama o Planner de `[roles] planner` (padrão `claude -p --model claude-opus-5-5`, fallback `opencode run -m opencode-go/deepseek-v4-pro`, stdin fechado) com `prompts/replan.md` + contexto; aceita só se `ginga lint` passar no PLAN; senão `blocked`.
## Interface
- `buildReplanContext(o)` (PLAN.md); `replan(o: { ...; planner: Runner; lint: Runner }): { result: "replanned" | "blocked"; reason: string }`. Teste: fixture → contexto igual ao arquivo esperado; planner falso que quebra o lint → `blocked`.
## Não fazer
- Não decidir quando replanejar (quem decide é o tick).
## Contexto
- `.ginga/prompts/replan.md`; decisões do dono ("Replan = o mesmo Planner com mais contexto").

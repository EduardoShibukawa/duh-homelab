---
type: task
mode: padrao
goal: "ginga tick decide por função pura a próxima ação de cada PLAN aprovado e chama o comando configurado em [commands]"
title: O tick avança as fases
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: ginga
depends_on: [TASK-01-fase-do-plan]
tier: medium
touch: [src/tick_plan.ts, src/tick.ts, tests/tick_plan.test.ts]
done_when: "bun test tests/tick_plan.test.ts"
tests_frozen: [tests/tick_plan.test.ts]
pinga_task: T135
---
## Fazer
- `nextAction`: `approved` → `red`; `red`/`tasks` com TASK aberta e deps feitas → `run` (uma por repo por tick); todas `pass` → `judge`; judge `pass` → `merge`; judge `high` ou TASK com 3 falhas → `replan`; `!cap_ok` → `notify` (Inbox, budget). Sem nada a fazer → `none`.
- `tick` aplica a ação via `[commands] red|run|judge|merge|replan` (padrões `manda red {plan}`, `manda run {plan} {task}`, `manda judge {plan}`, `bin/merge-gate.sh {plan}`, `manda replan {plan} {task}`) e chama `setPhase`.
## Interface
- `Action`, `nextAction` (PLAN.md). Teste: tabela com 8 estados → 8 ações exatas; `tick` com comandos falsos registra os argv.
## Não fazer
- Nenhuma chamada de LLM dentro do ginga.
## Contexto
- `src/tick.ts` (PLAN-0010), doc 04 §3 (regra do dispatcher).

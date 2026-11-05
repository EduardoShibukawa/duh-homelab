---
type: task
mode: mvp
goal: "O state.db guarda a fase de cada PLAN aprovado e toda mudança de fase emite um evento transition"
title: Fase do PLAN no state.db
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: ginga
depends_on: []
tier: free
touch: [src/plan_phase.ts, tests/plan_phase.test.ts]
done_when: "bun test tests/plan_phase.test.ts"
tests_frozen: [tests/plan_phase.test.ts]
pinga_task: T134
---
## Fazer
- Tabela `plan_phase(plan PRIMARY KEY, phase, since, replans)`, criada sob demanda (`CREATE TABLE IF NOT EXISTS`).
- `setPhase` grava e emite `transition` (`from`, `to`, `reason`); `replan` incrementa `replans`.
## Interface
- `Phase`, `getPhase`, `setPhase` (PLAN.md). Teste: db em memória; approved → red → tasks gera 2 eventos; 2 `replan` → `replans: 2`.
## Não fazer
- Não mexer em `task_exec` nem no frontmatter.
## Contexto
- `src/state/db.ts`; doc 04 §5 ("o arquivo guarda o contrato, o db guarda a execução").

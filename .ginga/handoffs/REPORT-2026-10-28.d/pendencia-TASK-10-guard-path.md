---
type: task
mode: mvp
goal: "O guard de payload do hook sem config segue o provider por PATH: sem gira no PATH a dica não cita o gira (A6)"
title: guardReasonFor usa contextProvider (config → PATH → rg)
plan: PLAN-0009-contexto-sem-gira
repo: p-inga
pinga_task: T81
depends_on: [TASK-06-pinga-a6]
tier: free
touch: [src/hooks.ts, tests/hooks_guard_path.test.ts, tasks/T81/PLAN.md]
done_when: "bun test tests/hooks_guard_path.test.ts tests/hooks_provider.test.ts tests/hooks.test.ts"
tests_frozen: [tests/hooks_guard_path.test.ts]
---
## Fazer
- `guardReasonFor` em `src/hooks.ts`: trocar `configuredProvider(base)` por `contextProvider(base)`; provider ≠ gira → variante rg.
## Não fazer
- Não mudar mensagens exportadas nem `contextProvider`; não tocar `tests/hooks_provider.test.ts` (congelado, T77).
## Contexto
- Achado do judge do PLAN-0009 (AC-A6 / TASK-06).

---
type: task
mode: mvp
goal: "Cada evento de um PLAN vira uma linha no log.md da pasta dele, criado se não existir"
title: log.md automático
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T140
depends_on: []
tier: free
touch: [src/plan_log.ts, src/notify/router.ts, tests/plan_log.test.ts]
done_when: "bun test tests/plan_log.test.ts"
tests_frozen: [tests/plan_log.test.ts]
---
## Fazer
- `attempt` → `AAAA-MM-DD TASK-xx <runtime/modelo> tentativa N pass|fail[: motivo]` (o formato que as lanes já escrevem); `transition`, `receipt`, `answer`, `handoff`, `learning` → `AAAA-MM-DD <kind> <resumo>`.
- Idempotente por `id` de evento (não duplica ao reprocessar).
## Interface
- `formatLogLine(ev)` e `appendPlanLog(root, ev)` (PLAN.md, "Interfaces"). Teste: `attempt` com `model: "opencode/qwen3.8-flash"`, `n: 1`, `passed: true` → `2026-10-29 TASK-05 opencode/qwen3.8-flash tentativa 1 pass`; mesmo evento 2× → 1 linha.
## Não fazer
- Não reescrever linhas existentes (só append).
## Contexto
- Doc 06 §2; `src/notify/router.ts` (PLAN-0010).

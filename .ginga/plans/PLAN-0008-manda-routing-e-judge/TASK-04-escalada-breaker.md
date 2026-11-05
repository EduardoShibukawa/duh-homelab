---
type: task
mode: padrao
goal: "Escada free×2 → medium×2 automática (strong só com tier: strong explícito) e breaker de 3 falhas iguais (sem quota/infra) levando a blocked"
title: Escada de tiers + breaker
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: [TASK-03-routing-manda]
tier: medium
pinga_task: T11
touch: [src/escalation.ts, src/run.ts, tests/escalation.test.ts]
done_when: "bun test tests/escalation.test.ts"
tests_frozen: [tests/escalation.test.ts]
---
## Fazer
- Duas falhas num tier sobem um tier sem pedir OK; candidato já tentado é pulado.
- 3 falhas seguidas com o mesmo `reason_code` → para; `quota_exhausted` e `infra` não contam.
- Esgotou → `transition` para `blocked` + evento `blocker` (`raised_by: manda`).
## Não fazer
- Sem teto de budget (TASK-04).
## Contexto
- `router.ts` (`DEFAULT_LADDER` l. 865, `escalateWithFloor` l. 878, `filterAttemptedCandidates` l. 904); `p-inga/src/breaker.ts`.

## Replan (2026-10-28)
- Motivo: TASK-04 foi escrita antes da ROUTING de 2026-10-28, que proíbe escalada automática para strong (só com `tier: strong` explícito) e remove o nemotron. O teste RED congelado foi reescrito para refletir free×2 → medium×2 → blocked, sem strong automático. Planner (operador).

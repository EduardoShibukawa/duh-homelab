---
type: plan
title: Follow-up: teste comportamental do holdout com exit 97 (p-inga)
intent: INTENT-0006-sandbox-e-code-mode
kind: fix
status: approved
repos: [p-inga]
depends_on: [PLAN-0018-sandbox-done-when]
---
## Objetivo
Fix do achado novo do judge de PLAN-0018: o holdout do verify com exit 97 (wrapper indisponível) é checado só por inspeção textual; falta teste comportamental que execute o fluxo e verifique receipt blocked/infra.

## Context
- Achado: judge codex4, TASK-07.
- Implementação já existe em src/verify.ts:427-438; falta cobertura comportamental.
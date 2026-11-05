---
type: plan
title: Follow-up: validar cost_usd em eventos v1 (ginga)
intent: INTENT-0001-ginga-revamp
kind: fix
status: approved
repos: [ginga]
depends_on: [PLAN-0004-eventos-e-lint]
---
## Objetivo
Fix do achado novo do judge de PLAN-0004: `src/events/validate.ts` omite `cost_usd` dos campos numéricos; validador aceita tipo inválido. Adicionar ao conjunto de campos numéricos e teste.

## Context
- Achado: judge codex7, evidência "src/events/validate.ts:19 omite cost_usd".
- docs/events-v1.md:22 define cost_usd em attempt.
- Fix pequeno, sem regressão.

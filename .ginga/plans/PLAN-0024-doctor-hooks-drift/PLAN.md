---
type: plan
title: Follow-up: ginga doctor acusa drift dos hooks (PLAN-0022 TASK-04)
intent: INTENT-0009-skills-e-hooks
kind: fix
status: approved
repos: [ginga]
depends_on: [PLAN-0022-merge-gate-no-pacote]
---
## Objetivo
Fix do achado do judge (REPORT 21:15, gate 0 do ginga plan/0022): `ginga doctor` só faz probes de harness e não verifica nem acusa drift dos hooks instalados pelo `ginga hooks install`.

## Context
- TASK-04 em `.ginga/plans/PLAN-0022-merge-gate-no-pacote/TASK-04-ginga-hooks-install.md`; o plano T25 marcava "ginga doctor" fora do escopo.
- Worktree `ginga-plan-0024` (branch `plan/0024`) a partir da main (que já contém 19dc411).

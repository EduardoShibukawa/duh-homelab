---
type: plan
title: ginga install cria o link ~/.local/bin/ginga
intent: INTENT-0009-skills-e-hooks
kind: feature
status: approved
repos: [ginga]
depends_on: [PLAN-0023-vigia-e-supervisor]
---
## Objetivo
`ginga install --apply` cria (idempotente) o link `<HOME>/.local/bin/ginga` apontando para `bin/ginga.ts` do repo, e avisa se `<HOME>/.local/bin` não está no PATH. `ginga --version` passa a funcionar.

## Context
- Backlog do ginga (lane r1). Worktree `ginga-plan-0026` (branch `plan/0026`) a partir da main (5a0a231). Id T104 (ledger global).

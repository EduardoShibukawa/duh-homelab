---
type: plan
title: Hook reference-transaction recusa ancestral LLM; vigia stale_ready/ready_writer
intent: INTENT-0009-skills-e-hooks
kind: fix
status: approved
repos: [ginga]
depends_on: [PLAN-0022-merge-gate-no-pacote, PLAN-0023-vigia-e-supervisor]
---
## Objetivo
1. (PRIORIDADE, incidente 22:48) `reference-transaction` recusa update de `refs/heads/main` quando um ancestral do processo é agente LLM, mesmo com `MERGE_GATE=1` (mesma lógica de argv do `merge-gate.sh`). `ginga hooks install` passa a atualizar um hook ginga-managed no lugar (sem encadeá-lo a si mesmo).
2. (follow-up 10 do PLAN-0023) vigia: regra `stale_ready` e `ready_writer` (`{"branch","by","at"}`).

## Context
- Worktree `ginga-plan-0025` (branch `plan/0025`) a partir da main (5a0a231). Ids T101/T102 (ledger global ocupa T1..T76 e T100).
- A fonte real é `.ginga/hooks/git/reference-transaction` (raiz, fora do git): a TASK-01 entrega o hook em `tests/fixtures/hooks_llm/git/`; o operador o promove à fonte e roda `ginga hooks install`.

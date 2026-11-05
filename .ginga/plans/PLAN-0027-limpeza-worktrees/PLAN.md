---
type: plan
title: Vigia limpa worktrees já mergeadas (arquiva o WIP antes)
intent: INTENT-0009-skills-e-hooks
kind: feature
status: approved
repos: [ginga]
depends_on: [PLAN-0025-hooks-llm-e-stale-ready]
---
## Objetivo
Regra `worktree_cleanup` no `ginga watch` (e, por consequência, no `ginga serve`, que executa o watch a cada tick): worktree cuja branch já é ancestral da `main` e sem `ready/*.json` apontando para ela é arquivada (patch + untracked + MANIFEST em `.ginga/_archive/<data>-worktrees/<nome>/`), removida (`git worktree remove`) e a branch apagada com `git branch -d` (nunca `-D`).

## Context
- Worktree `ginga-plan-0027` (branch `plan/0027`) a partir de `plan/0025` (usa `src/watch/ready.ts` e o wiring de `src/watch/index.ts` do 0025). Id T105.
- Salvaguarda (decisão do operador): branch com a ponta igual à da `main` (worktree recém-criada, sem commits) NÃO é limpa.

---
type: plan
title: Bytecode Python fora do git (ginga)
intent: housekeeping (pendência do relatório problemas-harness-sessao-guard-2026-10-30)
kind: chore
status: approved
repos: [ginga]
depends_on: []
done_when: "cd ginga && bun test tests/no_tracked_bytecode.test.ts"
---
## Objetivo

`contrib/hermes-plugin/__pycache__/__init__.cpython-314.pyc` estava rastreado, apesar do `.gitignore`. Cada teste do plugin Hermes o regravava, a `main` ficava suja e o `merge-gate` saía com 2. Tirar do índice (`git rm --cached`).

## TASKs

1. T368 (`ginga/tasks/T368/PLAN.md`, branch `plan/0035`): teste congelado `tests/no_tracked_bytecode.test.ts` + `git rm --cached`.

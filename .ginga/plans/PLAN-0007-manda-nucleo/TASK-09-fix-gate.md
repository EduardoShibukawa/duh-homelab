---
type: task
mode: mvp
goal: "Gate não aprova com tests_frozen criado do zero e lê [commands].verify do repo, não da worktree"
title: Fix do judge — buracos do gate
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T8
depends_on: [TASK-08-pi-host-adapter]
tier: free
touch: [src/gate.ts, tests/gate_fix.test.ts]
done_when: "bun test tests/gate_fix.test.ts tests/worktree_gate.test.ts"
tests_frozen: [tests/gate_fix.test.ts]
---
## Fazer
- `protectTestsFrozen`: todo `tests_frozen` tocado conta como violação, com ou sem restauração. Se não existir na base, a "restauração" é remover o arquivo (`git rm --cached -f` + apagar). Devolver a lista mesmo se a restauração falhar.
- `configuredVerify`: ler só do `repo` (trunk). A worktree é mutável pelo executor e não pode definir o próprio gate.
- Testes RED já escritos pelo Planner em `tests/gate_fix.test.ts` (frozen).
## Não fazer
- Não alterar `tests/worktree_gate.test.ts` (frozen).
## Contexto
- Judge (Codex + Gemini flash) do PLAN-0007: `src/gate.ts:87-95` e `:104-132`.

---
type: task
mode: mvp
goal: "A enumeração da CLI cobre os 8 verbos de operação; a delegação resolve binários pelo PATH corrente do processo"
title: cobertura dos verbos de operação na CLI
plan: PLAN-0015-init-e-homelab
repo: ginga
depends_on: [TASK-03-ginga-cobre-homelab]
tier: free
touch: [tests/cli_verbs.test.ts, src/workspace.ts, src/verbs/ops.ts]
done_when: "bun test tests/cli_verbs.test.ts"
tests_frozen: [tests/cli_verbs.test.ts]
pinga_task: T131
---
## Fazer
- `tests/cli_verbs.test.ts` (frozen T121; alterado por TASK nova — precedente T128): CASES dos 8
  verbos novos + stubs de PATH (`stubBin`) + `via`/`bin` no laço comparador.
- `src/workspace.ts:binary` — `Bun.which` sem 2º argumento usa o PATH do snapshot de boot do
  processo; em chamada in-process (API/`run` direto) isso resolve o binário REAL, não o PATH
  atual. Resolver com `Bun.which(name, { PATH: process.env.PATH ?? "" })`.
## Não fazer
- Não mudar a superfície dos verbos (já registrada em T130).
## Contexto
- Achei na r5: suíte verde em CLI (spawn com env custom) mas `gira`/`verify`/`maestro` in-process
  pegavam `~/.local/bin` — nondeterminismo e side effect no ledger real.

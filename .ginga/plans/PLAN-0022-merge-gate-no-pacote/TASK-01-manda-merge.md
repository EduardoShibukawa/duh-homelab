---
type: task
mode: padrao
goal: "manda merge <PLAN> <repo> <branch> --json reproduz o gate de .ginga/bin/merge-gate.sh (exit 0/2/10/11/12/13/14/15)"
title: manda merge (gate determinístico)
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: []
tier: medium
pinga_task: T16
touch: [src/merge.ts, src/cli.ts, tests/merge_gate.test.ts, tests/fixtures/merge/]
done_when: "bun test tests/merge_gate.test.ts"
tests_frozen: [tests/fixtures/merge/pinga-stub]
---
## Fazer
- Um caso por código de saída, em um repo git temporário de fixture: sem veredito ou HEAD diferente (10), `regression` (11), TASK do diff sem receipt `done` (12, com `pinga queue` em stub), falha nova na branch (13), main piora depois do merge e é revertida (14).
- O merge exporta `MERGE_GATE=1`. Grava uma linha no `log.md` do PLAN.
## Não fazer
- Sem LLM no caminho. Sem push.
## Contexto
- A referência é `.ginga/bin/merge-gate.sh`; o comparativo de falhas é o conjunto de `(fail)` da main × o da branch.
- `tests/merge_gate.test.ts` passou a ser `tests_frozen` da TASK-02 (T17), que corrigiu 3 erros de autoria; por isso saiu da lista deste arquivo.

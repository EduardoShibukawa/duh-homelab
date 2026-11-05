---
type: task
mode: mvp
goal: "pinga learn propose e pinga learn promote avisam no stderr que as lições migraram para o ginga, sem mudar a saída nem o exit code"
title: pinga learn avisa a migração
plan: PLAN-0013-handoff-e-learnings
repo: p-inga
depends_on: []
tier: free
touch: [src/cli.ts, src/lessons_migrado.ts, tests/learn_migrado.test.ts]
done_when: "bun test tests/learn_migrado.test.ts"
tests_frozen: [tests/learn_migrado.test.ts]
---
## Fazer
- O ramo `learn` do `src/cli.ts` (subcomandos `propose` e `promote`) escreve uma linha no stderr: `aviso: lições migraram para o ginga (ginga lessons import / ginga learning promote)`.
## Interface
- `export const MIGRATION_NOTICE: string` em `src/lessons_migrado.ts`. Teste: rodar os dois comandos com HOME e state temporários → stderr contém `MIGRATION_NOTICE`; stdout e exit iguais aos de antes (comparar com a execução sem o aviso via snapshot do teste).
## Não fazer
- Não remover os comandos nem mudar o ledger (o corte fica para depois do PLAN-0017).
## Contexto
- `src/cli.ts:918` (ramo `learn`), `src/lessons.ts` (`proposeCmd`, `promoteCmd`; não tocar).

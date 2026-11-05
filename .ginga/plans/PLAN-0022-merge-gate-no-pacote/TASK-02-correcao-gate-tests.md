---
type: task
mode: padrao
goal: "Corrigir 3 erros de autoria em tests/merge_gate.test.ts (veredicto desatualizado em 13, commit faltante em 14, wtHead() após remover worktree em 2a) para que o gate fiel a merge-gate.sh passe"
title: correção dos testes congelados do gate (13, 14, 2a)
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T17
touch: [tests/merge_gate.test.ts]
done_when: "bun test tests/merge_gate.test.ts"
---
## Fazer
- A referência é `.ginga/bin/merge-gate.sh` (veredito sobre o HEAD exato da branch).
- Teste 13: escrever o veredito DEPOIS do commit do teste quebrado (o judge real roda sobre o estado final).
- Teste 14: adicionar o `git add/commit` de `tests/needs_helper.test.ts` que o comentário do caso descreve ("a branch comita um teste").
- Teste "2: sem worktree": escrever o veredito ANTES de remover a worktree (o `wtHead()` após a remoção dá ENOENT e o conteúdo é irrelevante para o exit 2).
## Não fazer
- Não tocar em `src/merge.ts` nem em `tests/fixtures/merge/pinga-stub`.
## Contexto
- Correção de tests_frozen por TASK nova conforme regra do operador; a implementação de T16 fica intacta.

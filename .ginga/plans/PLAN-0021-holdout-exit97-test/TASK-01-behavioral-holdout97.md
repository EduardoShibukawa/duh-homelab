---
type: task
mode: mvp
goal: "teste comportamental: holdout do verify com wrapper exit 97 vira receipt blocked/infra"
title: behavioral holdout exit 97
plan: PLAN-0021-holdout-exit97-test
repo: p-inga
depends_on: []
tier: free
pinga_task: T76
touch: [tests/exec_wrapper_holdout97.test.ts]
done_when: "bun test tests/exec_wrapper_holdout97.test.ts"
tests_frozen: []
---
## Fazer
- Adicionar teste comportamental que executa `pinga verify` com wrapper saindo 97 só no holdout (passando no done_when visível) e verifica receipt blocked/infra.
## Contexto
- PLAN-0021 follow-up do judge de PLAN-0018 TASK-07.

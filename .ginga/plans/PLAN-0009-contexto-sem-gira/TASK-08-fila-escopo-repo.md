---
type: task
mode: mvp
goal: "A fila do pinga só conta recibo do repo da raiz (ou legado sem repo): pass de T4 em outro repo não fecha a T04"
title: Fila do pinga filtra recibos por repo (achado do judge)
plan: PLAN-0009-contexto-sem-gira
repo: p-inga
pinga_task: T79
depends_on: []
tier: free
touch: [src/queue.ts, tests/queue_repo_scope.test.ts]
done_when: "bun test tests/queue_repo_scope.test.ts tests/queue.test.ts tests/queue_state_prove_red.test.ts tests/queue_state_retention.test.ts"
tests_frozen: [tests/queue_repo_scope.test.ts]
---
## Fazer
- `scanQueue` descarta, antes de casar receipts, linha cujo `body.repo` existe e difere de `repoScope(root)` (`src/breaker.ts`). Sem `repo` (legado) ou raiz sem git: mantém.
## Não fazer
- Não tocar em verify/ledger/judge; não mudar `normalizeTask`.

---
type: task
mode: padrao
goal: "Fazer tests/e2e/two_runtimes.test.ts passar de novo em plan/0008 sem alterar o teste congelado, corrigindo run.ts (e routing.ts quando aplicável)"
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: []
tier: free
pinga_task: T15
touch:
  - src/run.ts
  - src/routing.ts
tests_frozen:
  - tests/e2e/two_runtimes.test.ts
done_when: "bun test tests/e2e/two_runtimes.test.ts"
---
# TASK-09: correção do e2e two_runtimes (PLAN-0008)

O pi adapter passou a ser fail-closed (T9) e o `run.ts` não passava provider/modelo
para o adapter no caminho de runtime fixo, quebrando o e2e congelado do PLAN-0007.
Ajustar `run.ts` (e `routing.ts` se necessário) para que o runtime fixo invoque o
adapter com rota válida, sem reintroduzir padrão no `pi.ts`.
---
type: task
mode: mvp
goal: "Com a cota free esgotada, a lane espera com backoff de 15, 30 e 60 minutos e só volta depois de um probe ok, em vez de sair com exit 4"
title: free_retry com espera
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-02-probe, TASK-04-escada-por-custo]
tier: free
touch: [src/free_retry.ts, tests/free_retry.test.ts]
done_when: "bun test tests/free_retry.test.ts"
tests_frozen: [tests/free_retry.test.ts]
pinga_task: T173
---
## Fazer
- `freeRetryWait(n)` → 15, 30, 60, 60... min. Laço: espera, `probe` do 1º free; ok → devolve o modelo; falha → próxima espera. Sinal de parada injetado.
## Interface
- `export function freeRetryWait(n: number): number` (ms) e `export async function waitForFree(o: { free: string[]; probe: (m: string) => Promise<{ ok: boolean }>; sleep: (ms: number) => Promise<void>; stop: () => boolean }): Promise<string | null>`. Teste: probe falha 2× e passa → dormiu 15+30 min (sleep falso) e devolve o modelo.
## Não fazer
- Não chamar modelo pago enquanto espera.
## Contexto
- `handoffs/.free-esgotado` e exit 4 de hoje (`lane.sh`, PLAN-0023 TASK-24).

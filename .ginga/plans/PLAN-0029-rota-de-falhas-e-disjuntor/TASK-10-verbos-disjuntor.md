---
type: task
mode: mvp
goal: "manda breaker status lista o disjuntor de cada modelo e manda breaker reset <modelo> fecha um, para recuperação manual"
title: Verbos do disjuntor
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-03-disjuntor]
tier: free
touch: [src/breaker_cli.ts, src/cli.ts, tests/breaker_cli.test.ts]
done_when: "bun test tests/breaker_cli.test.ts"
tests_frozen: [tests/breaker_cli.test.ts]
pinga_task: T306
---
## Fazer
- `status --json` → `[{model, state, until, level, last_reason}]`; `reset <modelo>` → `recordSuccess` + evento `transition`. Subcomando `breaker` registrado no `src/cli.ts`.
## Interface
- `export function breakerStatus(db: Database, now: Date): { model: string; state: BreakerState; until: string | null; level: number; last_reason: string | null }[]`; `export function breakerReset(db: Database, model: string): void`. Teste: 2 modelos (1 aberto) → status; reset → `closed`.
## Não fazer
- Não mudar outros subcomandos do `src/cli.ts`.
## Contexto
- INTENT-0008 ("verbos de recuperação").

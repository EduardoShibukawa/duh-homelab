---
type: task
mode: padrao
goal: "O manda respeita os tetos de TASK, PLAN e mês, avisa em 80% e pede OK só ao passar do teto ou ao cair no claude"
title: Tetos de budget e OK do dono
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: [TASK-04-escalada-breaker]
tier: medium
pinga_task: T12
touch: [src/budget.ts, src/run.ts, src/cli.ts, tests/budget.test.ts]
done_when: "bun test tests/budget.test.ts"
tests_frozen: [tests/budget.test.ts]
---
## Fazer
- Gasto: soma de `cost_usd` dos `attempt` em `.ginga/state/manda-spend.jsonl` (ou `--spend-cmd` que devolve JSON, para o ginga).
- `budget` warn em 80%; no teto, ou se o próximo candidato é `runtime: claude`, para e emite `blocker` pedindo OK.
- `--approve <scope>` (ou `MANDA_APPROVED_SCOPES`) libera um teto uma vez.
## Não fazer
- Não descontar quota de assinatura como custo (só `cost_source: metered`).
## Contexto
- `.ginga/models/ROUTING.md` ("Budget do Zen", "Escalada"); `pi-harness/src/async/budget_scheduler.ts`.

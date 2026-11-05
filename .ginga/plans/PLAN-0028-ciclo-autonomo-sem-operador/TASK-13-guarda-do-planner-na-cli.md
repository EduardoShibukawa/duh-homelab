---
type: task
mode: padrao
goal: "Corrige o achado grave do judge (refs AC e TASK-12) no `manda replan` da CLI: a guarda do planner em src/cli.ts passa a medir o gasto real (janela de 24h como run/judge/replan, não since=agora, e claudeCosts alimentado com o total_cost_usd do stdout do planner), bloqueia antes de CADA chamada paga do planner (primária e fallback) e entrega model/since/claudeCosts para a guarda interna de replan() — o gasto do planner passa a ser medido e barrado antes de gastar"
title: Guarda do planner na CLI mede e barra o gasto real (achado grave do judge na TASK-12)
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-12-teto-ligado-nas-chamadas-pagas]
tier: free
touch: [src/cli.ts, src/cost_cap.ts, src/replan.ts, tests/replan_cli_cost.test.ts, tasks/T163/PLAN.md]
done_when: "bun test tests/replan_cli_cost.test.ts tests/replan_cli.test.ts tests/cost_cap_wiring.test.ts tests/replan.test.ts"
tests_frozen: [tests/replan_cli_cost.test.ts]
pinga_task: T163
---
## Achado do judge (2026-10-30, grave; refs AC e TASK-12)
- `src/cli.ts:257-263`: guarda do planner usa `since=agora` e `claudeCosts:[]` → gasto medido ~0; o planner roda em cli.ts:268 antes de `replan()`, então a guarda de `src/replan.ts:62-77` chega depois do gasto; o fallback do planner não faz nova checagem; `claudeCosts` nunca recebe `total_cost_usd`; `ginga cost --json` não existe (só o fallback opencode.db+claude mede de fato).

## Fazer
- `src/cost_cap.ts` (sem mudar `capCheck`/`spentUsd`/`checkPaidCall` nem seus testes congelados): adicionar `extractTotalCostUsd(output: string): number | undefined` — varre as linhas JSON do stdout (stream-json do claude) e devolve o último `total_cost_usd` numérico; sem match → `undefined`.
- `src/cli.ts` (comando `replan`): `since` = agora − 24h (mesma janela de run.ts/judge.ts/replan.ts); acumular `claudeCosts: number[]` com o `extractTotalCostUsd` de cada chamada do planner; checar `checkPaidCall({root, since, next_estimate_usd: 0.15, model, claudeCosts})` ANTES da chamada primária e NOVAMENTE antes do fallback (com o custo da primária já em `claudeCosts`); bloqueio → imprime `{"result":"blocked",...}` e return 1 sem chamar o LLM; passar `model`, `since` e `claudeCosts` para `replan({...})`.
- `src/replan.ts`: aceitar `claudeCosts?: number[]` opcional em `ReplanOptions` e repassar para o `checkPaidCall` interno (comportamento padrão inalterado).
- Testes frozen em `tests/replan_cli_cost.test.ts` (estilo de `tests/replan_cli.test.ts`, fakes em PATH + HOME temporário com opencode.db fixture e `[budget] round_usd`): (1) gasto de 24h no opencode.db (0.90 a 1h atrás, teto 1.00) bloqueia o planner pago SEM chamar o claude; (2) planner que falha com `total_cost_usd: 0.90` no stdout bloqueia o fallback SEM chamar o opencode; (3) modelo free (`-free`) não é barrado mesmo com gasto alto; (4) dentro do teto o planner roda e o resultado é `replanned`; (5) `extractTotalCostUsd` via import dinâmico (falha por asserção no base).

## Não fazer
- Não editar `tests/cost_cap_wiring.test.ts`, `tests/cost_cap.test.ts`, `tests/replan_cli.test.ts` nem a fixture `tests/fixtures/opencode-cost.sql`. Não mudar `capCheck`/`spentUsd`/`checkPaidCall`. Não ler `paid-spend.tsv`, não usar `TOTAL_CAP` de ambiente, sem rede. Não criar `ginga cost --json` (o fallback opencode.db+claudeCosts é o medidor real).

## Contexto
- TASK-12 (T162) ligou o teto em run/judge/replan; o judge reprovou porque na CLI real o planner é chamado antes da guarda da lib e a guarda da CLI mede ~0. Estimativa padrão por tentativa paga: 0.15. RED esperado: testes (1), (2) e (5) falham no base; (3) e (4) passam.

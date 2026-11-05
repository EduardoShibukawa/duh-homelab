---
type: task
mode: padrao
goal: "Antes de cada chamada paga dos papéis LLM (executor em run.ts, judge em judge.ts, planner em replan.ts), o manda lê o teto em [budget] round_usd do .ginga/project.toml, mede o gasto real por `ginga cost --json` (fallback opencode.db + custos do claude) e bloqueia a chamada que passaria do teto"
title: Teto ligado às chamadas pagas (achado grave do judge na TASK-06)
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-06-teto-todos-papeis]
tier: free
touch: [src/cost_cap.ts, src/run.ts, src/judge.ts, src/replan.ts, tests/cost_cap_wiring.test.ts, tasks/T162/PLAN.md]
done_when: "bun test tests/cost_cap_wiring.test.ts tests/cost_cap.test.ts tests/run.test.ts tests/judge_module.test.ts tests/replan.test.ts"
tests_frozen: [tests/cost_cap_wiring.test.ts]
pinga_task: T162
---
## Achado do judge (2026-10-30, grave)
- `capCheck`/`spentUsd` existem em `src/cost_cap.ts` e passam no teste, mas nenhum código os chama: o teto não é checado antes de chamada paga, `[budget] round_usd` não é lido e `ginga cost --json` não é usado. AC do PLAN não atendido.

## Fazer
- Em `src/cost_cap.ts` (sem mudar `capCheck`/`spentUsd` nem seus testes congelados), adicionar:
  - `loadRoundCapUsd(root: string): number` — lê `[budget] round_usd` de `<root>/.ginga/project.toml` (Bun.TOML.parse); sem a chave → `Infinity` (sem teto). **Não** cair no `TOTAL_CAP` do ambiente.
  - `isPaidModel(model: string | undefined | null): boolean` — free se o modelo começa com `pi:` ou casa com `/[-:]free$/i`; caso contrário pago (inclusive `undefined`).
  - `checkPaidCall(o: { root: string; since: string; next_estimate_usd: number; model?: string | null; opencodeDb?: string; claudeCosts?: number[]; costCmd?: string[] }): CapResult` — se `model` é free → `{allow:true}`; senão: cap = `loadRoundCapUsd(root)`; gasto = `costCmd` (padrão `["ginga","cost","--json"]`, spawnSync com cwd=root) devolvendo JSON com `spent_usd` numérico; se o comando falha/não existe, fallback para `spentUsd({since, opencodeDb, claudeCosts})` (`opencodeDb` padrão `~/.local/share/opencode/opencode.db`); retorna `capCheck({spent_usd, next_estimate_usd, cap_usd: cap})`.
- Ligar a guarda **antes** de cada chamada paga:
  - `src/run.ts`: antes de `adapter.run(request)` no loop de tentativas (papel executor), com `model: request.model ?? spec.model`, `since` = ISO do início do runPlan, `costCmd`/`nextEstimateUsd` (padrão 0.15) injetáveis via `RunOptions`. Se `!allow`: emite evento `budget`/`blocker` como o bloqueio de budget existente, não chama o adapter, e devolve outcome `passed:false` (sem merge).
  - `src/judge.ts`: antes de `adapter.run(...)` do juiz, com `model: chosen.model`; se `!allow` → retorna exitCode não-zero sem chamar o adapter. `costCmd`/`nextEstimateUsd` injetáveis via `JudgeOptions`.
  - `src/replan.ts`: antes de `options.planner(...)`, com `model`/`costCmd`/`since` opcionais em `ReplanOptions`; se `!allow` → `{result:"blocked", reason}` sem chamar o planner.
- Testes novos em `tests/cost_cap_wiring.test.ts` (frozen): imports **dinâmicos** do módulo (no base o named export não existe e a falha tem de ser por asserção, não por import); cobre `loadRoundCapUsd` (com e sem `[budget]`), `isPaidModel`, `checkPaidCall` com `costCmd` falso (`bun -e` imprimindo `{"spent_usd":0.9}`), modelo free, e fallback para `spentUsd` com a fixture `tests/fixtures/opencode-cost.sql` quando o `costCmd` falha; mais integração via `runPlan` com `resolveRuntime` stub (harness no estilo de `tests/run.test.ts`): `executor = "opencode:paid-pro"` + `[budget] round_usd = 1.00` + `costCmd` com gasto 0.90 e estimativa 0.30 → o adapter **não** é chamado e a TASK falha; com gasto 0.10 → adapter chamado e TASK passa.

## Não fazer
- Não editar `tests/cost_cap.test.ts` nem a fixture `tests/fixtures/opencode-cost.sql` (frozen da TASK-06). Não ler `paid-spend.tsv`. Não usar `TOTAL_CAP` do ambiente. Sem rede.
- Não mudar as assinaturas existentes de `capCheck`/`spentUsd`; só adicionar.

## Contexto
- TASK-06 (T155) criou o módulo; o judge reprovou porque nada chama. AC do PLAN: "teto de custo cobre todos os papéis, checado antes de cada chamada paga". Estimativa padrão por tentativa paga: 0.15 (maior custo pago já visto, como no `dispatch-task.sh`).

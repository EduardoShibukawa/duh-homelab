# Operador duh-homelab - PLAN-0028

## Execução

**Worktree**: /home/shibuka/Projetos/duh-homelab/manda-plan-0028
**Branch**: plan/0028
**Item**: PLAN-0028-ciclo-autonomo-sem-operador

## Achados do judge resolvidos

### TASK-13 (T163) – Guarda do planner na CLI
- **PLAN**: tasks/T163/PLAN.md
- **Goal**: Guarda do planner no `manda replan` da CLI mede gasto real (since=24h, claudeCosts com total_cost_usd) e bloqueia antes de cada chamada paga
- **pinga prove-red**: pass (RED falha no base)
- **Implementação**:
  - `src/cost_cap.ts`: `extractTotalCostUsd` adicionado; `spentUsd` com try/catch para DB vazio; default path usa `process.env.HOME ?? homedir()`
  - `src/replan.ts`: `claudeCosts` opcional em `ReplanOptions` e repassado ao `checkPaidCall`
  - `src/cli.ts`: `since` = agora-24h; `claudeCosts` acumulado com `extractTotalCostUsd`; `checkPaidCall` antes da primária e antes do fallback; `model/since/claudeCosts` passados para `replan`
- **pinga verify**: pass (receipt id c190dfc9-0dc7-4c66-87cc-9aac92ce3dfb, status pass)
- **bun test**: `tests/replan_cli_cost.test.ts` 5/5 pass
  - gasto real 24h bloqueia antes de chamar LLM: pass
  - fallback nova checagem com total_cost_usd: pass
  - modelo free não barrado: pass
  - dentro do teto roda: pass
  - extractTotalCostUsd: pass

### TASK-12 regressão (src/cost_cap.ts)
- **Problema**: `spentUsd` abria `session_v2` sem try/catch; com `opencode.db` vazio lançava `SQLiteError` via `checkPaidCall`
- **Correção**: `spentUsd` envolve criação/consulta do DB em try/catch; default path usa `process.env.HOME ?? homedir()` para testes com HOME temporário
- **Impacto**: `tests/cost_cap.test.ts` 4/4 pass; `tests/cost_cap_wiring.test.ts` 9/9 pass; suíte regressão mitigada

## Ready
`.ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/ready/manda.json` já contém `{"branch":"plan/0028"}`

## Decisões
- Nenhuma decisão fora de regra; correções realizadas dentro da TASK T163 com teste RED prévio.

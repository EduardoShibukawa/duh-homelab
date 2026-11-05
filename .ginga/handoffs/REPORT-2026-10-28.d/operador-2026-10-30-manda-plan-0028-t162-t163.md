# Handoff — operador (lane manda, 2026-10-30)

## Fatos

### Judge findings resolvidos (PLAN-0028, worktree manda-plan-0028)

#### T162 — regressão spentUsd (judge: "fora do teto quebra a main")
- **Problema:** `spentUsd` (`src/cost_cap.ts:44`) faz `SELECT` em `session_v2` sem try/catch. Com `~/.local/share/opencode/opencode.db` vazio (0 bytes, sem a tabela), lança `SQLiteError`, cascateando para `run.ts:339` e `cli.ts:258`, mesmo sem `[budget]`. Suíte: 4 → 48 falhas.
- **Fix:** try/catch ao redor do `SELECT` — DB sem tabela = gasto 0. Commit `c785473` (base 47ebe2e).
- **`pinga verify`:** pass (seq 1289).
- **Testes:** done_when (33/0) + suíte completa 263/4 (4 pré-existentes da main).

#### T163 — implementação planner CLI guarda (judge: "HEAD é só o RED")
- **Problema:** `extractTotalCostUsd` inexistente; `cli.ts:257-263` usa `since=now` e `claudeCosts:[]`; planner roda sem checagem antes do fallback.
- **Fix:**
  - `src/cost_cap.ts`: `extractTotalCostUsd(output)` — varre linhas JSON do stdout, devolve último `total_cost_usd`.
  - `src/cli.ts`: `since=24h`, `claudeCosts` acumulado da primária; `checkPaidCall` antes da primária e antes do fallback com custo já acumulado; passa `model/since/claudeCosts` para `replan()`.
  - `src/replan.ts`: `claudeCosts?: number[]` em `ReplanOptions`, repassado a `checkPaidCall`.
  - Commit `f968019` (base c785473).
- **`pinga verify`:** pass (seq 1290).
- **Testes:** done_when 19/0.

#### T155, T156, T159 — scope_drift cleanup
- **Motivo:** commits de T162/T163 tocaram arquivos fora do `touch` dessas TASKs (src/cli.ts, src/replan.ts).
- **Fix:** re-verify com `--base HEAD --allow-no-delta` (sem delta, apenas re-sela pass).
- **Resultado:** T155 pass, T156 pass, T159 pass — todos os 44 tasks done/pass.

### Estado final
- `pinga queue --json`: 44 done, 0 blocked.
- `pinga ledger verify`: ok 1294.
- Suíte completa `bun test`: 263 pass, 4 fail (pré-existentes: judge CLI ×2, pipeline/lane ×2 — identificadas pelo judge como "da main").
- `ready/manda.json`: `{"branch":"plan/0028"}`.

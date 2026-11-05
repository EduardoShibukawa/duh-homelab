---
type: task
mode: mvp
goal: "O stub de quota do tick (`src/tick.ts:593` `cap_ok: true, // assume ok for now`) passa a ser alimentado por `ginga quota`: `cap_ok` vem de `readQuotas` (via `quotaCapOk` puro em `src/quota/index.ts`) e fica falso quando algum provider automático está esgotado (used_pct >= 100)"
title: ginga quota alimenta o stub de quota do tick
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-03-quota-claude]
tier: free
pinga_task: T364
touch: [src/tick.ts, src/quota/index.ts, tests/quota_cap.test.ts]
done_when: "bun test tests/quota_cap.test.ts tests/tick_plan.test.ts tests/tick.test.ts"
tests_frozen: [tests/quota_cap.test.ts]
---
## Fazer
- Decisão do PLAN (emendas 2026-10-29): "`ginga quota` entra no registro de verbos e alimenta o stub de quota do `tick` (PLAN-0010)". O judge 2026-11-03T02:50 confirmou que `src/tick.ts` não menciona quota: o stub é `cap_ok: true, // assume ok for now` em `src/tick.ts:593`.
- Em `src/quota/index.ts` exporte `quotaCapOk(quotas: Quota[]): boolean` (puro): falso se alguma quota com `source` automático (`codex-rollout`, `claude-statusline`, `opencode-db`) tem `used_pct` não nulo e `>= 100`; `manual`, `unavailable` e `stale` nunca bloqueiam.
- Em `src/tick.ts` troque o literal por `cap_ok: quotaCapOk(readQuotas({ home: process.env.HOME ?? homedir(), db }))` (imports de `./quota/index.ts` e `node:os`). Só no fluxo por fase (onde está o stub hoje); não mexa no fluxo antigo de fila.
- `nextAction` (src/tick_plan.ts) já trata `cap_ok === false` como `notify` "capacidade/limites indisponíveis" — não mude `tick_plan.ts` nem testes alheios.
## RED
- `tests/quota_cap.test.ts`: (1) unitário de `quotaCapOk` (100% → false; manual/unavailable/stale → true; 99.9 → true); (2) e2e como `tests/tick_plan.test.ts`: PLAN por fase em `tasks` + HOME falso com `~/.local/state/ginga/claude-rate-limits.json` esgotada (`five_hour.used_percent: 100`) → `runTick` NÃO despacha (log de comandos sem `run`); com `used_percent: 10` → despacha. Hoje falha: o stub fixo `cap_ok: true` despacha nos dois casos.

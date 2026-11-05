---
type: task
mode: mvp
goal: "Um script de statusline grava os rate_limits do Claude e ginga quota --json junta Claude, Codex e os providers manuais"
title: Quota do Claude + ginga quota
plan: PLAN-0014-metricas-e-quota
repo: ginga
pinga_task: T354
depends_on: [TASK-02-quota-codex, TASK-07-custo-opencode-db]
tier: free
touch: [contrib/claude-statusline.sh, src/quota/claude.ts, src/quota/index.ts, src/verbs/quota.ts, src/verbs/registry.ts, tests/quota.test.ts]
done_when: "bun test tests/quota.test.ts"
tests_frozen: [tests/quota.test.ts]
---
## Fazer
- `claude-statusline.sh`: lê o JSON do stdin, grava `rate_limits` (`five_hour`, `seven_day`) em `~/.local/state/ginga/claude-rate-limits.json`, imprime uma linha curta.
- `ginga quota --json`: claude-pro e chatgpt-go automáticos; gemini-pro e opencode-go com `source: manual`; zen pelo gasto dos eventos `cost` do mês (TASK-07) contra o budget do ROUTING (`source: "opencode-db"`).
## Interface
- `readQuotas({home, db})` (PLAN.md) em `src/quota/index.ts`; `readClaudeQuota(path: string): Quota` em `src/quota/claude.ts`. Teste: HOME falso com o arquivo da statusline e um rollout → 2 automáticos, 2 `manual`, zen com `used_pct` = gasto/budget.
## Não fazer
- Não editar `~/.claude/settings.json` (instrução no README para o dono).
## Contexto
- `.ginga/models/PROVIDER-*.md` (`quota_check`).

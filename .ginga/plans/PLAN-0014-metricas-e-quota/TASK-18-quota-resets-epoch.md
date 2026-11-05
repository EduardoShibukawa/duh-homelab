---
type: task
mode: padrao
goal: "readCodexQuota e readClaudeQuota aceitam resets_at em epoch numérico (segundos ou ms), normalizando para string ISO; com o formato real do Codex a quota sai completa (não stale), o evento quota é emitido e o cap_ok do tick bloqueia com used_pct >= 100"
title: Quota aceita resets_at em epoch (formato real dos rollouts)
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-02-quota-codex, TASK-03-quota-claude]
tier: free
pinga_task: T367
touch: [src/quota/codex.ts, src/quota/claude.ts, tests/quota_resets_epoch.test.ts]
done_when: "bun test tests/quota_resets_epoch.test.ts tests/quota_codex.test.ts tests/quota.test.ts tests/quota_cap.test.ts"
tests_frozen: [tests/quota_resets_epoch.test.ts]
---
## Fazer
- Achado grave do judge 2026-11-03T11:23 (gate fail no PLAN-0014, reprovou AC/TASK-02): os rollouts reais do Codex (`~/.codex/sessions/**/rollout-*.jsonl`) bring `"resets_at":1795285686` (epoch **numérico**), mas `primaryLimits` (`src/quota/codex.ts`) e `readWindow` (`src/quota/claude.ts`) só aceitam `typeof === "string"` → `resets_at: null` → `complete: false` → `source: "stale"` com dados reais. Consequência: o evento `quota` nunca é emitido e `quotaCapOk` ignora `stale`, então o `cap_ok` do tick (`src/tick.ts:595`) não bloqueia com o Codex esgotado. O fixture ISO escondia o defeito.
- Normalização única nos dois parsers: número finito → ISO string, `v >= 1e12` é milissegundos, senão segundos (`new Date(v >= 1e12 ? v : v * 1000).toISOString()`); string continua aceita; qualquer outro tipo → `null` (continua `stale`).
- `Quota.resets_at` continua `string | null` (o schema do evento exige string em `src/events/validate.ts:57`) — a normalização acontece na leitura, não no tipo.
## RED
- `tests/quota_resets_epoch.test.ts` (frozen desta TASK, já commitado RED em `01c60ce`): rollout com `resets_at: 1795285686` e `used_percent: 100` → `source: "codex-rollout"`, `resets_at === new Date(1795285686*1000).toISOString()`, 1 evento `quota` com `resets_at` string e `quotaCapOk([quota]) === false`; epoch em ms; último rate_limits vence misturando ISO/epoch; resets_at inválido (objeto/bool) continua `stale` sem evento; statusline do Claude com `five_hour.resets_at` epoch → `claude-statusline`.
## Não fazer
- Não altere `tests/quota_codex.test.ts`, `tests/quota.test.ts`, `tests/fixtures/codex-rollout.jsonl` nem `src/events/validate.ts` (frozen de outras TASKs). Não mude o tipo `Quota` nem `quotaCapOk` — a correção é só na normalização do `resets_at` lido.
## Contexto
- Judge 2026-11-03T11:23 (`judge/ginga-20261103T112303.log`): "os rollouts reais do Codex bring resets_at epoch numérico (1795285686) e o parser só aceita string, então a quota sai 'stale' com dados reais". Verificado em `~/.codex/sessions`: `"resets_at":1795223153`.

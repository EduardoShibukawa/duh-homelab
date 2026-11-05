---
type: task
mode: mvp
goal: "O ginga lê a quota do Codex do último rate_limits nos rollouts e emite um evento quota"
title: Quota do Codex
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: []
tier: free
touch: [src/quota/codex.ts, tests/quota_codex.test.ts, tests/fixtures/codex-rollout.jsonl]
done_when: "bun test tests/quota_codex.test.ts"
tests_frozen: [tests/quota_codex.test.ts, tests/fixtures/codex-rollout.jsonl]
pinga_task: T342
---
## Fazer
- Achar o rollout mais recente em `$CODEX_HOME/sessions/**/rollout-*.jsonl` (padrão `~/.codex`); pegar o último `rate_limits` (`primary.used_percent`, `window_minutes`, `resets_at`).
- Evento `quota` (`provider: chatgpt-go`, `source: codex-rollout`); sem arquivo → `source: unavailable`.
## Interface
- `readCodexQuota(codexHome: string): Quota` em `src/quota/codex.ts` (tipo `Quota` no PLAN.md). Teste: fixture com 2 `rate_limits` → usa o último; diretório vazio → `source: "unavailable"`.
## Não fazer
- Fixture redigido (sem conteúdo de sessão real).
## Contexto
- `.ginga/models/PROVIDER-chatgpt-go.md` (`quota_check`). Implementação própria (o `codex_quota.ts` do pi-harness vai para `_archive/` no PLAN-0017; não importar).

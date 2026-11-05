---
type: task
mode: padrao
goal: "ginga metrics --json calcula FTPR por modelo, custo por TASK verificada e falhas por motivo a partir do state.db"
title: ginga metrics
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-07-custo-opencode-db]
tier: medium
pinga_task: T356
touch: [src/metrics.ts, src/verbs/read.ts, tests/metrics.test.ts, tests/fixtures/metrics/]
done_when: "bun test tests/metrics.test.ts"
tests_frozen: [tests/metrics.test.ts, tests/fixtures/metrics/events.jsonl]
---
## Fazer
- FTPR = TASKs com receipt `pass` na 1ª tentativa / TASKs tentadas, por modelo e por tier; exclui `quota_exhausted` e `infra`.
- Custo por TASK verificada = soma dos eventos `cost` (TASK-07; cai no `attempt.cost_usd` só se não houver `cost` da tentativa) / TASKs com `pass`; agregação por PLAN e SPEC (relações do frontmatter).
- Falhas por `failure`/`reason_code`; escaladas de tier; `--since`.
## Interface
- `computeMetrics(db, {since})` → `Metrics` (PLAN.md). Teste: fixture com 4 TASKs (1 pass de primeira, 1 pass na 2ª, 1 falha `quota_exhausted` + pass, 1 falha `infra`) → FTPR exclui as tentativas `quota`/`infra`; custo vindo de `cost` vence `attempt.cost_usd`.
## Não fazer
- Sem UI (TASK-05).
## Contexto
- Doc 05 §9 ("Métricas: de onde vem cada número"); `p-inga/src/maestro.ts` (scoreboard FTPR).

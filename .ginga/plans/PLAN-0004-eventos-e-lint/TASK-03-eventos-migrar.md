---
type: task
mode: padrao
goal: "ginga events migrate converte o events.jsonl do pi-harness para o envelope v1 de forma idempotente"
title: Migração do events.jsonl do pi-harness
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T3
depends_on: [TASK-02-eventos-schema]
tier: medium
touch: [src/events/migrate.ts, src/cli.ts, tests/events_migrate.test.ts, tests/fixtures/pi-harness-events.jsonl]
done_when: "bun test tests/events_migrate.test.ts"
tests_frozen: [tests/events_migrate.test.ts, tests/fixtures/pi-harness-events.jsonl]
---
## Fazer
- `attempt`: `specId`→`spec` (`SPEC-NNNN`), `taskId`→`task`, `runner`→`runtime`, `durationMs`→`duration_ms`, `costUsd`→`cost_usd`, `costSource`→`cost_source`, `tokens`→`tokens_total`; `passed` e `failure` como estão; `source: pi-harness`.
- `verify` (BDD) → `kind: receipt`, `data.check: bdd`, `status` pass se `failed == 0`.
- `id` determinístico (hash da linha): rodar duas vezes gera a mesma saída. Linhas inválidas são contadas, não abortam.
## Não fazer
- Não reescrever o arquivo de entrada (saída em `--out`).
## Contexto
- `pi-harness/src/harness/events.ts` (`AttemptEvent`, `VerifyEvent`, `parseEvents`).

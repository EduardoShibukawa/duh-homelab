---
type: task
mode: mvp
goal: "manda jev status mostra modo, provider e chave presente; manda jev shadow-report resume a concordância Jev × regra por classificador"
title: Verbos jev status e shadow-report
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: [TASK-04-blocked-hibrido, TASK-05-cota-por-log, TASK-06-novidade-do-judge]
tier: free
touch: [src/jev/report.ts, src/verbs.ts, src/cli.ts, tests/jev/report.test.ts]
done_when: "bun test tests/jev/report.test.ts"
tests_frozen: [tests/jev/report.test.ts]
---
## Fazer
- `manda jev status [--json]`: modo configurado e efetivo, provider, modelo, **se a chave existe (sem mostrar)**, classificadores ligados.
- `manda jev shadow-report [--json] [--since]`: por classificador, `n`, taxa de concordância, onde discordam (rótulo da regra × do Jev, sem o texto), custo e latência. É o relatório que o dono lê antes de mudar `shadow` para `on`.
## Interface
- Teste com eventos `jev.shadow`/`jev.call` sintéticos: contagens e taxas exatas; a chave nunca aparece na saída.
## Não fazer
- Não mudar `mode` (é do dono, em `project.toml`).
## Contexto
- SPEC-0004.

---
type: task
mode: mvp
goal: "classifyRun distingue devagar, na fila, travado e recusado a partir de observações da tentativa, sem relógio fixo"
title: Os quatro estados da tentativa
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: []
tier: free
touch: [src/run_state.ts, tests/run_state.test.ts]
done_when: "bun test tests/run_state.test.ts"
tests_frozen: [tests/run_state.test.ts]
pinga_task: T167
---
## Fazer
- `recusado`: `exit != null` e stderr casa ECONNRESET, HTTP 5xx, 429 ou "usage limit". `devagar`: evento nos últimos `no_progress_min`. `na_fila`: `stream_bytes == 0`, `probe_ok == true`, dentro de `patience_min`. `travado`: sem evento há `no_progress_min`, `cpu_pct < 1`, `!files_changed` e `probe_ok == false` (ou `na_fila` além da paciência).
## Interface
- `RunObs`, `classifyRun` (PLAN.md). Teste: tabela de 8 observações → estados e `reason` esperados.
## Não fazer
- Não matar processo (TASK-09).
## Contexto
- Decisões do dono ("Quatro estados, não um timeout").

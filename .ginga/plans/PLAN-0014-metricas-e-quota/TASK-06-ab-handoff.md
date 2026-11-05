---
type: task
mode: padrao
goal: "O ginga registra o experimento handoff-ab com os braços native-compact e ginga-handoff e importa eventos handoff/attempt de um JSONL"
title: A/B nativo vs handoff no bench do ginga
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: []
tier: medium
pinga_task: T352
touch: [src/bench/store.ts, src/bench/handoff_ab.ts, tests/bench_handoff_ab.test.ts, tests/fixtures/handoff-ab.jsonl]
done_when: "bun test tests/bench_handoff_ab.test.ts"
tests_frozen: [tests/bench_handoff_ab.test.ts, tests/fixtures/handoff-ab.jsonl]
---
## Fazer
- `src/bench/store.ts`: tabelas `experiment(id, methodology_version)`, `arm(experiment, id)`, `run(id, arm, task, started, ended)`, `event(run, ts, kind, json)` num banco próprio (`.ginga/state/bench.db`, caminho injetável).
- `experiment: handoff-ab`, `methodology_version: 1`, braços `native-compact` e `ginga-handoff`. Importar eventos `handoff`/`attempt` v1; o braço vem de `data.arm` (ausente → `native-compact` se não houver `handoff` na run).
- Métricas do doc 06 §6 por braço: custo e FTPR depois do corte, `handoff_tokens` médio.
## Interface
- `openBench(path: string): Database`; `importHandoffAb(bench: Database, jsonlPath: string): { runs: number; events: number }`; `handoffAbReport(bench: Database): { arm: string; runs: number; ftpr: number; cost_usd: number; handoff_tokens_avg: number | null }[]`. Teste: fixture de 4 runs (2 por braço) → relatório exato; importar 2× não duplica.
## Não fazer
- Sem porta de bench genérica (lacuna 9). Não ler o pi-harness.
## Contexto
- Doc 06 §6. Ontologia de referência (só leitura, sai no PLAN-0017): `pi-harness/src/bench/store.ts` l. 85-121.

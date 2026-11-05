---
type: task
mode: padrao
goal: "ginga cost sync lê o custo real das sessões no opencode.db (somente leitura) e grava eventos cost no state.db, sem duplicar"
title: Custo lido do opencode.db
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: []
tier: medium
touch: [src/cost/opencode_db.ts, src/verbs/cost.ts, src/verbs/registry.ts, tests/cost_opencode_db.test.ts, tests/fixtures/opencode-db.sql]
done_when: "bun test tests/cost_opencode_db.test.ts"
tests_frozen: [tests/cost_opencode_db.test.ts, tests/fixtures/opencode-db.sql]
pinga_task: T348
---
## Fazer
- `readOpencodeSessions`: abre o db com `readonly: true`; lê `session_v2` (`id`, `cost`, `tokens_input`, `tokens_output`, `time_created`, `directory`) e o modelo (`providerID/id`) da primeira `session_message` com `$.model.id`. Filtros `since` e `ids`. Colunas ausentes → lança `OpencodeSchemaError`.
- `syncCost`: um evento `cost` por sessão (`scope: "call"`, `cost_source: "reported"`, `provider`, `model`, `amount_usd`, `tokens_in`, `tokens_out`, `data.session_id`), idempotente pelo `session_id`.
- Verbo `cost sync` (args `since`, `db`; padrão `~/.local/share/opencode/opencode.db`) e `cost` (soma por dia e por modelo, `--json`).
## Interface
- `OcSession`, `readOpencodeSessions`, `syncCost` (PLAN.md). Teste: fixture SQL cria `session_v2`/`session_message` com 3 sessões (2 pagas, 1 free com custo 0) → 3 eventos, total igual à soma; 2ª sync → `emitted: 0`; db sem a coluna `cost` → `OpencodeSchemaError`.
## Não fazer
- Nunca escrever no `opencode.db`. Não ler o `paid-spend.tsv`.
## Contexto
- Decisão do dono (cobertura da visão 02, "Teto de custo medido pelo opencode.db"). Consulta de referência: `select date(time_created/1000,'unixepoch'), sum(cost) from session_v2 group by 1`.

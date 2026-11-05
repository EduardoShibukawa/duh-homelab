---
type: task
mode: padrao
goal: "Plugin do Hermes traduz resposta na thread e slash /ginga em verbos do ginga, só para user IDs da allowlist"
title: Plugin do Hermes (entrada)
plan: PLAN-0011-verbos-api-auth
repo: ginga
depends_on: [TASK-02-cli-verbos]
tier: medium
pinga_task: T125
touch: [contrib/hermes-plugin/plugin.yaml, contrib/hermes-plugin/__init__.py, contrib/hermes-plugin/test_inbound.py]
done_when: "python3 -m unittest discover -s contrib/hermes-plugin -p test_inbound.py"
tests_frozen: [contrib/hermes-plugin/test_inbound.py]
---
## Fazer
- Thread de PLAN (via `plan_thread`) + resposta → `ginga answer <blocker> <texto> --via discord|telegram --by <user>`.
- `/ginga intent|status|inbox|pause|approve <id>` → verbo correspondente; fora da allowlist, só leitura.
- Tradução determinística (sem LLM); conversa livre continua no LLM do Hermes.
## Não fazer
- Não reimplementar verbos: chamar a CLI `ginga`.
## Contexto
- `pi-harness/hermes-plugin/` (`plugin.yaml`, `__init__.py`), `pi-harness/tests/unit/hermes_plugin.test.ts`; DECISION-0002.

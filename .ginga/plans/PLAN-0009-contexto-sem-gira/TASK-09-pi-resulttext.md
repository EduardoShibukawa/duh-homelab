---
type: task
mode: padrao
goal: "O adapter pi devolve em resultText o texto da última mensagem do assistente, não o NDJSON cru"
title: pi resultText = texto do assistente (achado do e2e da TASK-07)
plan: PLAN-0009-contexto-sem-gira
repo: manda
pinga_task: T152
depends_on: [TASK-05-context-rg]
tier: free
touch: [src/runtime/pi.ts, tests/runtime_pi_text.test.ts, tasks/T152/PLAN.md]
done_when: "bun test tests/runtime_pi_text.test.ts tests/runtime_pi_opencode.test.ts"
tests_frozen: [tests/runtime_pi_text.test.ts]
---
## Fazer
- `src/runtime/pi.ts`: `resultText` = texto (`content[].text`) da ÚLTIMA `message_end` com `role: "assistant"`; sem nenhuma, `raw.stdout`. `stdout` segue cru.
## Por quê
- Com o pi real (`--mode json`) o stdout é NDJSON e o texto vem JSON-escapado; `manda plan` (`parseFiles`, `^=== FILE: ... ===$`) não acha os blocos do Planner. Achado ao escrever o e2e da TASK-07.

---
type: task
mode: padrao
goal: "os runtimes pi e opencode do manda exportam GINGA_GUARD_LANE e passam a extensão (-e) ou OPENCODE_CONFIG_DIR, na mesma construção de env/argv que o PLAN-0029 e o PLAN-0032 estabeleceram"
title: manda run liga o guard
plan: PLAN-0033-guard-de-segredos
repo: manda
depends_on: [TASK-06-fiacao-das-lanes]
pinga_task: T319
tier: medium
touch: [src/runtime/env.ts, src/runtime/pi.ts, src/runtime/opencode.ts, tests/runtime_guard.test.ts]
done_when: "bun test tests/runtime_guard.test.ts && bun test"
tests_frozen: [tests/runtime_guard.test.ts]
---
## Fazer
- Em `src/runtime/env.ts` (criado pela TASK-05 do PLAN-0029): acrescentar ao env de todo runtime `GINGA_GUARD_LANE=<PLAN-TASK>`, `GINGA_GUARD` (padrão `enforce`) e `GINGA_GUARD_LOG`. No `pi`: `-e <GUARD_DIR>/contrib/guard/pi.ts` junto ao `-e` do PLAN-0032. No `opencode`: `OPENCODE_CONFIG_DIR` (ou o que a Fase 2 confirmar). `GUARD_DIR` por `[guard] dir` no `project.toml`/env, com o checkout da main do `ginga` como padrão.
- Guard ausente com guard ligado → a tentativa não é spawnada e vira falha `guard_missing` (não `infra`).
## Interface
- O teste RED é escrito pelo Planner **depois** do merge do PLAN-0029 TASK-05 e do PLAN-0032 TASK-04, porque depende da API final de `env.ts`; formato: `spawnFn` falso e asserts sobre `argv`/`env` (como `tests/runtime_pi_scope.test.ts`).
## Não fazer
- **Não iniciar antes de PLAN-0029 e PLAN-0032 mergeados** (`git -C manda log main --oneline | grep -q PLAN-0029` e `PLAN-0032`): ambos editam `src/runtime/pi.ts` e o 0029 cria `env.ts`.
- Não importar código do ginga: o manda só consome o ginga por caminho/CLI (decisão 4 do revamp).
## Contexto
- Depois do PLAN-0028 o operador LLM some e o `manda run` vira o único caminho; esta TASK é o que mantém o guard nesse caminho.

---
type: task
mode: padrao
goal: "a extensão pi_scope_guard registra o handler tool_call, bloqueia com {block, reason} quando decideToolCall nega e libera com evento quando o próprio handler falha"
title: Extensão do Pi
plan: PLAN-0032-guarda-de-escopo-no-pi
repo: manda
depends_on: [TASK-01-decisao-de-escopo, TASK-02-casamento-de-caminho]
tier: medium
touch: [src/runtime/pi_scope_guard.ts, tests/pi_scope_guard.test.ts]
done_when: "bun test tests/pi_scope_guard.test.ts"
pinga_task: T164
tests_frozen: [tests/pi_scope_guard.test.ts]
---
## Fazer
- `export default function (pi)` registra `pi.on("tool_call", handler)`. O escopo vem de `MANDA_SCOPE_TOUCH`, `MANDA_SCOPE_FROZEN` (JSON) e `MANDA_SCOPE_ROOT`; **sem as variáveis, a extensão não registra nada** (inofensiva fora do manda).
- Handler: `decideToolCall`; se `allow: false` → `return { block: true, reason }`; senão `undefined`.
- Todo o corpo em `try/catch`: erro → `undefined` (libera) e emite `scope.guard_error` com a mensagem. Nunca lança.
## Interface
- Teste com um `pi` falso que guarda o handler: permite, bloqueia, JSON inválido nas variáveis (libera + erro), sem variáveis (não registra), exceção interna forçada (libera).
## Não fazer
- Não importar o pacote do Pi em tempo de execução além do tipo (`import type`). Não mexer em `~/.pi`.
## Contexto
- Pi `docs/extensions.md` (evento `tool_call`, `{block, reason}`; falha de handler bloqueia, por isso o `try/catch`); exemplo `protected-paths.ts`.

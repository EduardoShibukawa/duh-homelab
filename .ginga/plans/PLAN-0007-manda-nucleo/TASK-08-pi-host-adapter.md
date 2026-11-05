---
type: task
mode: mvp
goal: "O Pi ganha o comando /manda que só delega para a CLI manda run (host adapter)"
title: /manda no Pi como host adapter
plan: PLAN-0007-manda-nucleo
repo: pi-harness
pinga_task: T59
depends_on: [TASK-06-manda-run]
tier: free
touch: [.pi/extensions/manda-host.ts, .pi/extensions/index.ts, tests/unit/manda_host.test.ts]
done_when: "bun test tests/unit/manda_host.test.ts"
tests_frozen: [tests/unit/manda_host.test.ts]
---
## Fazer
- `/manda run <PLAN>` faz spawn de `manda run` e mostra stdout/exit no Pi; `manda` ausente → mensagem clara.
- Registrar em `.pi/extensions/index.ts`.
## Não fazer
- Não remover `/pipeline` nem mexer no `sdlc.ts` (a aposentadoria é decisão posterior).
## Contexto
- Padrão de registro de comando: `.pi/extensions/sdlc.ts` (`ExtensionAPI`), `.pi/extensions/index.ts`.

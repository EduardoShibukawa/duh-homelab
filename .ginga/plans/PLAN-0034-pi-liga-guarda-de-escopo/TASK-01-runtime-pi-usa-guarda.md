---
type: task
mode: padrao
goal: "o runtime pi do manda passa -e para a extensão e as variáveis de escopo derivadas do frontmatter da TASK, só quando a TASK declara touch"
title: Runtime pi liga a guarda
plan: PLAN-0034-pi-liga-guarda-de-escopo
repo: manda
pinga_task: T321
depends_on: []
tier: medium
touch: [src/runtime/pi.ts, tests/runtime_pi_scope.test.ts]
done_when: "bun test tests/runtime_pi_scope.test.ts tests/runtime_pi_opencode.test.ts tests/runtime_pi_text.test.ts"
tests_frozen: [tests/runtime_pi_scope.test.ts]
---
## Fazer
- Ao montar o `argv` do `pi -p`, acrescentar `-e <caminho absoluto de pi_scope_guard.ts>` e, no `env`, `MANDA_SCOPE_TOUCH`/`MANDA_SCOPE_FROZEN`/`MANDA_SCOPE_ROOT` (a worktree da TASK).
- Sem `touch` na TASK → não liga (compatível com TASK antiga). Chave de configuração `[routing] scope_guard = true` (padrão `true`) para desligar numa emergência.
## Interface
- Teste com `spawnFn` falso: `argv` e `env` esperados, ausência de `touch`, desligado por configuração, e que os testes antigos do runtime pi continuam verdes.
## Não fazer
- Não iniciar antes de PLAN-0029, PLAN-0032 e PLAN-0033 TASK-07 mergeados na `main` (`git -C manda log main --oneline | grep -E 'PLAN-0029|PLAN-0032|PLAN-0033'`): todos editam `src/runtime/pi.ts`.
- Não alterar `dispatch-task.sh`: o diff dele (adicionar `-e` e as variáveis na linha `pi -p`) fica como proposta no `log.md` do PLAN, aplicada por TASK do harness.
## Contexto
- `manda/src/runtime/pi.ts` (`req.env`); `.ginga/bin/dispatch-task.sh` linha do `pi:*`.

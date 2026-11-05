---
type: task
mode: mvp
goal: "Mensagens de hook e o doctor do pinga só citam o gira quando o provider de contexto é o gira"
title: Mensagens do pinga condicionais ao provider (A6)
plan: PLAN-0009-contexto-sem-gira
repo: p-inga
pinga_task: T77
depends_on: []
tier: free
touch: [src/hooks.ts, src/doctor.ts, tests/hooks_provider.test.ts]
done_when: "bun test tests/hooks_provider.test.ts tests/hooks.test.ts tests/doctor.test.ts"
tests_frozen: [tests/hooks_provider.test.ts]
---
## Fazer
- Provider: `[context].provider` do `.ginga/project.toml`, senão `gira` se estiver no PATH, senão `rg`.
- `hooks.ts:28,31`: sem gira, a dica vira "edite só o símbolo alvo" sem citar `gira write`.
- `doctor.ts:484-499`: gira ausente com provider ≠ gira → `ok` ("opcional"), não falha.
## Não fazer
- Não remover o suporte às tools `gira_context` (hooks.ts:96).
## Contexto
- `src/hooks.ts` (`GIRA_READ_ACTIONS`, `GIRA_WRITE_ACTIONS`), `src/doctor.ts`.

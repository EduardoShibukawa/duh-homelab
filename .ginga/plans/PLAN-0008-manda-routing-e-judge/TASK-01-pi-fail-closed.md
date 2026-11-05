---
type: task
mode: padrao
goal: "O adapter pi do manda não tem provider/modelo padrão: sem rota explícita ele falha fechado com mensagem clara"
title: pi.ts fail-closed (sem provider/modelo padrão)
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: []
tier: free
pinga_task: T9
touch: [src/runtime/pi.ts, tests/runtime_pi_opencode.test.ts]
done_when: "bun test tests/runtime_pi_opencode.test.ts"
tests_frozen: [tests/runtime_pi_opencode.test.ts]
---
## Fazer
- `src/runtime/pi.ts` `createPiRuntime().run`: remover os padrões `opencode-go`/`qwen3.8-flash` (l. 148-149). Sem `req.provider` e `req.model`, falhar fechado (não spawnar o `pi`) com mensagem clara citando `[runtimes]` do project.toml ou o request.
- O `pickRuntime` do run.ts já resolve a rota; o adapter só recebe provider/modelo explícitos.
## Não fazer
- Não usar `opencode-go` em lugar nenhum. Não mudar o parsing de custo/uso.
## Contexto
- `manda/src/runtime/pi.ts:148-149` (`const provider = req.provider || "opencode-go"`); INTENT-0008 (nenhum padrão implícito de provider/modelo).

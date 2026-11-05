---
type: task
mode: mvp
goal: "Corrigir o subverbo real `ginga handoff hook --runtime claude`: despachar runHook, persistir prepare/cooldown e injetar a abertura no redirect"
title: Correção da CLI do hook de handoff
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T309
depends_on: [TASK-12-handoff-hook]
tier: free
touch: [src/handoff/hook.ts, src/verbs/handoff.ts, src/verbs/registry.ts, tests/handoff_cli_hook.test.ts]
done_when: "bun test tests/handoff_cli_hook.test.ts"
tests_frozen: [tests/handoff_cli_hook.test.ts]
---
## Fazer
- Resolver `handoff hook` como verbo de duas palavras sem ampliar a enumeração pública `VERBS` (o teste congelado da CLI exige um caso para cada verbo enumerado); `hook` não pode virar o PLAN do handoff manual.
- A CLI lê o JSON do runtime no stdin e devolve somente a saída de `runHook`; não grava `HANDOFF-...-hook.md`.
- `prepare` persiste `lastHandoffTs`, `depth` e `handoffPath`; uma segunda chamada dentro do cooldown não regrava o handoff.
- `redirect` usa `openSession` por padrão e devolve `decision: block` com o id/attach da sessão aberta.
## Interface
- Teste pela CLI real: Stop com 120k em modo suggest → prepare sem estado visível antes, mas com estado persistido e cooldown; UserPromptSubmit ocioso em modo auto → sessão aberta e `decision/reason`.
## Não fazer
- Não alterar os testes congelados da TASK-12; não corrigir ainda o evento fixo de `--open` (TASK-13).
## Contexto
- Achado do judge de 2026-10-31: `ginga handoff hook` era tratado como handoff manual e `prepare` não persistia cooldown.

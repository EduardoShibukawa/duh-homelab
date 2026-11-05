---
type: task
mode: padrao
goal: "a extensão Pi barra cat .env e cat ~/.pi/agent/auth.json em tool_call, deixa cat README.md passar e redige chave em tool_result; fora de lane não registra nada"
title: Extensão Pi do guard
plan: PLAN-0033-guard-de-segredos
repo: ginga
pinga_task: T302
depends_on: [TASK-02-run-e-cli]
tier: free
touch: [contrib/guard/pi.ts, tests/guard_pi.test.ts]
done_when: "bun test tests/guard_pi.test.ts"
tests_frozen: [tests/guard_pi.test.ts]
---
## Fazer
- `export default function (pi, env = process.env)`: `if (mode(env) === "off") return;` registra `pi.on("tool_call")` → `{block:true, reason:"guard-segredos: <motivo> [<regra>]"}` ou `undefined`; e `pi.on("tool_result")` → substitui o `text` dos itens de `content` (e zera `structuredContent` se mudou algo) ou `undefined`.
- Carregado por execução com `pi -e <repo>/contrib/guard/pi.ts` (TASK-06). Nada em `~/.pi`.
## Interface
- Protótipo: [ref/ginga/contrib/guard/pi.ts](../ref/ginga/contrib/guard/pi.ts). Eventos: `event.toolName`, `event.input` (docs do Pi, `extensions.md`, exemplos `protected-paths.ts` e `permission-gate.ts`).
## Não fazer
- Não tocar tests_frozen. Não importar do pi-harness. Não deixar o `reason` carregar o trecho que casou.
## Contexto
- Rode a conferência do formato do `tool_result` em `types.ts` do Pi (1.4.0) se o teste de `content` divergir; a doc só garante `content`/`structuredContent`.
- O PLAN-0032 também registra `tool_call` por `-e`; os dois podem coexistir (qualquer `block` vence).

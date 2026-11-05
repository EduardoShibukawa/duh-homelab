---
type: task
mode: mvp
goal: "web/inbox.js liga os botões do Inbox a /v1/verbs/<slug> e atualiza o contador [data-count] por SSE (/v1/events)"
title: Inbox ligado aos verbos e ao SSE (follow-up do judge)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-03-inbox]
tier: free
touch: [web/inbox.js, tests/web_inbox_js.test.ts]
done_when: "bun test tests/web_inbox_js.test.ts"
tests_frozen: [tests/web_inbox_js.test.ts]
pinga_task: T330
---
## Fazer (follow-up do judge 2026-11-01 — TASK-03 reprovada: web/inbox.js não existe)
- `web/inbox.js` (módulo JS sem build, mesmo padrão de `web/board.js`):
  - `inboxVerbRequest(button)` → `{ verb, path: "/v1/verbs/<slug>", body: { id } }`, slug = verbo com espaço → `-` (ex.: `"budget raise"` → `/v1/verbs/budget-raise`);
  - `invokeInboxVerb(button, fetcher = fetch)` → POST JSON (`content-type: application/json`) no path, devolve o JSON da resposta;
  - `refreshInboxCount(counterEl, fetcher = fetch)` → POST `/v1/verbs/inbox` com `{}` e grava `data-count` + `textContent` com `items.length`;
  - `connectInboxSse(counterEl, source = new EventSource("/v1/events"), fetcher = fetch)` → no evento `message` chama `refreshInboxCount`.
- Auto-init no `DOMContentLoaded` quando houver `[data-inbox]` (padrão do board.js).
## Interface
- O teste frozen (tests/web_inbox_js.test.ts) importa o módulo real e exercita as quatro funções com fakes (botão, contador, EventSource, fetch).
## Não fazer
- Não tocar na casca (TASK-12/T329), em src/ nem nos testes frozen antigos.

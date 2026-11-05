---
type: task
mode: mvp
goal: "ginga serve entrega a casca da Roda Web em / com navegação Inbox, Quadro e PLAN, responsiva"
title: Casca da Roda Web
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-01-board-model]
tier: free
touch: [web/index.html, web/app.js, web/style.css, src/api/server.ts, tests/web_shell.test.ts]
done_when: "bun test tests/web_shell.test.ts"
tests_frozen: [tests/web_shell.test.ts]
pinga_task: T159
---
## Fazer
- `GET /` serve `web/index.html` (com auth do PLAN-0011); `app.js` assina `/v1/events` e chama `/v1/verbs/*`.
- Sidebar no desktop, abas embaixo abaixo de 640px; tema claro/escuro.
## Interface
- `GET /` → 200 `text/html` com `<nav data-view="inbox|board|plan">`; `GET /app.js`, `/style.css` → 200. Sem token → 401 (auth do PLAN-0011). Teste com `serve` em porta efêmera.
## Não fazer
- Sem framework nem build; sem lógica de negócio no JS.
## Contexto
- `p-inga/web/index.html`; protótipo `knowledge/design/ginga-revamp/prototipos/Main.dc.html`.

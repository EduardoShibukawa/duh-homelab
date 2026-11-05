---
type: task
mode: mvp
goal: "A casca real da Roda Web em web/ (index.html, app.js, style.css) entrega nav Inbox/Quadro/PLAN, sidebar no desktop e abas abaixo de 640px, tema claro/escuro e SSE"
title: Casca real da Roda Web (follow-up do judge)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-02-web-shell]
tier: free
touch: [web/index.html, web/app.js, web/style.css, tests/web_shell_casca.test.ts]
done_when: "bun test tests/web_shell_casca.test.ts"
tests_frozen: [tests/web_shell_casca.test.ts]
pinga_task: T329
---
## Fazer (follow-up do judge 2026-11-01, gate exit 11 — TASK-02 reprovada: arquivos com 1 byte)
- `web/index.html` real: `<nav data-view="inbox|board|plan">`, seções `data-view="inbox"|"board"|"plan"`, `<script src="/app.js">` + os módulos das telas (`/inbox.js`, `/board.js`, `/plan.js`, `/alerts.js`) e `<link href="/style.css">`.
- `web/app.js`: `EventSource` em `/v1/events`, chamadas a `/v1/verbs/`, troca de view pelos `data-view` (sidebar/abas), toggle de tema com `data-theme`.
- `web/style.css`: sidebar no desktop, `@media … 640px` com abas embaixo, variáveis de tema claro/escuro (`data-theme="dark"`).
## Interface
- O teste frozen (tests/web_shell_casca.test.ts) lê os arquivos REAIS de web/ e exige os marcadores acima. O fallback do `serve` já entrega web/ em `GET /` — não precisa mexer em src/.
## Não fazer
- Sem framework/build; sem lógica de negócio no JS; não tocar em src/, em web/inbox.js (TASK-13) nem nos testes frozen antigos.

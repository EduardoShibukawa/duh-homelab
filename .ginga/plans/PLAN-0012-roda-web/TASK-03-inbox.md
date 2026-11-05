---
type: task
mode: mvp
goal: "A tela Inbox lista as pendências do dono com o botão da resposta mais provável e Responder livre, chamando verbos"
title: Tela Inbox
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-02-web-shell]
tier: free
touch: [src/web/render/inbox.ts, web/inbox.js, tests/web_inbox.test.ts]
done_when: "bun test tests/web_inbox.test.ts"
tests_frozen: [tests/web_inbox.test.ts]
pinga_task: T325
---
## Fazer
- Cards BLOCKER / APROVAR / BUDGET / DECIDIR conforme doc 05 §3.1; cada botão → `approve`, `reject`, `answer`, `budget raise`, `decide`.
- Contador de pendências no topo; atualiza por SSE.
## Interface
- `renderInbox(items: InboxItem[]): string` (pura) em `src/web/render/inbox.ts`; cada botão tem `data-verb="approve|reject|answer|budget raise|decide"` e `data-id`. Teste: 1 item de cada tipo → botões e contador `data-count`.
## Não fazer
- Não tocar em quadro/PLAN (TASK-04/05).
## Contexto
- `src/board.ts` (Inbox), protótipo `Main.dc.html` (Inbox).

---
type: task
mode: padrao
goal: "Fallback do serve entrega o web/ da instalação do ginga quando o --root não tem web/ — num workspace real GET / mostra a Roda Web e /app.js não dá 404"
title: Fallback do serve lê o web/ da instalação (follow-up do judge na TASK-02)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-02-web-shell]
tier: free
touch: [src/serve.ts, tests/web_shell_install.test.ts]
done_when: "bun test tests/web_shell_install.test.ts tests/web_shell.test.ts tests/web_shell_casca.test.ts"
tests_frozen: [tests/web_shell_install.test.ts]
pinga_task: T336
---
## Context
- Judge 2026-11-02 (merge-gate plan/0012 exit 11, achado na TASK-02 / AC-roda-web-inbox-quadro-plan): o fallback lia só `join(base, "web")` (src/serve.ts:305), onde base é o --root/cwd; num workspace real (ex. duh-homelab/) `GET /` devolvia só "ginga serve" e `/app.js` 404. O `tests/web_shell.test.ts:28-31` mascarava o bug criando `web/` dentro do root temporário (frozen da T159 — NÃO alterar).
## Interface
- `webDir = existsSync(join(base, "web")) ? join(base, "web") : join(import.meta.dir, "..", "web")` — override do workspace primeiro; senão o `web/` da instalação do ginga (ao lado de `src/serve.ts`). Resto do fallback inalterado: arquivo ausente → 404; `"ginga serve\n"` só se nenhum dos dois `web/` existir.
- RED novo (tests/web_shell_install.test.ts, já commitado como `test(T336): RED`): root temporário SEM `web/` → `GET /` 200 text/html com o index.html da instalação (`nav data-view="inbox|board|plan"` + `<title>Roda`), `/app.js` e `/style.css` 200, `/nao-existe.js` 404; root COM `web/` próprio → o override do workspace continua valendo.
## Não fazer
- Não alterar `tests/web_shell.test.ts` nem nenhum outro frozen; não mudar auth/API; mudança cirúrgica só no fallback de src/serve.ts.

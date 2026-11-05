---
type: task
mode: mvp
goal: "README do ginga traz a instrução de ativar a statusline do Claude (seção que aponta `contrib/claude-statusline.sh` e `~/.claude/settings.json`); o ginga não edita o settings.json — ativar é ação do dono"
title: Instrução da statusline do Claude no README
description: "Ressalva simples do judge 2026-11-03T02:50 (veredito pass, TASK-03 ok:false simples): falta a instrução no README"
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-03-quota-claude]
tier: free
pinga_task: T363
touch: [README.md, tests/readme_statusline.test.ts]
done_when: "bun test tests/readme_statusline.test.ts"
tests_frozen: [tests/readme_statusline.test.ts]
---
## Fazer
- Achado do judge 2026-11-03T02:50 (ressalva simples da TASK-03): o PLAN promete "a TASK-03 só entrega o script e a instrução; ativar é ação do dono" e a TASK-03 diz "instrução no README para o dono", mas `grep -i statusline README.md` é vazio.
- Adicione uma seção ao `README.md` do ginga (ex.: `## Statusline do Claude (quota)`) dizendo ao dono para registrar em `~/.claude/settings.json` algo como `"statusLine": { "type": "command", "command": "<caminho do repo>/contrib/claude-statusline.sh" }`, e que o ginga **não** edita esse arquivo — ativar é ação do dono.
- A seção deve citar `contrib/claude-statusline.sh` e `~/.claude/settings.json`.
## RED
- `tests/readme_statusline.test.ts` lê o `README.md` REAL do repo e falha sem a seção (hoje falha: sem `statusline`, sem `claude-statusline.sh`, sem `settings.json`).

# Rodada 4 — operador (ginga)

## T158 (PLAN-0012 TASK-01) — fix judge
- receipt: seq 853 status pass (`pinga verify tasks/T158/PLAN.md`)
- bun test tests/board.test.ts tests/verbs.test.ts: pass (21 pass, 0 fail)
- mudanças: src/board.ts (blockers, budget cap, decidir, promover), tests/verbs.test.ts (colunas Card)

## T159 (PLAN-0012 TASK-02) — casca Roda Web
- receipt: seq 857 status pass (`pinga verify tasks/T159/PLAN.md --base c431d73...`)
- bun test tests/web_shell.test.ts: pass (2 pass, 0 fail)
- mudanças: src/serve.ts (fallback estático), web/index.html, web/app.js, web/style.css

## Suíte
- bun test (worktree ginga-plan-0012): 461 pass, 0 fail

## Ready
- .ginga/plans/PLAN-0012-roda-web/ready/ginga.json removido (stale); TASK-03..09 pendentes.

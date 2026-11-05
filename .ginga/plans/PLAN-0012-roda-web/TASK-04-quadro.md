---
type: task
mode: mvp
goal: "A tela Quadro mostra o kanban INTENT → FEITO com marcas de blocker, aprovação e execução e filtros por repo e trilha"
title: Tela Quadro
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-02-web-shell]
tier: free
touch: [src/web/render/board.ts, web/board.js, tests/web_board.test.ts]
done_when: "bun test tests/web_board.test.ts"
tests_frozen: [tests/web_board.test.ts]
pinga_task: T326
---
## Fazer
- Colunas e cartões do `src/board.ts`; ⚑ blocker, ✓? aguardando aprovação, ⟳ rodando, progresso `n/m` TASKs.
- Filtros `repo` e `trilha` (pequena/feature) na URL.
## Interface
- `renderBoard(b: Board, f?: { repo?: string; track?: string }): string` (pura); marcas `⚑`, `✓?`, `⟳` e `n/m`. Teste: filtro por repo esconde o card de outro repo.
## Não fazer
- Nenhuma ação além de abrir o PLAN.
## Contexto
- Doc 05 §3.2; protótipo `Main.dc.html` (Quadro).

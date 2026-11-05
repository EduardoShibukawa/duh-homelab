---
type: task
mode: padrao
goal: "Um modelo único deriva as colunas do quadro e os itens do Inbox a partir do bundle, do state.db e dos receipts"
title: Modelo do quadro + board/inbox
plan: PLAN-0012-roda-web
repo: ginga
depends_on: []
tier: medium
touch: [src/board.ts, src/verbs/read.ts, tests/board.test.ts, tests/fixtures/board/]
done_when: "bun test tests/board.test.ts"
tests_frozen: [tests/board.test.ts, tests/fixtures/board/]
pinga_task: T158
---
## Fazer
- Colunas: INTENT, SPEC, PLAN, EXECUTANDO, VERIFICANDO, FEITO (receipt `pass` do PLAN + VERDICT ok).
- Inbox: SPEC/PLAN `draft` aguardando aprovação, blockers abertos, `budget` cap, decisões (`decide`), learnings a promover.
- `ginga board --json` e `ginga inbox --json` passam a usar este modelo.
## Interface
- `deriveBoard(root, db): Board` em `src/board.ts` (tipos no PLAN.md, "Interfaces"); `read.board`/`read.inbox` devolvem `deriveBoard(...).columns`/`.inbox`. Teste: fixture `tests/fixtures/board/` com 1 INTENT, 1 SPEC draft, 1 PLAN approved com 2 TASKs (1 receipt pass) → colunas e inbox exatos.
## Não fazer
- Não gravar nada; só leitura.
## Contexto
- Doc 05 §3.1–3.3; `pinga queue --json` (PLAN-0005); `src/state/db.ts`.

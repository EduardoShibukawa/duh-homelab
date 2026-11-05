---
type: task
mode: padrao
goal: "ginga index gera o index.md do bundle a partir do modelo do quadro, preservando as seções de texto livre"
title: ginga index gera o index.md
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-01-board-model]
tier: medium
touch: [src/index_md.ts, src/verbs/read.ts, src/serve.ts, tests/index_md.test.ts, tests/fixtures/index/]
done_when: "bun test tests/index_md.test.ts"
tests_frozen: [tests/index_md.test.ts, tests/fixtures/index/]
---
## Fazer
- Seções geradas: Pronto para pegar, Esperando o dono, Em andamento, Concluído, Backlog (INTENTs sem PLAN). Frontmatter `okf: "0.1"` e a linha `> gerado por ginga`.
- Texto livre vem de `.ginga/index.template.md` (blocos `<!-- ginga:board -->` etc.).
- `serve` regenera em cada `transition`; `ginga index --check` → exit 1 se desatualizado.
## Interface
- `renderIndex(b: Board, template: string, now: Date): string` (pura) e `writeIndex(root, db): { changed: boolean }`; verbo `index` com `check` (exit 1 se desatualizado). Teste: mesma entrada → mesmos bytes; segunda escrita → `changed: false`.
## Não fazer
- Não gravar se nada mudou (sem diff ruidoso).
## Contexto
- `.ginga/index.md` atual do workspace como fixture de referência.

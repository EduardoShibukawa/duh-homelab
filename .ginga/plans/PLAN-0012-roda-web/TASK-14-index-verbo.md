---
type: task
mode: padrao
goal: "Verbo `index` registrado na CLI com `--check` (exit 1 se desatualizado) e o serve regenera .ginga/index.md a cada tick/transition"
title: Verbo index ligado (follow-up do judge na TASK-06)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-06-index-gerado]
tier: free
touch: [src/verbs/registry.ts, src/verbs/index.ts, src/index_md.ts, src/serve.ts, tests/index_cli.test.ts, tests/fixtures/index/, tests/cli_verbs.test.ts]
done_when: "bun test tests/index_cli.test.ts"
tests_frozen: [tests/index_cli.test.ts, tests/fixtures/index/template.md]
pinga_task: T331
---

## Context
- Follow-up do judge 2026-11-01T210947 (gate exit 11): `src/index_md.ts` tem
  renderIndex/writeIndex/checkIndex, mas o verbo `index` não está no registro
  (`bun bin/ginga.ts index` -> "comando desconhecido"), sem `--check`/exit 1,
  o serve não regenera em transition e falta `tests/fixtures/index/`.
  A CLI é gerada do registro (PLAN-0011 TASK-02): basta registrar o verbo.
- `ctx.root` nos verbos é o bundle (`<ws>/.ginga`); `writeIndex`/`checkIndex`
  esperam a raiz do workspace — derivar com `basename(root) === ".ginga"`.
- No serve, regenerar em `makeTickRunner` após o `runWatch` (o watcher de
  $GINGA_EVENTS acorda o tick a cada evento, inclusive `transition`).

## Interface
- `getVerb("index")` definido com arg bool `check`.
- `runVerb("index", ctx, {})` grava `<ws>/.ginga/index.md` com `> gerado por
  ginga` e frontmatter `okf: "0.1"`; segunda chamada retorna `changed: false`.
- `runVerb("index", ctx, { check: "true" })` com index.md desatualizado **lança**
  erro (CLI sai 1); com ele atualizado retorna `{ ok: true }`.
- E2E: serve com `GINGA_EVENTS` Append de um evento `transition` ->
  `.ginga/index.md` aparece com `> gerado por ginga`.

## Não fazer
- Não tocar em `tests/index_md.test.ts` (frozen da T160, done). Não gravar
  index.md se o conteúdo for idêntico (writeIndex já faz isso).

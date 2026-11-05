---
type: task
mode: padrao
goal: "ginga lint lê o bundle .ginga e valida o frontmatter obrigatório de cada tipo"
title: Leitor do bundle + lint de frontmatter
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T4
depends_on: [TASK-03-eventos-migrar]
tier: medium
touch: [src/bundle/read.ts, src/lint/frontmatter.ts, src/lint/index.ts, src/cli.ts, tests/lint_frontmatter.test.ts, tests/fixtures/bundle-ok/, tests/fixtures/bundle-bad/]
done_when: "bun test tests/lint_frontmatter.test.ts"
tests_frozen: [tests/lint_frontmatter.test.ts, tests/fixtures/bundle-ok/, tests/fixtures/bundle-bad/]
---
## Fazer
- `ginga lint [dir] [--json]`: exit 0 sem erros, 1 com erros (lista `arquivo: campo: mensagem`).
- Obrigatórios: intent `title,source,timestamp`; spec `title,intent,status,bench`; plan `title,intent,status`; task `mode,goal,done_when,touch,plan`.
- `status` e `kind` só com os valores do doc 04; `mode` aceita os do pinga (`mvp|padrao|completo`).
## Não fazer
- Relações e DAG ficam para a TASK-06.
## Contexto
- `.ginga/knowledge/design/ginga-revamp/04-artefatos.md` §5; parser YAML: `Bun.YAML.parse` (como `p-inga/src/plan.ts`).

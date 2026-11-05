---
type: task
mode: mvp
goal: "ginga lint --export okf <saida> gera uma cópia OKF v0.1 do bundle"
title: Export OKF v0.1
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T6
depends_on: [TASK-06-lint-relacoes]
tier: free
touch: [src/lint/okf.ts, src/cli.ts, tests/lint_okf.test.ts]
done_when: "bun test tests/lint_okf.test.ts"
tests_frozen: [tests/lint_okf.test.ts]
---
## Fazer
- Só exporta se o lint passar. Na saída: `type` em todo `.md`, `index.md` raiz com `okf: "0.1"`, relações do frontmatter também como links markdown.
- Usa o fixture `tests/fixtures/bundle-ok/` da TASK-05.
## Não fazer
- Não depender de ferramenta do OKF; não alterar o bundle de origem.
## Contexto
- Doc 04 §5 ("OKF como compatibilidade, não como fundação").

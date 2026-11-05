---
type: task
mode: mvp
goal: "ginga lint valida o formato do LEARNINGS.md e aceita kind: change | investigation no PLAN"
title: LEARNINGS.md e kind no lint
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T141
depends_on: []
tier: free
touch: [src/lint/learnings.ts, src/lint/frontmatter.ts, src/lint/index.ts, tests/lint_learnings.test.ts]
done_when: "bun test tests/lint_learnings.test.ts"
tests_frozen: [tests/lint_learnings.test.ts]
---
## Fazer
- Entrada `## L-NN · <confirmada|descartada|fato|armadilha> · AAAA-MM-DD HH:MM` com `hipótese`, `evidência`, `conclusão`, `escopo`.
- PLAN `approved` sem `LEARNINGS.md` → aviso; `kind` fora de `change|investigation` → erro.
## Interface
- `lintLearnings(path: string): LintIssue[]` em `src/lint/learnings.ts`, chamado pelo `ginga lint`. Teste: fixture válida → 0 issues; sem `evidência` → 1 erro; status fora da lista → 1 erro.
## Não fazer
- Não exigir learnings em PLAN `draft`.
## Contexto
- Doc 06 §2 ("Formato de um learning"), doc 04 §1.

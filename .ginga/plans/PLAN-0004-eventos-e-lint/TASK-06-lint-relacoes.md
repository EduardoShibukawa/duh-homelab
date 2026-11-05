---
type: task
mode: padrao
goal: "ginga lint valida relações, numeração única, PLAN com TASK, DAG sem ciclo e touch disjunto entre TASKs paralelas"
title: Lint de relações e DAG
plan: PLAN-0004-eventos-e-lint
repo: ginga
pinga_task: T5
depends_on: [TASK-05-lint-frontmatter]
tier: medium
touch: [src/lint/relations.ts, src/lint/dag.ts, src/lint/index.ts, tests/lint_relations.test.ts]
done_when: "bun test tests/lint_relations.test.ts"
tests_frozen: [tests/lint_relations.test.ts]
---
## Fazer
- `intent`, `spec`, `plan`, `depends_on` apontam para artefatos existentes; `TASK.plan` é a pasta onde ela está; PLAN com ≥ 1 TASK.
- Numeração: IDs únicos e sequenciais por tipo (sem regra de herança; ver doc 04 §IDs).
- `depends_on` sem ciclo; TASKs sem caminho entre si no DAG não podem ter `touch` em comum (prefixo de pasta conta).
## Não fazer
- Não chamar LLM. Não importar do pi-harness: portar a lógica.
## Contexto
- `pi-harness/src/intent/decomposition_linter.ts` (`lintTaskDecomposition`, l. 203).

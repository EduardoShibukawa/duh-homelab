---
type: task
mode: padrao
goal: "manda plan show <PLAN> --json lê PLAN.md e TASK-*.md e devolve as TASKs em ordem topológica"
title: Leitor de PLAN/TASK + ordem do DAG
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T2
depends_on: [TASK-01-manda-repo]
tier: free
touch: [src/bundle.ts, src/project.ts, src/cli.ts, tests/bundle.test.ts, tests/fixtures/plan-basic/]
done_when: "bun test tests/bundle.test.ts"
tests_frozen: [tests/bundle.test.ts, tests/fixtures/plan-basic/]
---
## Fazer
- Frontmatter com `Bun.YAML.parse`; campos da TASK do doc 04 + `repo`.
- Ordem topológica por `depends_on`; ciclo → exit 1 com o ciclo.
- `src/project.ts`: lê `.ginga/project.toml` com `Bun.TOML.parse` (`[commands]`, `[runtimes]`, `[context]`); ausente = padrões.
## Não fazer
- Não validar o bundle inteiro (isso é o `ginga lint`).
## Contexto
- Doc 04 §5 (frontmatter); doc 02 §2 ("Contrato por projeto").

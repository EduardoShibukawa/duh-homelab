---
type: task
mode: padrao
goal: "ginga handoff [<PLAN>] gera o mesmo arquivo para a mesma entrada, sem chamar LLM, e emite o evento handoff"
title: ginga handoff
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T142
depends_on: [TASK-01-log-automatico, TASK-02-learnings-lint]
tier: medium
touch: [src/handoff.ts, src/verbs/handoff.ts, src/verbs/registry.ts, tests/handoff.test.ts, tests/fixtures/handoff/]
done_when: "bun test tests/handoff.test.ts"
tests_frozen: [tests/handoff.test.ts, tests/fixtures/handoff/]
---
## Fazer
- Ordem: objetivo do PLAN (+ SPEC), TASKs com estado e última tentativa, learnings (`descartada`/`armadilha` primeiro), próxima TASK aberta, `git status --short` + `git diff --stat` dos `repos`, blockers abertos.
- Arquivo `.ginga/handoffs/HANDOFF-<data>-<PLAN>.md` (`type: handoff`); evento `handoff` com `trigger: boundary` e `handoff_tokens` estimado (chars/4).
- Teste: relógio fixo → bytes idênticos; spy garante zero spawn além de `git`/`pinga`.
## Interface
- `buildHandoff(root, {plan, now, git})` (PLAN.md). Sem `plan`: cobre os PLANs `approved` não concluídos. `HANDOFF_VERBS` em `src/verbs/handoff.ts`, registrado em `registry.ts` com `...HANDOFF_VERBS` (as TASKs 10/11 só tocam `src/verbs/handoff.ts`).
## Não fazer
- Sem gatilho automático (TASK-10).
## Contexto
- Doc 06 §4 (o formato é o desta TASK; não depende do pi-harness).

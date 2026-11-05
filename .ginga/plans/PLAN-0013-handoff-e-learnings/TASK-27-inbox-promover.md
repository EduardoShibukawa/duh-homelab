---
type: task
mode: mvp
goal: "inbox() traz o item 'promover?' quando o PLAN fecha (status done) e há learnings ainda não promovidos no LEARNINGS.md dele — corrige o achado do judge 2026-11-01 na TASK-05 (src/verbs/read.ts:77 só lista aprovar e blocker)"
title: Inbox "promover?" ao fechar o PLAN
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T317
depends_on: [TASK-05-learning-promote]
tier: free
touch: [src/verbs/read.ts, src/lessons.ts, tests/inbox_promover.test.ts]
done_when: "bun test tests/inbox_promover.test.ts tests/verbs.test.ts"
tests_frozen: [tests/inbox_promover.test.ts]
---
## Fazer
- `listBundle` (src/verbs/read.ts) passa a devolver também o caminho do PLAN.md de cada artefato (campo interno `file`; não muda a saída de status/board).
- Em `inbox()`, para cada artefato `kind === "plan"` com `status === "done"`: ler o `LEARNINGS.md` do diretório do PLAN e, se houver learnings sem `· promovida`, empurrar `{ id: planId, type: "promover?", plan: planId, pending: ["L-02", ...] }` (só os ids pendentes, na ordem do arquivo).
- Exportar `listLearnings(planDir: string): LearningEntry[]` em `src/lessons.ts` (wrapper de `parseLearnings(readSafe(join(planDir, "LEARNINGS.md")))`; exportar o tipo `LearningEntry` também). Sem LEARNINGS.md → sem item.
- PLAN não `done` ou tudo promovido → sem item. Itens `aprovar` e `blocker` intactos.
## Interface
- Teste congelado `tests/inbox_promover.test.ts` (já escrito, RED): PLAN done com L-02 pendente → item `promover?` com `pending: ["L-02"]`; tudo promovido → sem item; PLAN approved → sem item; aprovar continua listando junto.
- `tests/verbs.test.ts` (frozen) segue verde.
## Não fazer
- Não promover sozinho; não mudar os outros verbos de leitura; sem scripts de depuração fora do touch (use /tmp).
## Contexto
- Judge 2026-11-01 (TASK-05): "Item de Inbox 'promover?' quando o PLAN fecha" não existe — `inbox()` em `src/verbs/read.ts:77` só lista aprovar e blocker. TASK-05 Fazer pedia esse item.

---
type: task
mode: mvp
goal: "ginga learning promote <PLAN>#L-NN cria knowledge/lessons/LESSON-NNNN-slug.md com escopo e evidência"
title: learning promote → LESSON
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T146
depends_on: [TASK-03-handoff]
tier: free
touch: [src/lessons.ts, src/verbs/learning.ts, src/verbs/registry.ts, tests/learning_promote.test.ts]
done_when: "bun test tests/learning_promote.test.ts"
tests_frozen: [tests/learning_promote.test.ts]
---
## Fazer
- Frontmatter `type: lesson`, `scope: {repo, files, symbols, tags}`, `evidence` (receipt ou commit), `from: PLAN#L-NN`.
- Marca o learning como promovido (`· promovida`) e emite `learning` com `promoted: true`. Item de Inbox "promover?" quando o PLAN fecha.
## Interface
- `promote(root, ref): Lesson` (PLAN.md); `LEARNING_VERBS` em `src/verbs/learning.ts`, registrado com `...LEARNING_VERBS`. Teste: PLAN de fixture com L-02 → `LESSON-0001-<slug>.md` com `from: PLAN-0099#L-02` e o learning marcado `· promovida`.
## Não fazer
- Não promover sozinho (só pelo verbo).
## Contexto
- Doc 06 §5; `p-inga/src/lessons.ts` (`promoteCmd` l. 429) como referência.

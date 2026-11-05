---
type: task
mode: padrao
goal: "Cobertura do verbo handoff no cli_verbs (caso no CASES) e retorno do verbo determinístico entre fixtures idênticos (path relativo ao root), sem quebrar os frozen do T142/T143"
title: cli_verbs cobre o verbo handoff (colateral do T142)
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T144
depends_on: [TASK-16-handoff-completo]
tier: light
touch: [src/verbs/handoff.ts, tests/cli_verbs.test.ts, tasks/T144/PLAN.md]
done_when: "bun test tests/cli_verbs.test.ts tests/handoff.test.ts tests/handoff_full.test.ts"
tests_frozen: [tests/cli_verbs.test.ts]
---
## Fazer
- O T142 registrou `handoff` em `registry.ts` sem caso no `CASES` de `tests/cli_verbs.test.ts` (frozen T121 — alterado só por TASK nova; precedente T131/T128): 2 falhas novas vs main no `bun test` completo. O commit RED desta TASK já traz o caso:
  `handoff: { argv: ["handoff", "PLAN-0001"], args: { plan: "PLAN-0001" } }`.
- A comparação CLI × run direto usa fixtures gêmeos em dirs temporários diferentes: o retorno do verbo precisa ser idêntico nos dois. Devolver `path` relativo ao `ctx.root` (ex.: `handoffs/HANDOFF-<data>-PLAN-0001.md`) em vez do absoluto; `data.file` do evento continua absoluto. `markdown`/`tokens` já são idênticos (git real cai para "" fora de repo git nos dois lados; a fila degrada igual).
- RED: `bun test tests/cli_verbs.test.ts` falha no base (2 fail: cobertura + comparação handoff).

## Não fazer
- Não mudar a lógica de comparação do cli_verbs nem os frozen do T142 (tests/handoff.test.ts) e do T143 (tests/handoff_full.test.ts); não adicionar outros verbos.

## Contexto
- Achado ao rodar a suíte completa após o verify pass do T143: 487 pass / 2 fail, ambos em tests/cli_verbs.test.ts e presentes já no HEAD 0a8e10e (T142), ou seja, falha nova vs main que o gate vai barrar.

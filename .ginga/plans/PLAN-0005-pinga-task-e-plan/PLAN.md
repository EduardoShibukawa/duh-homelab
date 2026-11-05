---
type: plan
title: pinga verifica TASK-*.md e PLAN.md
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
repos: [p-inga]
depends_on: [PLAN-0004-eventos-e-lint]
done_when: "cd p-inga && bun test"
---
## Objetivo

O pinga passa a verificar o formato novo (`.ginga/plans/PLAN-*/TASK-*.md` e o `PLAN.md` de integração) sem quebrar o legado `tasks/T<N>/PLAN.md`, e emite `receipt` em `$GINGA_EVENTS`. Este é o "PLAN de migração" citado no CLAUDE.md: depois dele os repos irmãos podem usar TASKs do bundle direto.

## Abordagem

- Hoje o id da task é `basename(dirname(path))` em 6 lugares (`verify.ts:97`, `prove.ts:373`, `supersede.ts:61`, `mode.ts:219`, `examples.ts:314`, `maestro.ts:149`). Para `TASK-*.md` isso daria o nome do PLAN para todas as TASKs. Um resolvedor único (`src/task_ref.ts`, a criar) devolve `T61` no legado e `PLAN-0005/TASK-02` no formato novo.
- Os sidecars (`.baseline.json`, `EXEC.md`, `EVAL.md`) saem de `tasks/<id>/` para uma pasta derivada do ref.
- `--root <repo>`: a TASK pode morar no bundle do workspace (fora do git do repo-alvo), e o `done_when` roda na raiz do repo indicado.
- Verificação de PLAN: todas as TASKs da pasta com receipt `pass`, depois o `done_when` do PLAN. `kind: investigation` usa o mesmo caminho.
- Mantém o limite de 25 linhas para TASK (o `parsePlan` já impõe); o PLAN de integração não tem esse limite.
- **Execução:** TASKs materializadas como `tasks/T<N>/PLAN.md` no p-inga (este PLAN ainda não está pronto para verificar a si mesmo); `tests_frozen` escritos pelo Planner antes do despacho.

## TASKs

1. [TASK-01](TASK-01-schema-task.md): campos opcionais da TASK no `parsePlan`
2. [TASK-02](TASK-02-task-ref.md): `task_ref.ts` + `verify`/`prove-red`
3. [TASK-03](TASK-03-task-ref-resto.md): demais comandos e sidecars
4. [TASK-04](TASK-04-root-flag.md): `--root <repo>`
5. [TASK-05](TASK-05-plan-verify.md): `pinga verify <PLAN.md>` de integração (inclui `kind: investigation`)
6. [TASK-06](TASK-06-queue-bundle.md): `pinga queue` enxerga o bundle
7. [TASK-07](TASK-07-receipt-events.md): `receipt` em `$GINGA_EVENTS`

## ACs da SPEC cobertos

- O pinga verifica `TASK-*.md` e `PLAN.md` (a parte "não referencia o pi-harness" fecha no PLAN-0006).
- Cada ferramenta emite em `$GINGA_EVENTS` (pinga). `kind: investigation` funciona com o mesmo verify.

## Riscos

- `verify.ts` e `cli.ts` são grandes (561 e 1671 linhas): edições cirúrgicas, TASKs em série onde tocam o mesmo arquivo.
- Mudar o id pode partir a correlação de receipts antigos: o legado `tasks/T<N>` tem de continuar devolvendo exatamente `T<N>` (teste de regressão).
- O SPEC pede `mode` mvp|full; o pinga aceita `mvp|padrao|completo`. As TASKs usam `mvp`/`padrao`.

---
type: plan
title: Schema de eventos v1 + ginga lint do bundle
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
repos: [ginga, pi-harness]
depends_on: []
done_when: "cd ginga && bun test && cd ../pi-harness && bun test tests/unit/harness_events_v1.test.ts"
---
## Objetivo

Criar o repo `ginga/` (a criar) com as duas primeiras peças usáveis sozinhas: o contrato de eventos do [07](../../knowledge/design/ginga-revamp/07-eventos.md) (emitir, validar, migrar) e o `ginga lint` do bundle `.ginga/`, com export OKF v0.1.

## Abordagem

- O ginga nasce como repo Bun/TS irmão (`ginga/`), com `git init` na TASK-01 e governado pelo pinga (`tasks/T<N>/`) desde o primeiro commit.
- Eventos são spec em documento: o ginga e o pi-harness implementam o emissor cada um por conta própria (sem lib compartilhada).
- O lint porta a lógica de `pi-harness/src/intent/decomposition_linter.ts` (`lintTaskDecomposition`), por cópia e não por import.
- **Execução:** o `done_when` de cada TASK roda na raiz do `repo:`. Até o PLAN-0005 fechar, a TASK é materializada como `tasks/T<N>/PLAN.md` no repo (cabe nas 25 linhas) e passa por `prove-red` → `verify`. Os `tests_frozen` são escritos pelo Planner (RED) antes do despacho.

## TASKs

1. [TASK-01](TASK-01-ginga-repo.md): repo `ginga/` + CLI mínima
2. [TASK-02](TASK-02-eventos-schema.md): schema v1, emissor e `ginga events validate`
3. [TASK-03](TASK-03-eventos-migrar.md): `ginga events migrate` do `events.jsonl` do pi-harness
4. [TASK-04](TASK-04-pi-harness-emite-v1.md): o pi-harness passa a emitir v1 em `$GINGA_EVENTS`
5. [TASK-05](TASK-05-lint-frontmatter.md): leitor do bundle + lint de frontmatter
6. [TASK-06](TASK-06-lint-relacoes.md): relações, numeração única, DAG e `touch` paralelo
7. [TASK-07](TASK-07-export-okf.md): `ginga lint --export okf`

## ACs da SPEC cobertos

- Eventos seguem o schema de 07 (envelope `v:1`) e o `events.jsonl` do pi-harness é migrado.
- `ginga lint` valida o bundle e exporta para OKF v0.1.
- Parte de "cada ferramenta emite em `$GINGA_EVENTS` e funciona sem ele" (ginga e pi-harness).

## Riscos

- ~~Numeração herdada~~: resolvido; o doc 04 passou a usar numeração sequencial própria.
- O `kind: verify` do pi-harness não existe no 07; a TASK-03 propõe mapeá-lo para `receipt` com `check: bdd`.
- `state/events.jsonl` não é rastreado no git do pi-harness: a migração precisa de backup antes.

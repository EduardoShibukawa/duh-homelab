---
type: task
mode: padrao
goal: "cada achado do judge é classificado como novo, repetido ou regressão contra as rodadas anteriores, com regra por ref+evidência e Jev no texto que mudou"
title: Novo × repetido × regressão no judge
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: [TASK-03-camada-hibrida]
tier: medium
touch: [src/judge_novelty.ts, tests/judge_novelty.test.ts]
done_when: "bun test tests/judge_novelty.test.ts"
tests_frozen: [tests/judge_novelty.test.ts]
---
## Fazer
- Regra: mesmo `ref` e `evidence` normalizada → `repetido`; `regression: true` do judge → `regressao`; `ref` nunca visto → `novo`. Mesmo `ref` com evidência reescrita → pergunta ao Jev (`finding_novelty`), com o achado e os anteriores mascarados.
- Alimenta a regra `judge_no_regression` (SPEC-0003: rodada > 2 sem regressão → merge + follow-up) com a contagem de `novo` e `repetido`.
## Interface
- `classifyFinding(previous, finding, ctx): Labeled`. Teste: as três classes pela regra; reescrita → Jev; Jev fora → `novo` (conservador: não esconde achado).
## Não fazer
- Só roda se `finding_novelty` passou no PLAN-0030. Na dúvida, nunca classificar como `repetido` (esconder um achado real é pior que repeti-lo).
## Contexto
- SPEC-0003, `judge.verdict{new, regression}`.

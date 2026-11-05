---
type: plan
title: Pi liga a guarda de escopo (runtime pi passa -e e MANDA_SCOPE_*)
intent: INTENT-0012-jev-e-guarda-de-escopo
spec: SPEC-0004-jev-classificador-e-guarda-de-escopo
kind: change
status: approved
repos: [manda]
depends_on: [PLAN-0029-rota-de-falhas-e-disjuntor, PLAN-0032-guarda-de-escopo-no-pi]
done_when: "cd manda && bun test"
---
## Objetivo

Ligar de fato a guarda construída no PLAN-0032: o runtime `pi` do manda passa `-e <pi_scope_guard.ts>` e `MANDA_SCOPE_TOUCH/FROZEN/ROOT` ao `pi -p`. Sem este PLAN a guarda existe mas não bloqueia nada em execução real.

Separado do PLAN-0032 (replan de 2026-10-30) porque a TASK precisa esperar PLAN-0029 e PLAN-0033 TASK-07 (mesmo arquivo, `src/runtime/pi.ts`); dentro do 0032 ela fazia o judge reprovar o merge a cada rodada.

## TASKs

1. [TASK-01](TASK-01-runtime-pi-usa-guarda.md): runtime `pi` liga a guarda (antes TASK-04 do PLAN-0032)

## Riscos

- Conflito em `src/runtime/pi.ts` com PLAN-0029 e PLAN-0033: por isso a dependência explícita e a parte da `main` já com os dois.
- Critério de aceite medido depois de ~20 TASKs pelo Pi (SPEC-0004): `scope_drift` cai à metade ou menos.

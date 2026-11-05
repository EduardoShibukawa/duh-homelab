---
type: task
mode: padrao
goal: "manda judge <PLAN> roda o Verifier Judge só com artefatos crus, em runtime de família diferente do executor e do Planner"
title: Judge cego de outra família
plan: PLAN-0008-manda-routing-e-judge
repo: manda
depends_on: [TASK-05-budget, TASK-06-pinga-judge-externo]
tier: strong
pinga_task: T13
touch: [src/judge.ts, src/cli.ts, tests/judge_blind.test.ts]
done_when: "bun test tests/judge_blind.test.ts"
tests_frozen: [tests/judge_blind.test.ts]
---
## Fazer
- Bundle num tmpdir só com: SPEC (se houver), PLAN.md, `git diff base..head`, receipts (`pinga queue --json`) e `metrics.json`. Sem repo, sem transcript, sem LEARNINGS.
- Candidato: pool `verifier_judge` cuja família ≠ executores do PLAN e ≠ Planner (`selectJudgeCandidate`, `router.ts:368`).
- Grava `VERDICT.json` na pasta do PLAN e sela via `[commands].judge_seal` (padrão `pinga judge {plan} --verdict {file} ...`).
## Não fazer
- Não usar o context port (o Judge não lê código).
## Contexto
- `pi-harness/src/pipeline/judge_guard.ts` (`judgeTamperGuard`); doc 02 §5.

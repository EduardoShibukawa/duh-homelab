---
type: task
mode: padrao
goal: "pinga judge --verdict <arquivo> sela um veredito produzido fora do pinga, recusando judge da mesma família do executor"
title: pinga judge sela veredito externo
plan: PLAN-0008-manda-routing-e-judge
repo: p-inga
depends_on: []
tier: medium
pinga_task: T74
touch: [src/judge.ts, src/cli.ts, tests/judge_external.test.ts]
done_when: "bun test tests/judge_external.test.ts tests/judge.test.ts"
tests_frozen: [tests/judge_external.test.ts]
---
## Fazer
- `--verdict F --judge-model M` (e `--planner-model P` opcional): lê o JSON com `parseVerdict`, aplica `assertDistinctFamily` contra o executor (do receipt) e contra o planner.
- Mesma família → exit 7 `same_family_judge`; sem atestado → exit 8. Sem `--verdict`: comportamento atual.
## Não fazer
- Não chamar endpoint quando `--verdict` é dado.
## Contexto
- `src/judge.ts` (`JUDGE_EXIT`, `assertDistinctFamily` l. 35, `parseVerdict` l. 52, `judgePlan`), `src/family.ts` (`attestFromTranscript` l. 172), `cli.ts:693`.

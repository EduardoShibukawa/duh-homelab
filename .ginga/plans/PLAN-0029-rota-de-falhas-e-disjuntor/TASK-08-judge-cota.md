---
type: task
mode: mvp
goal: "Antes de chamar o judge, o manda escolhe um modelo de família diferente da do executor com cota e disjuntor fechado"
title: Pré-checagem de cota do judge
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-03-disjuntor]
tier: free
touch: [src/judge_pick.ts, tests/judge_pick.test.ts]
done_when: "bun test tests/judge_pick.test.ts"
tests_frozen: [tests/judge_pick.test.ts]
pinga_task: T174
---
## Fazer
- Ordem do pool `verifier_judge`; pula família igual à do executor (`src/family.ts`), disjuntor `open` e provider com `used_pct >= 100` em `ginga quota --json` (ausente → probe).
## Interface
- `export function pickJudge(o: { pool: string[]; executorModel: string; breaker: (m: string) => BreakerState; quota: (m: string) => number | null }): string | null`. Teste: Codex com quota 100% → `opencode/gpt-6-luna`; executor gpt → pula a família gpt.
## Não fazer
- Não mudar o `judge_run`.
## Contexto
- `bin/judge-run.sh` (fallback de hoje); `src/judge.ts`.

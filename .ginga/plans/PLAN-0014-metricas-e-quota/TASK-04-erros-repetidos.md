---
type: task
mode: padrao
goal: "ginga metrics conta erros repetidos: falha com o mesmo motivo e escopo depois de existir learning ou lesson sobre ele"
title: Métrica de erros repetidos
plan: PLAN-0014-metricas-e-quota
repo: ginga
depends_on: [TASK-01-metricas]
pinga_task: T358
tier: medium
touch: [src/metrics_repeat.ts, src/metrics.ts, tests/metrics_repeat.test.ts]
done_when: "bun test tests/metrics_repeat.test.ts"
tests_frozen: [tests/metrics_repeat.test.ts]
---
## Fazer
- Para cada `attempt` falho: existe `learning`/LESSON anterior cujo escopo cobre o `touch` da TASK e com o mesmo `failure`/`reason_code`? Conta como repetido.
- Saída por PLAN e por semana; também "learnings reutilizados" (lessons citadas por PLANs posteriores).
## Interface
- `repeatedErrors(db: Database, root: string): { plan: string; week: string; repeated: number; reused_lessons: number }[]` em `src/metrics_repeat.ts`; `computeMetrics` ganha o campo `repeated_errors: number`. Teste: learning de 01/10 sobre `src/x.ts` + falha de mesmo `reason_code` em 05/10 tocando `src/x.ts` → 1 repetido.
## Não fazer
- Sem heurística por LLM.
## Contexto
- Doc 06 §6 ("Erros repetidos" é o indicador principal).

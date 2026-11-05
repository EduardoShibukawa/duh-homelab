---
type: task
mode: mvp
goal: "O detalhe do PLAN mostra o DAG de TASKs, tentativas, custo e log, com Retry, Escalar, Pausar e Cancelar"
title: Detalhe do PLAN
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-02-web-shell]
tier: free
touch: [src/web/render/plan.ts, web/plan.js, tests/web_plan.test.ts]
done_when: "bun test tests/web_plan.test.ts"
tests_frozen: [tests/web_plan.test.ts]
pinga_task: T327
---
## Fazer
- Cabeçalho (status, gasto / teto, SPEC, repo); TASKs com receipt, tentativas (runtime/modelo/tokens/custo), bloqueadas por quem.
- Botões → `retry`, `escalate`, `pause`, `cancel`; `log.md` do PLAN embaixo.
## Interface
- `renderPlan(p: { id: string; status: string; spent_usd: number; cap_usd: number; tasks: { id: string; status: string; attempts: { model: string; cost_usd: number; pass: boolean }[] }[]; log: string }): string` (pura); botões `data-verb="retry|escalate|pause|cancel"`.
## Não fazer
- Sem stream Ao Vivo (fica fora deste PLAN).
## Contexto
- Doc 05 §3.3; eventos `attempt` no `state.db`.

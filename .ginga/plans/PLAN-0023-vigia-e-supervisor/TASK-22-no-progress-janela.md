---
type: task
mode: padrao
goal: "no_progress avalia só os heartbeats da janela recente (window_minutes), não todo o histórico"
title: follow-up do judge 01:07 — no_progress com recorte de janela
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-21-heartbeat-pid-filho]
tier: free
pinga_task: T113
touch: [src/watch/evaluate.ts, tests/watch_no_progress_window.test.ts, tasks/T113/PLAN.md]
done_when: "bun test tests/watch_no_progress_window.test.ts tests/watch_rules.test.ts tests/watch_followup8.test.ts tests/watch_followup9.test.ts tests/serve_watch_tick.test.ts tests/supervisor_heartbeat_running.test.ts tests/supervisor_progress_effect.test.ts"
tests_frozen: [tests/watch_no_progress_window.test.ts]
---
## Fazer
- `src/watch/evaluate.ts` (no_progress, ~:92-103): por entidade, referência = o ts do heartbeat mais novo da entidade; recorte = heartbeats com `ts >= ref - window_minutes` mais o último heartbeat anterior ao corte (baseline). A regra (progress todo igual, algum alive, span >= window, `thr+1` heartbeats) vale sobre esse recorte, não sobre o histórico inteiro. Heartbeats antigos com progress diferente não impedem o alerta; progress variando dentro do recorte não alerta.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

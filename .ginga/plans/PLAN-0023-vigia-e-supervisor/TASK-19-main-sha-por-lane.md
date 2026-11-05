---
type: task
mode: padrao
goal: "main_moved_outside_gate compara o SHA de main por entidade/lane, não num conjunto global"
title: follow-up do judge 00:51 — SHA de main por lane
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-17-main-moved-warn-sem-sha]
tier: free
pinga_task: T110
touch: [src/watch/evaluate.ts, tests/watch_main_sha_per_lane.test.ts, tasks/T110/PLAN.md]
done_when: "bun test tests/watch_main_sha_per_lane.test.ts tests/watch_main_moved_nosha.test.ts tests/watch_followup8.test.ts tests/watch_followup9.test.ts tests/serve_watch_tick.test.ts tests/watch_rules.test.ts"
tests_frozen: [tests/watch_main_sha_per_lane.test.ts]
---
## Fazer
- `src/watch/evaluate.ts` (main_moved_outside_gate, ~:150-185): agrupar heartbeats por entidade. Entidade com >= 2 SHAs distintos e sem `gate.result` na janela → alerta (severidade da regra, default critical) com `entity` = a entidade. Entidade não-`executor/*` sem nenhum SHA → warn "sem SHA de main no heartbeat" (um por entidade), mesmo que outras entidades tenham SHA. SHAs de entidades diferentes nunca são comparados entre si.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

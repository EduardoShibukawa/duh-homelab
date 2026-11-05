---
type: task
mode: padrao
goal: "lane.round end fecha só o start correspondente (pareado por ordem temporal); start posterior sem end continua visível para lane_dead"
title: follow-up do judge 00:51 — lane_dead pareia start/end
plan: PLAN-0023-vigia-e-supervisor
repo: ginga
depends_on: [TASK-02-watch-rules]
tier: free
pinga_task: T109
touch: [src/watch/evaluate.ts, tests/watch_lane_dead_pairing.test.ts, tasks/T109/PLAN.md]
done_when: "bun test tests/watch_lane_dead_pairing.test.ts tests/watch_rules.test.ts"
tests_frozen: [tests/watch_lane_dead_pairing.test.ts]
---
## Fazer
- `src/watch/evaluate.ts` (lane_dead, ~:123-146): por lane, ordenar os `lane.round` por ts; contar starts abertos (end fecha um start anterior, nunca mais de um; end sem start é ignorado). Lane com contagem aberta > 0 conta como pendente (respeitando `thr`) e alerta se não houver heartbeat vivo. Remover o `Set` global de lanes com end.
## Não fazer
- Não alterar tests_frozen nem testes de outras TASKs.

---
type: task
mode: padrao
goal: "Renomeia T162-T166 (tasks de PLAN-0028) para T168-T172, resolvendo a colisão de ids com o PLAN-0032 (scope guard) já mergeado na main"
title: Renomeia T162-T166 para T168-T172 para resolver colisão de task id
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: manda
depends_on: [TASK-17-worktree-before-taken]
pinga_task: T168
tier: free
touch: [tasks/T168/PLAN.md, tasks/T169/PLAN.md, tasks/T170/PLAN.md, tasks/T171/PLAN.md, tasks/T172/PLAN.md]
done_when: "test -f tasks/T168/PLAN.md && test -f tasks/T169/PLAN.md && test -f tasks/T170/PLAN.md && test -f tasks/T171/PLAN.md && test -f tasks/T172/PLAN.md"
tests_frozen: []
---

## Achado do judge
- PLAN-0028 usa T162-T166 para tarefas de cost-cap wiring (T162), planner guard (T163), red repo filter (T164), red CLI multi-repo (T165) e taken scans (T166).
- PLAN-0032 usa T162-T166 para scope guard (decideToolCall, resolvePath, pi_scope_guard, scope events, scope refactor).
- PLAN-0032 já mergeado na main → colisão de diretório na hora do merge de PLAN-0028.

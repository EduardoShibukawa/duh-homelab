---
type: task
mode: padrao
goal: "Desacoplar tests/discord.test.ts (T26) e tests/ux_t52_hardening.test.ts (W12) do HOME real, usando HOME falso via tests/helpers/home.ts"
plan: PLAN-0018-sandbox-done-when
repo: p-inga
depends_on: []
tier: free
pinga_task: T74
touch:
  - tests/discord.test.ts
  - tests/ux_t52_hardening.test.ts
tests_frozen: []
done_when: "HOME=/tmp/pinga-task03-red bun test tests/discord.test.ts tests/ux_t52_hardening.test.ts"
---
# TASK-03: HOME falso para T26 e W12 (PLAN-0018)

Materializar em p-inga/tasks/T74/PLAN.md.
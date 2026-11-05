# Operador manda rodada 4

- T160 (manda): `manda red` ligado na CLI; env propagado ao pinga/git. `bun test tests/red_cli.test.ts` pass.
- T161 (manda): `manda replan` monta receipts, judge e diff real; usa `[roles] planner` com fallback opencode. `bun test tests/replan_cli.test.ts` pass.
- Commit: manda-plan-0028 397389c.
- Ready: .ginga/plans/PLAN-0028-ciclo-autonomo-sem-operador/ready/manda.json -> plan/0028.

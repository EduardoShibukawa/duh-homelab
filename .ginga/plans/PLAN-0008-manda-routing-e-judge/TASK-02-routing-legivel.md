---
type: task
mode: mvp
goal: "ROUTING.md ganha frontmatter legível por máquina (ladder, pools por papel/tier, budget) equivalente às tabelas"
title: Frontmatter máquina no ROUTING.md
plan: PLAN-0008-manda-routing-e-judge
repo: duh-homelab
depends_on: []
tier: free
touch: [.ginga/models/ROUTING.md]
done_when: "grep -q '^ladder:' .ginga/models/ROUTING.md && grep -q '^pools:' .ginga/models/ROUTING.md && grep -q '^budget:' .ginga/models/ROUTING.md"
tests_frozen: []
---
## Fazer
- `ladder: [{tier: free, tries: 2}, {tier: medium, tries: 2}, {tier: strong, tries: 1}]`, `breaker: {same_reason: 3, ignore: [quota_exhausted, infra]}`.
- `pools`: por papel e tier, `provider/model` na ordem das tabelas (Executor free/medium/strong, Planner, judges).
- `budget: {month_usd: 10, task_usd: 0.25, plan_usd: 1.5, warn_pct: 80}`; `ask_owner: [over_cap, runtime_claude]`.
## Não fazer
- Não mudar o texto nem as tabelas; frontmatter e tabela precisam dizer a mesma coisa.
## Contexto
- `.ginga/models/ROUTING.md`, `.ginga/models/PROVIDER-*.md`.

---
type: task
mode: mvp
goal: "O gira.yaml do p-inga carrega o tour e os workflows que saíram do código do gira"
title: Conteúdo do site do P-Ingá no gira.yaml do p-inga
plan: PLAN-0009-contexto-sem-gira
repo: p-inga
pinga_task: T80
depends_on: [TASK-01-gira-tour-config]
tier: free
touch: [gira.yaml, tasks/T80/PLAN.md]
done_when: "grep -q '^docsite:' gira.yaml && gira docs --output /tmp/pinga-docsite >/dev/null && grep -q 'pinga-stable' /tmp/pinga-docsite/index.html"
tests_frozen: []
---
## Fazer
- Copiar para `docsite:` os passos de `tour.go:309-370` e os comandos de `landing.go:421-422` (`bun .pinga/pinga-stable verify ...`), título "P-Ingá".
## Não fazer
- Não mexer em código do p-inga.
## Contexto
- Formato definido na TASK-01; `p-inga/gira.yaml` atual (`target_system`, `repositories`).

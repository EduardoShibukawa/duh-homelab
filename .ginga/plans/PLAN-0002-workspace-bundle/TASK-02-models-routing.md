---
type: task
mode: mvp
goal: "Registrar providers, modelos, roteamento e budget"
title: Registro de modelos por provider + política de roteamento e budget
plan: PLAN-0002-workspace-bundle
depends_on: []
tier: strong
touch: [.ginga/models/]
done_when: "test -f .ginga/models/ROUTING.md && ls .ginga/models/PROVIDER-*.md | wc -l | grep -qx 6"
tests_frozen: []
---

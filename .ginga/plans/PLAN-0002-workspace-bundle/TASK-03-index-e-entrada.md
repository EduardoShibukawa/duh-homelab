---
type: task
mode: mvp
goal: "index.md como quadro de trabalho e CLAUDE.md/AGENTS.md apontando para ele"
title: index.md como quadro de trabalho + apontar CLAUDE.md/AGENTS.md
plan: PLAN-0002-workspace-bundle
depends_on: [TASK-01-bundle-e-cleanup, TASK-02-models-routing]
tier: strong
touch: [.ginga/index.md, .ginga/log.md, CLAUDE.md, AGENTS.md]
done_when: "grep -q '.ginga/index.md' CLAUDE.md && grep -q '.ginga/index.md' AGENTS.md"
tests_frozen: []
---

---
type: task
mode: mvp
goal: "Criar o bundle .ginga, mover o design e arquivar o legado da raiz"
title: Criar o bundle, mover o design e arquivar o legado
plan: PLAN-0002-workspace-bundle
depends_on: []
tier: strong
touch: [.ginga/, _archive/, ginga-revamp/, PROMPT-ORQUESTRADOR-*.md, P-INGA-INSTALL-E-APRENDIZADO.md, intents/0001-deepen-global-skill.md]
done_when: "test -d .ginga/knowledge/design/ginga-revamp && test ! -e ginga-revamp && test -f _archive/MANIFEST.md"
tests_frozen: []
---

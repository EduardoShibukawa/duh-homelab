---
type: lesson
title: "Mexer na main de um repo enquanto a lane roda faz a lane abortar com alerta CRÍTICO"
from: sessao-2026-11-05
status: "armadilha"
scope:
  repo: "duh-homelab"
  files: [".ginga/bin/"]
  symbols: []
  tags: ["lane", "main", "pull"]
evidence: "lane.sh: 'Aborta se a main do <repo> andar durante o operador'; pipeline.sh exit 20"
---
# LESSON-0005 — Mexer na main de um repo enquanto a lane roda faz a lane abortar com alerta CRÍTICO

- from: sessao-2026-11-05 (armadilha)
- evidência: lane.sh: 'Aborta se a main do <repo> andar durante o operador'; pipeline.sh exit 20
- conclusão: Sincronizar `main` local (pull, merge de PR no remoto seguido de pull) só com `systemctl --user list-units 'ginga-lane-*'` vazio. Scripts de `.ginga/bin` usados pelas lanes trocam por `.new` + `mv` atômico.
- escopo: .ginga/bin/

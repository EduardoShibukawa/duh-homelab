---
type: lesson
title: "O __pycache__ gerado pelo próprio done_when (unittest) causa scope_drift no pinga verify"
from: PLAN-0011#TASK-05
status: "armadilha"
scope:
  repo: "ginga"
  files: ["tests/", "contrib/"]
  symbols: []
  tags: ["scope_drift", "python"]
evidence: "PLAN-0011 LEARNINGS TASK-05; PLAN-0035 (`.pyc` rastreado sujava a main)"
---
# LESSON-0003 — O __pycache__ gerado pelo próprio done_when (unittest) causa scope_drift no pinga verify

- from: PLAN-0011#TASK-05 (armadilha)
- evidência: PLAN-0011 LEARNINGS TASK-05; PLAN-0035 (`.pyc` rastreado sujava a main)
- conclusão: Artefato transitório não é edição: limpar `__pycache__` antes de selar o receipt e manter `*.pyc` fora do git (`git rm --cached` se já rastreado).
- escopo: tests/, contrib/

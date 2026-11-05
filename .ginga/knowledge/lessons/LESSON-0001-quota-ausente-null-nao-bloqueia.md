---
type: lesson
title: "Quota ausente (null) mantém o modelo elegível para probe; só used_pct >= 100 bloqueia"
from: PLAN-0029#TASK-08
status: "confirmada"
scope:
  repo: "manda"
  files: ["src/"]
  symbols: []
  tags: ["quota", "probe"]
evidence: "PLAN-0029 TASK-08 (log.md do PLAN)"
---
# LESSON-0001 — Quota ausente (null) mantém o modelo elegível para probe; só used_pct >= 100 bloqueia

- from: PLAN-0029#TASK-08 (confirmada)
- evidência: PLAN-0029 TASK-08 (log.md do PLAN)
- conclusão: Tratar `null` como 'sem dado' e não como 'esgotado' evita travar a escada de modelos quando a leitura de quota falha.
- escopo: src/

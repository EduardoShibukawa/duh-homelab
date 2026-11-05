---
type: lesson
title: "A main do gira-g é protegida (5 checks, enforce_admins): só entra por PR, e o merge é do dono"
from: sessao-2026-11-05
status: "armadilha"
scope:
  repo: "gira-g"
  files: [".github/"]
  symbols: []
  tags: ["github", "pr", "protecao"]
evidence: "gh api branches/main/protection; auto mode bloqueou `gh pr merge` sem revisão (2026-11-05); LESSONS.md L-6"
---
# LESSON-0006 — A main do gira-g é protegida (5 checks, enforce_admins): só entra por PR, e o merge é do dono

- from: sessao-2026-11-05 (armadilha)
- evidência: gh api branches/main/protection; auto mode bloqueou `gh pr merge` sem revisão (2026-11-05); LESSONS.md L-6
- conclusão: Fluxo: branch `sync/*` → PR → CI verde (ubuntu, macos, windows, validator, floor guard) → merge pelo dono. Atenção: um PR draft em repo público já publica os commits; rodar a varredura de segredos (gitleaks) antes de abrir.
- escopo: .github/

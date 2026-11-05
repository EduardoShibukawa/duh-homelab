---
type: lesson
title: "Bun.serve só despeja os headers do SSE no primeiro byte do corpo: sem heartbeat, a conexão pendura até o idle timeout de 10 s"
from: PLAN-0011#TASK-03
status: "fato"
scope:
  repo: "ginga"
  files: ["src/serve.ts", "src/api/"]
  symbols: []
  tags: ["sse", "bun"]
evidence: "PLAN-0011 LEARNINGS TASK-03"
---
# LESSON-0004 — Bun.serve só despeja os headers do SSE no primeiro byte do corpo: sem heartbeat, a conexão pendura até o idle timeout de 10 s

- from: PLAN-0011#TASK-03 (fato)
- evidência: PLAN-0011 LEARNINGS TASK-03
- conclusão: Emitir um comentário SSE (`: ping`) no pump vazio. Vale para qualquer endpoint SSE novo.
- escopo: src/serve.ts, src/api/

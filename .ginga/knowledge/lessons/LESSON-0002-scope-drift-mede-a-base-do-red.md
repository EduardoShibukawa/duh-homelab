---
type: lesson
title: "scope_drift mede o diff contra o commit `test(T<N>): RED`; RED de TASKs irmãs commitado depois entra no diff"
from: PLAN-0033#P1
status: "armadilha"
scope:
  repo: "p-inga"
  files: ["src/guards.ts", "src/verify.ts"]
  symbols: []
  tags: ["scope_drift", "verify"]
evidence: "knowledge/research/problemas-harness-sessao-guard-2026-10-30.md §P1 (50 de 154 falhas, 32%)"
---
# LESSON-0002 — scope_drift mede o diff contra o commit `test(T<N>): RED`; RED de TASKs irmãs commitado depois entra no diff

- from: PLAN-0033#P1 (armadilha)
- evidência: knowledge/research/problemas-harness-sessao-guard-2026-10-30.md §P1 (50 de 154 falhas, 32%)
- conclusão: Uma TASK que já passa o done_when pode voltar `blocked scope_drift` porque `findRedBase` devolve o RED da própria TASK e os RED das irmãs entram no diff. Antes de culpar o modelo, conferir a base do diff e commitar todos os RED do PLAN antes de despachar.
- escopo: src/guards.ts, src/verify.ts

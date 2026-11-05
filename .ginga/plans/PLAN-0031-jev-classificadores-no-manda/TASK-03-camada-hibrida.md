---
type: task
mode: padrao
goal: "classifyWith aplica o Jev sobre uma regra determinística com off/shadow/on, limiar, orçamento e fail-open, emitindo os eventos"
title: Camada híbrida regra + Jev
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: [TASK-01-config-jev]
tier: medium
touch: [src/jev/hybrid.ts, tests/jev/hybrid.test.ts]
done_when: "bun test tests/jev/hybrid.test.ts"
tests_frozen: [tests/jev/hybrid.test.ts]
---
## Fazer
- Implementar `classifyWith` e `Labeled`/`Mode` como no PLAN.md. Tabela de teste (modo × regra sabe/não × Jev ok/erro/lento/baixa confiança × orçamento) com o resultado e os eventos esperados.
- `off`: `jev()` **nunca** é chamado (o teste conta as chamadas). `shadow`: chama sem esperar mais que `timeoutMs` e nunca altera o retorno. `on`: usa o Jev só com `confidence ≥ minConfidence` e `budgetOk()`.
## Interface
- Ver PLAN.md. Sem dependência de rede; `jev` e `emit` são injetados.
## Não fazer
- Nenhuma classe do Jev dispara ação por si: quem chama mapeia classe → ação já existente.
## Contexto
- SPEC-0004, ACs de fail-open e shadow.

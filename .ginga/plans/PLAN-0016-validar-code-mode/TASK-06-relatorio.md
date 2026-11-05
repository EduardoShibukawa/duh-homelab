---
type: task
mode: mvp
goal: "O relatório lê results.jsonl, calcula pass^k e médias por célula e decide cada hipótese pelos critérios pré-registrados"
title: Relatório e decisão
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-02-runner]
tier: free
touch: [bench/code-mode/report.ts, tests/code_mode/report.test.ts, tests/fixtures/code-mode/results.jsonl]
done_when: "bun test tests/code_mode/report.test.ts"
tests_frozen: [tests/code_mode/report.test.ts, tests/fixtures/code-mode/results.jsonl]
pinga_task: T341
---
## Fazer
- Tabela por modo × modelo: reward médio, pass^k, turnos, tokens de entrada/saída, custo, latência; trials `infra` fora das médias e contados à parte.
- `decide`: H1 adotar se X2 tem tokens ≤ 0,7× de M e reward ≥ M − 1 task; H3 "não criar `execute`" se |C − X2| ≤ 1 task; H4 informa o menor modelo com reward ≥ 8/10 em X2; H5 exige Oracle 10/10; H7 adotar se tokens ≤ 0,85× com o mesmo reward; H2 sempre `informativo`. Diferença menor que 1 task → `inconclusivo`.
## Interface
- `decide` (PLAN.md); `renderReport(trials: Trial[]): string` (markdown). Teste: fixture de results com números escolhidos para cada veredito → os 6 vereditos exatos.
## Não fazer
- Sem gráficos (markdown basta).
## Contexto
- PLAN.md ("Hipóteses").

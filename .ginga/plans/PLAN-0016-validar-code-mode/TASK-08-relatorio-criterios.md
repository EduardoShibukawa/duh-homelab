---
type: task
mode: mvp
goal: "O relatório decide H4 pelo tamanho do modelo, H7 pelo par sandbox explícito, aplica a regra de diferença sub-task e expõe uma CLI executável"
title: Critérios do relatório e CLI
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-02-runner, TASK-06-relatorio]
tier: free
touch: [bench/code-mode/report.ts, bench/code-mode/runner.ts, bench/code-mode/run.ts, bench/code-mode/config.ts, bench/code-mode/surfaces/x.ts, tests/code_mode/report_followup.test.ts]
done_when: "bun test tests/code_mode/report_followup.test.ts tests/code_mode/report.test.ts"
tests_frozen: [tests/code_mode/report_followup.test.ts]
pinga_task: T351
---
## Fazer
- H4: ranquear por tamanho do modelo (flash = pequeno, pro = grande, desconhecido = médio), nunca por tokens; empate resolve pelo nome do modelo.
- H7: `Trial` carrega `sandbox: minimal | full`; `runCells --plan h7` produz os dois braços para a mesma task/model, o runner grava o braço e a config/superfície X o aplica. O relatório pareia pelo campo explícito, nunca por sufixo `-min`.
- H3: diferença de reward não nula e menor que 1 task vira `inconclusivo`; diferença zero continua sendo igualdade e mantém o veredito pré-registrado.
- CLI: `bun bench/code-mode/report.ts [results.jsonl]` lê o JSONL e imprime tabela + vereditos H1-H5/H7.

## Não fazer
- Não alterar `tests/code_mode/report.test.ts` nem o fixture congelado da TASK-06.
- Não trocar o sentido dos critérios H1, H3 (igualdade), H5 ou H7.

## Contexto
- Judge 2026-11-02: H4 ordenava por tokens; H7 dependia de `-min` que o runner nunca gerava; faltava a regra sub-task e o `main` do relatório.

---
type: task
mode: mvp
goal: "tests/fixtures/jev/blocked.jsonl tem ao menos 30 textos de BLOCKED reais, mascarados e rotulados nas 8 classes, com a regex atual como baseline"
title: Rótulos manuais de BLOCKED
plan: PLAN-0030-jev-experimento-de-acuracia
repo: manda
depends_on: [TASK-04-extrair-dataset]
tier: strong
touch: [tests/fixtures/jev/blocked.jsonl, tests/jev/blocked_fixture.test.ts]
done_when: "bun test tests/jev/blocked_fixture.test.ts"
tests_frozen: [tests/jev/blocked_fixture.test.ts]
---
## Fazer
- **Passada do Planner, à mão (sessão curta de Claude; não despachar a executor).** O `tier: strong` é só para o dispatcher não pegá-la sozinha (sem `ALLOW_PAID=1` ela fica bloqueada).
- Rodar o extrator sobre `.ginga/plans` real, escolher ≥ 30 textos de `BLOCKED:` (todos os que existirem se forem menos, e marcar `n` baixo), passar por `mask`, **conferir a máscara à mão**, rotular nas 8 classes do `BlockedClass` e gravar JSONL `{id, input, label}`.
- Incluir o baseline: a classe que o `classifyBlocked` (regex do PLAN-0029) devolve para cada texto, em `regex_label`.
## Interface
- O teste só valida o formato: ≥ 30 linhas (ou `n_low: true` documentado), rótulos dentro das 8 classes, nenhum padrão de segredo, nenhum caminho `/home/`.
## Não fazer
- Não commitar texto sem passar pela máscara e pela conferência. Não inventar casos: se faltar, o `n` é o que existe.
## Contexto
- PLAN-0029 TASK-07 define `BlockedClass` e `classifyBlocked`.

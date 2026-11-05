---
type: task
mode: padrao
goal: "extractDataset lê os log.md, runs e judge dos PLANs e gera exemplos mascarados (texto, rótulo derivado, n) para quatro classificadores, sem rede"
title: Extrator de dataset
plan: PLAN-0030-jev-experimento-de-acuracia
repo: manda
depends_on: [TASK-01-mascara]
tier: medium
touch: [src/jev/dataset.ts, tests/jev/dataset.test.ts, tests/fixtures/jev/plans/]
done_when: "bun test tests/jev/dataset.test.ts"
tests_frozen: [tests/jev/dataset.test.ts, tests/fixtures/jev/plans/]
---
## Fazer
- Entrada: um diretório com a forma de `.ginga/plans/` (o teste usa `tests/fixtures/jev/plans/`, **sintético**).
- `quota_log`: pares (cauda mascarada do log de tentativa, rótulo). Positivo = a linha do `log.md` da tentativa diz quota/429 e a seguinte mostra troca de modelo; negativo = log > 6000 bytes de trabalho real que cita 429 e termina em `pass`. Casos ambíguos são descartados e contados.
- `finding_novelty`: a partir de `judge/*.json` de rodadas consecutivas: `repetido` se o mesmo `ref` e a mesma `evidence` (normalizada) já existiam; `regressao` se `regression: true`; `novo` caso contrário.
- `tier`: a partir de `log.md` (`TASK-xx <modelo> tentativa N pass|fail`): menor tier que passou. Marca `weak: true` (rótulo derivado do histórico, só para medir).
- `blocked`: extrai só o **texto** (rótulo vazio) de `BLOCKED:` para a TASK-05 rotular.
- Saída JSONL com `{ classifier, id, input, label, source, weak? }`; cada `input` passa por `mask`. Relata `n` por classe e quantos descartou.
## Interface
- `extractDataset(plansDir: string): { examples: Example[]; dropped: Record<string, number> }`. Teste com a árvore sintética: contagens e rótulos exatos, e nenhum segredo falso sobrevive.
## Não fazer
- Não ler `.ginga/plans` real nos testes. Não escrever fora de `tests/fixtures/jev/`. Sem rede.
## Contexto
- Fontes reais (para a Fase 2): `.ginga/plans/*/log.md`, `runs/*.log`, `judge/*.json`.

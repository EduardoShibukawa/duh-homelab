---
type: task
mode: mvp
goal: "O snapshot sintético de code mode versiona os runs usados pelo Oracle e pela superfície M, de modo que os testes passem também em um checkout limpo"
title: Fixture sintético em checkout limpo
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-01-tasks-oracle, TASK-03-superficie-m]
tier: free
touch: [tests/code_mode/clean_checkout.test.ts, tests/fixtures/code-mode/snapshot/runs/a.log, tests/fixtures/code-mode/snapshot/runs/b.log, tests/fixtures/code-mode/snapshot/runs/c.jsonl, tests/fixtures/code-mode/snapshot/runs/d.jsonl]
done_when: "bun test tests/code_mode/clean_checkout.test.ts tests/code_mode/oracle.test.ts tests/code_mode/surface_m.test.ts"
tests_frozen: [tests/code_mode/clean_checkout.test.ts]
pinga_task: T350
---
## Fazer
- Incluir no índice Git os quatro fixtures sintéticos `snapshot/runs/{a.log,b.log,c.jsonl,d.jsonl}` com `git add -f`; não commitar.
- O teste exporta o índice com `git checkout-index` e roda Oracle + superfície M na cópia, sem depender dos arquivos locais ignorados.
- Depois do commit do operador, `git archive HEAD` deve conter `tests/fixtures/code-mode/snapshot/runs/` e os três testes devem passar na extração limpa.

## Não fazer
- Não versionar snapshot real do workspace; só os quatro arquivos sintéticos listados no `touch`.
- Não alterar `tests/code_mode/oracle.test.ts` nem `tests/code_mode/surface_m.test.ts`.

## Contexto
- Judge 2026-11-02: `.git/info/exclude` contém `runs/`; os fixtures existem só na worktree e o AC falha em `git archive HEAD` (17/20).

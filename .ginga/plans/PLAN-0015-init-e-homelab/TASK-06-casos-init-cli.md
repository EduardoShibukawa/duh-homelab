---
type: task
mode: padrao
goal: "registro com init coberto na enumeração da CLI: tests/cli_verbs.test.ts ganha o caso init e o run do verbo devolve JSON determinístico entre raízes"
title: casos init na CLI do registro
plan: PLAN-0015-init-e-homelab
repo: ginga
pinga_task: T128
depends_on: [TASK-01-ginga-init]
tier: light
touch: [src/verbs/init.ts, tasks/T128/PLAN.md]
done_when: "bun test tests/cli_verbs.test.ts"
tests_frozen: [tests/cli_verbs.test.ts]
---
## Fazer
- `src/verbs/init.ts:run` devolve só `{ created, detected }` — sem `root`/`repo` absolutos: o laço de `tests/cli_verbs.test.ts` compara o JSON da CLI e do `run` direto em diretórios temporários diferentes, e qualquer caminho absoluto nunca seria igual.
## Não fazer
- Não alterar `tests/init.test.ts` (frozen T127) nem os demais casos de `cli_verbs` (frozen T121/T123) — o caso `"init"` no `CASES` já entrou no commit RED desta TASK (f8b09fc).
## Contexto
- Correção do T127 (PLAN-0015 TASK-01): `init` entrou no registro e quebrou a enumeração "todo verbo do registro tem caso aqui". Alteração de tests_frozen alheio só por TASK nova (precedente T17→T22 em `.ginga/handoffs/REPORT-2026-10-28.d/decisoes.md`).
- Duas tentativas de despacho (qwen3.8-flash, US$0,036) saíram blocked: a 1ª mexeu no arquivo que o contrato congelava (contradição do próprio contrato), a 2ªrecognizou a contradição. O operador refez o RED com o caso no `CASES` e fechou o delta (run determinístico) dentro da TASK; verify pass.

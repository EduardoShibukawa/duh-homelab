---
type: task
mode: padrao
goal: "As 10 tasks do code mode têm schema de resposta, Oracle que dá 10/10 no snapshot sintético e verifier exato que aceita uma solução alternativa"
title: Tasks, Oracle e verifier (H5)
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: []
tier: medium
touch: [bench/code-mode/tasks.ts, bench/code-mode/oracle.ts, tests/code_mode/oracle.test.ts, tests/fixtures/code-mode/snapshot/]
done_when: "bun test tests/code_mode/oracle.test.ts"
tests_frozen: [tests/code_mode/oracle.test.ts, tests/fixtures/code-mode/snapshot/]
pinga_task: T335
---
## Fazer
- O snapshot tem a forma do real: `plans/PLAN-*/{PLAN.md,TASK-*.md,log.md}`, `runs/*.log`, `runs/*.jsonl`.
- As 10 tasks: (1) status de um PLAN; (2) nº de TASKs de um PLAN; (3) `touch` da TASK que passou na tentativa 1 com um modelo dado; (4) custo pago por modelo somando `tentativa paga N: US$x` dos `log.md`; (5) tentativas e taxa de pass por modelo; (6) quantos `runs/*.log` contêm `Free usage limit` (heavy); (7) total de `step_finish` nos `runs/*.jsonl` (heavy); (8) PLANs que dependem, direta ou transitivamente, de um PLAN `draft`; (9) tentativas pagas com custo US$ 0 (trap); (10) TASKs citadas em `log.md` sem arquivo `TASK-*.md` (trap).
- `oracle` resolve cada uma lendo arquivos (sem LLM); `verify` compara com a resposta do Oracle normalizada (ordem de listas ignorada, números com 2 casas).
## Interface
- `CMTask`, `TASKS`, `oracle`, `verify` (PLAN.md). Teste: as 10 respostas do Oracle no fixture batem com os valores esperados escritos no teste; para cada task, uma resposta alternativa equivalente (outra ordem, `0.1` vs `0.10`) dá reward 1 e uma errada dá 0.
## Não fazer
- Não versionar dado real do workspace (só o fixture sintético).
## Contexto
- PLAN.md (hipóteses e níveis); formato real das linhas em `.ginga/plans/PLAN-0011-verbos-api-auth/log.md`.

---
type: task
mode: padrao
goal: "log longo deixa de ser ignorado na detecção de cota: a cauda mascarada é classificada como cota ou trabalho real"
title: Cota × trabalho real em log longo
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: [TASK-03-camada-hibrida]
tier: medium
touch: [src/runtime/failure.ts, tests/runtime_failure_jev.test.ts]
done_when: "bun test tests/runtime_failure_jev.test.ts tests/runtime_pi_opencode.test.ts"
tests_frozen: [tests/runtime_failure_jev.test.ts]
---
## Fazer
- Em `classifyRunnerFailure`, a regra atual continua para log curto. Para log > 6000 bytes (onde hoje não se decide, por medo de falso positivo), uma nova `classifyLongLog(res)` pergunta `quota_log` sobre os últimos 2000 caracteres mascarados e só devolve `quota_exhausted` com `sim` e confiança ≥ limiar; senão `unknown`.
- Mantém a assinatura síncrona para quem já usa; a versão assíncrona é nova.
## Interface
- Teste: log longo de trabalho real que cita "429" → `unknown`; log longo que termina em erro de cota → `quota_exhausted`; Jev fora → `unknown`; `off` → comportamento atual.
## Não fazer
- Não tocar `dispatch-task.sh`/`lane.sh` (bash). A paridade no bash é migração do PLAN-0028.
## Contexto
- `dispatch-task.sh` (`is_quota`, limite de 6000 bytes) e `lane.sh`; só roda se `quota_log` passou no PLAN-0030.

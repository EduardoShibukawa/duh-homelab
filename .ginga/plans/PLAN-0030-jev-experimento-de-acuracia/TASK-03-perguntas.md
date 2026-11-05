---
type: task
mode: padrao
goal: "buildRequest e parseAnswer montam as perguntas tipadas e leem a resposta dos quatro classificadores, com rótulos fechados"
title: Perguntas e parsers dos classificadores
plan: PLAN-0030-jev-experimento-de-acuracia
repo: manda
depends_on: [TASK-01-mascara, TASK-02-cliente-jev]
tier: free
touch: [src/jev/questions.ts, tests/jev/questions.test.ts]
done_when: "bun test tests/jev/questions.test.ts"
tests_frozen: [tests/jev/questions.test.ts]
---
## Fazer
- `blocked`: uma `choice` com as classes do `BlockedClass` do PLAN-0029 (`contract_conflict`, `missing_dep`, `env_dependency`, `id_collision`, `gate_false_positive`, `scope_drift`, `quota`, `other`), critério em uma frase cada. Estado: `{ blocked_text }` mascarado.
- `quota_log`: uma `noul` ("Este trecho de log é um erro de cota/rate limit do provider, e não trabalho do modelo que cita o texto?"). Estado: `{ log_tail }` (últimos 2000 caracteres mascarados).
- `finding_novelty`: uma `choice` `novo | repetido | regressao`. Estado: `{ previous_findings: [{ref, evidence}], finding: {ref, evidence} }`.
- `tier`: uma `choice` `light | standard | heavy`. Estado: `{ task_goal, touch_count, has_tests_frozen }`.
- `parseAnswer` devolve `{ label, confidence, probabilities }`; para `noul`, `label` = `"sim" | "nao"`, `confidence` = `max(p, 1-p)`.
## Interface
- `Classifier`, `buildRequest`, `parseAnswer` (PLAN.md). Teste: para cada classificador, a requisição tem as chaves e rótulos esperados e o parser lê uma resposta enlatada (inclusive resposta malformada → erro tipado, não exceção solta).
## Não fazer
- Sem rede. Todo texto entra em `state` já mascarado pelo chamador (`mask`), e o teste verifica que `buildRequest` recusa texto > 4000 caracteres.
## Contexto
- `determinismo-e-placement.md` §2 e §4.

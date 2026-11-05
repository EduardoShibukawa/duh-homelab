---
type: task
mode: mvp
goal: "classifyBlocked mapeia o texto de BLOCKED/falha de gate para uma classe e uma ação, por regras de dados testadas com fixtures"
title: Classificador de BLOCKED
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: []
tier: free
touch: [src/blocked.ts, src/failure_rules.json, tests/blocked.test.ts, tests/fixtures/blocked/]
done_when: "bun test tests/blocked.test.ts"
tests_frozen: [tests/blocked.test.ts, tests/fixtures/blocked/scope_drift.txt, tests/fixtures/blocked/id_collision.txt, tests/fixtures/blocked/quota.txt, tests/fixtures/blocked/gate_false_positive.txt, tests/fixtures/blocked/contract_conflict.txt, tests/fixtures/blocked/missing_dep.txt, tests/fixtures/blocked/env_dependency.txt, tests/fixtures/blocked/other.txt]
pinga_task: T171
---
## Fazer
- `failure_rules.json`: lista `{class, action, pattern}` em ordem. Exemplos: `scope_drift` com `__pycache__|\\.pyc` → `retry_clean`; `id_collision` → `auto_unblock`; `usage limit|429` → `skip_tier`; `tests_frozen` alterado → `replan`; sem match → `other`/`notify`.
- Emite evento `gate.fail` com `classification`.
## Interface
- `BlockedClass`, `classifyBlocked` (PLAN.md). Teste: um fixture real redigido por classe (8 arquivos) → classe e ação exatas.
## Não fazer
- Sem LLM (Jev fica fora até o experimento).
## Contexto
- INTENT-0008; SPEC-0003 (`gate.fail.classification`).

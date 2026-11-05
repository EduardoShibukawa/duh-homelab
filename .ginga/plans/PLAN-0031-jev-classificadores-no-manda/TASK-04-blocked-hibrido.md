---
type: task
mode: padrao
goal: "classifyBlocked consulta o Jev quando a regra devolve other, e a ação segue a mesma tabela classe → ação"
title: classifyBlocked com Jev no resíduo
plan: PLAN-0031-jev-classificadores-no-manda
repo: manda
depends_on: [TASK-03-camada-hibrida]
tier: medium
touch: [src/blocked.ts, tests/blocked_jev.test.ts]
done_when: "bun test tests/blocked.test.ts tests/blocked_jev.test.ts"
tests_frozen: [tests/blocked_jev.test.ts]
---
## Fazer
- Nova `classifyBlockedAsync(text, ctx)`: roda `classifyBlocked` (regex do PLAN-0029). Se a classe não é `other`, devolve-a (a regra é o piso e não se pergunta ao Jev). Se é `other`, `classifyWith` pergunta ao Jev (`blocked`, texto mascarado) e mapeia a classe para a ação pela mesma tabela.
- `classifyBlocked` síncrona **não muda** (os testes do PLAN-0029 continuam verdes).
## Interface
- Teste com Jev falso: regra decide (Jev não chamado), resíduo → classe do Jev acima do limiar, abaixo do limiar → `other`/`notify`, modo `shadow` não muda a saída.
## Não fazer
- Só roda se o classificador `blocked` passou no PLAN-0030; senão, TASK `blocked` com esse motivo.
## Contexto
- PLAN-0029 TASK-07; INTENT-0008.

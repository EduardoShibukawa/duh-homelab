---
type: task
mode: padrao
goal: "buildHandoff inclui, em `### Learnings`, também as entradas em bullet `- TASK-NN (modelo): texto` do LEARNINGS.md (as 10 mais recentes, linhas de até 600 caracteres), depois das entradas estruturadas"
title: ginga handoff lê bullets de learnings
plan: PLAN-0038-learnings-que-funcionam
repo: ginga
depends_on: []
tier: free
touch: [src/handoff.ts, tests/handoff_bullet_learnings.test.ts]
done_when: "bun test tests/handoff_bullet_learnings.test.ts tests/handoff.test.ts tests/handoff_full.test.ts"
tests_frozen: [tests/handoff_bullet_learnings.test.ts]
---
## Fazer
- Em `src/handoff.ts`, `parseLearnings` continua devolvendo as entradas estruturadas na mesma ordem; acrescente, ao final da lista, as linhas que casam `^- TASK-\d+ \(.+?\): .+$` e têm até 600 caracteres (as maiores são ignoradas), no máximo as 10 últimas do arquivo.
- Sem nenhuma entrada de nenhum tipo, o handoff continua como hoje (sem a seção).
## Interface
- Teste via `buildHandoff(root, {plan})` com um bundle temporário (use `tests/fixtures/handoff-session/bundle` como base de formato): LEARNINGS só com bullets → o markdown contém os bullets; com estruturado + bullets → estruturados primeiro; 12 bullets → só os 10 últimos; um bullet de 700 chars → ausente; arquivo sem nenhuma entrada → sem `### Learnings`. Testes antigos de handoff verdes.
## Não fazer
- Não alterar o lint nem `learning promote` (só entradas estruturadas).
## Contexto
- `ginga/src/handoff.ts:68-87` (`parseLearnings`) e `:236-305`.

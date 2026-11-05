---
type: task
mode: mvp
goal: "A triagem escolhe a trilha por critérios determinísticos e só permite promover trilha pequena para feature"
title: Triagem que só promove
plan: PLAN-0011-verbos-api-auth
repo: ginga
depends_on: [TASK-02-cli-verbos]
tier: free
touch: [src/triage.ts, src/verbs/triage.ts, src/verbs/registry.ts, src/verbs/write.ts, tests/triage.test.ts, tests/cli_verbs.test.ts]
done_when: "bun test tests/triage.test.ts tests/cli_verbs.test.ts"
tests_frozen: [tests/triage.test.ts, tests/cli_verbs.test.ts]
pinga_task: T123
---
## Fazer
- `intent new` roda a triagem: flag do usuário, nº de arquivos/impact (via `manda context impact`, se houver), contrato novo; na dúvida → feature.
- Verbo `triage promote <PLAN>` (pequena → feature: cria SPEC draft e liga o PLAN). Não existe `demote`; pedir feature → pequena dá exit 2.
## Não fazer
- Sem LLM nesta versão (o desempate por LLM barato fica para depois).
## Contexto
- Doc 02 §4 (trilhas), doc 02 §5 ("Triagem não rebaixa").

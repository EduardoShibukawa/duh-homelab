---
type: task
mode: mvp
goal: "A skill handoff na fonte única passa no ginga lint e o ginga install --dry-run lista a projeção para Claude, opencode e Pi sem tocar entrada alheia"
title: Skill handoff + projeção
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T153
depends_on: [TASK-11-handoff-sessao]
tier: free
touch: [skills/handoff/SKILL.md, skills/handoff/scripts/handoff.ts, skills/handoff/references/formato.md, tests/skill_handoff.test.ts]
done_when: "bun test tests/skill_handoff.test.ts"
tests_frozen: [tests/skill_handoff.test.ts]
---
## Fazer
- `SKILL.md` (`name: handoff`, `description`): instrui o modelo a (1) escrever `notes` com decisões, preferências e hipóteses, (2) rodar `ginga handoff --open`, (3) encerrar o turno. `scripts/handoff.ts` chama a CLI e imprime `{path, tokens, open}`.
## Interface
- Teste: frontmatter da skill válido; `ginga install --dry-run` com HOME temporário lista os 3 destinos e não altera arquivo existente de outra skill.
## Não fazer
- Não instalar no HOME real.
## Contexto
- Doc 11 §3 ("Skill única", proposta TASK-12 de lá); a fonte vive no repo ginga, que o `ginga install` projeta. SPEC-0002 (draft) para o resto das skills.

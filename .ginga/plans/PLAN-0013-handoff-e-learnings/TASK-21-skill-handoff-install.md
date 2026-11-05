---
type: task
mode: mvp
goal: "O `ginga install` projeta a skill `handoff` a partir de `<source>/skills/` (fonte única do repo ginga, além do legado `<source>/.pi/skills/`): o --dry-run lista os 3 destinos e o --apply instala de fato a skill em `.claude/skills/<nome>/`, `.config/opencode/skills/<nome>/` e `.pi/agent/skills/<nome>/` do HOME, idempotente e sem tocar skill alheia"
title: Skill handoff projetada de skills/ do repo e instalada no --apply
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T311
depends_on: [TASK-14-skill-handoff]
tier: free
touch: [src/install/install.ts, tests/skill_handoff_install.test.ts]
done_when: "bun test tests/skill_handoff_install.test.ts"
tests_frozen: [tests/skill_handoff_install.test.ts]
---
## Achado do judge (gate 2026-10-31T18:59, exit 11)
- TASK-14: `src/install/install.ts:247` `projectSkillsOutput` lê só `<source>/.pi/skills` (não `skills/` do repo ginga) e só imprime no dry-run; o `--apply` não instala a skill. O teste congelado passa só copiando a skill para a fonte falsa.

## Fazer
- Nova função `sourceSkills(source)` em `src/install/install.ts`: união dos nomes de skills (dirs com `SKILL.md`) de `<source>/skills/` e `<source>/.pi/skills/`. `projectSkillsOutput(source)` usa essa união (mantém o output `=== skills ===` com as 3 linhas por skill).
- Dry-run: imprime a projeção quando há skills em qualquer uma das duas pastas (hoje a condição é `hasPiSkills`, ligada só a `.pi/skills`).
- `--apply`: instala cada skill nos 3 destinos do HOME real (`opts.home`): `.claude/skills/<nome>/`, `.config/opencode/skills/<nome>/`, `.pi/agent/skills/<nome>/` — cópia recursiva idempotente (2º apply não duplica nem falha). Se o destino já existe com `SKILL.md` de conteúdo diferente (skill alheia), pula com aviso no stderr e não toca. Deve rodar nos dois caminhos do apply (o early-return sem dirtyFiles e o caminho principal após escrever os alvos).
- Não gating novo nos adaptadores pi/hermes/tuios: `sourceHasPiSkills` continua lendo só `.pi/skills` (suíte congelada da T12 depende disso).

## Interface (teste RED tests/skill_handoff_install.test.ts)
- Fonte temporária com `skills/handoff` (cópia de `ROOT/skills/handoff`) + `.claude-plugin/marketplace.json` mínimo (`name: pi-harness-local`) e SEM `.pi/skills`: `installCmd({mode:"dry-run", home, env})` exit 0 e stdout lista 3 destinos com `skills/handoff`; nada escrito no home.
- `installCmd({mode:"apply", home, env})` após o dry-run: exit 0 e existem `<home>/.claude/skills/handoff/SKILL.md`, `<home>/.config/opencode/skills/handoff/SKILL.md`, `<home>/.pi/agent/skills/handoff/SKILL.md` com o mesmo conteúdo da fonte.
- Idempotência: 2º dry-run+apply → mesma árvore (skills não duplicadas), skill alheia preexistente (`.claude/skills/outra/SKILL.md`) intacta.
- Legado: fonte com `.pi/skills/handoff` (sem `skills/`) continua listada no dry-run (3 destinos).

## Não fazer
- Não alterar `tests/skill_handoff.test.ts` (frozen) nem nenhum outro teste congelado; não instalar nada no HOME real (só HOME temporário nos testes).
- Não registrar skills no manifest de revert (fora do escopo); não mudar adaptadores.

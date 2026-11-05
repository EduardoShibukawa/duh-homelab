---
type: task
mode: mvp
goal: "Correções do judge 2026-10-31T22:35 em src/install/install.ts: (a) o 2º --dry-run após --apply imprime nada de skills (projeção idempotente, só destinos pendentes) e o --revert remove as skills instaladas pelo apply; (b) a guarda A2 não trata ponteiro `owned` sob prefixo `append` como homônima (preciso para a TASK-22 declarar /hooks/Stop e /hooks/UserPromptSubmit com hook alheio preexistente)"
title: install.ts — dry-run/revert de skills idempotentes + guarda A2 sob append
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T313
depends_on: [TASK-21-skill-handoff-install, TASK-22-adapter-claude-install-real]
tier: free
touch: [src/install/install.ts, tests/install_dryrun_guard.test.ts]
done_when: "bun test tests/install_dryrun_guard.test.ts tests/install/adapters.test.ts"
tests_frozen: [tests/install_dryrun_guard.test.ts]
---

# TASK-23-install-dryrun-guard-correcoes.md → T313

Contrato: .ginga/plans/PLAN-0013-handoff-e-learnings/TASK-23-install-dryrun-guard-correcoes.md (não mudar goal/touch/done_when).
Achados do judge 2026-10-31T22:35 (gate exit 11): TASK-21 regrediu — `projectSkillsOutput` lista as skills sempre no dry-run, então o 2º --dry-run após apply imprime `=== skills ===` (tests/install/adapters.test.ts T13 idempotência passa na main e falha no HEAD); e a TASK-22 precisa que a guarda A2 não trate `/hooks/Stop` (owned sob prefixo `append` `/hooks`) como homônima quando já existe hook alheio no evento.

## Fazer
- `projectSkillsOutput(source, home?)`: com `home`, lista só os destinos ainda sem a skill instalada (`<home>/<dest>/<nome>/SKILL.md` ausente); se nada pendente, retorna `""`. O call site do dry-run passa `opts.home`. Sem `home` (chamada legada), comporta-se como antes.
- `--revert`: após restaurar o manifest, remove do HOME as skills instaladas pelo apply — dir em `.claude/skills`, `.config/opencode/skills`, `.pi/agent/skills` cujo `SKILL.md` tem bytes idênticos ao da fonte (`removeProjectedSkills`). Skill alheia (SKILL.md diferente) e symlink do adaptador pi ficam intactos. Com isso o T13 volta a passar no passo 5 (revert devolve a árvore anterior).
- Guarda A2 (`checkForeign`): no laço de homônima, pular ponteiros `owned` sob prefixo de `append` do próprio arquivo (o comentário já diz "nos prefixos de append não há checagem de homônima", §A.4). O acréscimo sob `/hooks` continua só-`+` e registrado no manifest via `appendKeyPaths`.
- Nada no HOME real; só HOMEs temporários nos testes.

## Interface (teste RED tests/install_dryrun_guard.test.ts)
- Fonte temp com `skills/handoff` + marketplace mínimo; HOME temp: dry-run imprime `=== skills ===` com 3 destinos; apply exit 0 instala as 3 destinos; 2º dry-run imprime "" (sem `=== skills ===`); `--revert` exit 0 e os 3 destinos somem (skill alheia preexistente intacta).
- Fonte estilo repo ginga (skills/handoff + contrib/claude-mod-handoff) e HOME com hook `Stop` alheio em settings.json: dry-run exit 0, apply exit 0, settings.json tem o hook alheio preservado + `Stop`/`UserPromptSubmit` com `ginga handoff hook --runtime claude`.
- `tests/install/adapters.test.ts` (T13 congelado) passa de novo, inclusive idempotência do dry-run e revert.

## Não fazer
- Não alterar nenhum outro teste congelado (install.test.ts, adapters.test.ts, install_handoff_real.test.ts, skill_handoff_install.test.ts); não tocar adaptadores; não registrar skills no manifest de revert (a remoção é por comparação de bytes com a fonte); não instalar nada no HOME real.

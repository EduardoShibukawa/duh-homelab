---
type: spec
title: Skills e hooks no harness, entregues por sandbox
intent: INTENT-0009-skills-e-hooks
status: draft
bench: none
---
## Objetivo

Entregar skills e hooks a partir de uma fonte única (`.ginga/skills/` + `hooks.toml` + perfis de sandbox), com scripts determinísticos em TypeScript/bun e enforcement do lado do host, projetados para cada runtime pelo `ginga install/init`. Com isso, cada papel e cada TASK recebe só as skills de que precisa, com menos contexto e menos superfície, e os gates que o modelo não contorna ficam fora da sandbox.

Detalhe em [research/skills-e-hooks.md](../knowledge/research/skills-e-hooks.md) e [10-sandbox.md](../knowledge/design/ginga-revamp/10-sandbox.md).

## ACs

- [ ] Existe `.ginga/skills/<nome>/{SKILL.md, scripts/*.ts, references/, assets/}` como fonte única, com `hooks.toml` e perfis de sandbox em `project.toml` (`[sandbox.<runtime>]`).
- [ ] `ginga install`/`init` projeta a fonte para Claude, OpenCode e Pi (MVP) de forma idempotente, sem sobrescrever entrada alheia, com dry-run por padrão.
- [ ] Cada skill entra na sandbox como mount somente leitura (`--ro-bind .ginga/skills/<nome> /skills/<nome>`), com a lista de skills por papel definida no perfil.
- [ ] Os scripts TS rodam com bun dentro da sandbox e imprimem JSON no stdout; o modelo só decide quando chamá-los.
- [ ] Os hooks do host (fora da sandbox) aplicam: `bashRefusal` (git add -A/--no-verify/push force), teto de custo pré-chamada, `tests_frozen` ro-bind. O modelo não contorna porque não está na sandbox.
- [ ] Hooks dentro da sandbox (plugins do runtime) são opcionais e servem de conveniência, não de gate de segurança.
- [ ] O gerador não importa o ginga no manda: comunicação só por CLI/JSON (decisão 4 do revamp).
- [ ] `ginga lint` valida o formato do `SKILL.md` (name/description) e do `hooks.toml`.

## MVP

- **Skills (3):** `pinga` (validar frontmatter + unicidade de task id), `red-audit` (já existe), `gira-context` (já existe).
- **Hooks do host (3):** `bashRefusal` migrado do pi-harness para o ginga; teto de custo pré-chamada (corrigindo o bug que mede depois); `tests_frozen` ro-bind (já em `sandbox-done-when.sh`).

## Fora do escopo

- Hooks dentro da sandbox como gate de segurança.
- Marketplace de skills e skill-creator.
- Projeção automática para Codex, AGY e Hermes (depois do MVP).
- Scripts em Python (manter TS/bun por causa do toolchain já montado).
- Migração do `skill_catalog`/`skill_projection` do pi-harness além do que o PLAN-0006 já prevê.

## PLANs afetados

- **PLAN-0006** (install sai do pinga): migra `skill_catalog`/`skill_projection` para o ginga e ganha a projeção de skills/hooks.
- **PLAN-0008** (routing/budget/judge): teto de custo pré-chamada e hooks de policy.
- **PLAN-0015** (init/onboarding): `ginga init` gera skills/hooks por agente a partir do `project.toml`.
- **PLAN-0016** (code mode): a H3 passa a medir "CLI + skill com scripts determinísticos" como célula adicional (C+scripts vs. C sem scripts), para decidir se o `execute` é necessário.
path: .ginga/specs/SPEC-0002-skills-e-hooks.md
## Emenda 2026-10-28: hooks de git (repo), além dos hooks do host

- **AC:** `ginga hooks install` instala, de forma versionada, idempotente e encadeada (hk/lefthook/`core.hooksPath`), os hooks git de `.ginga/hooks/git/` nos repos listados em `hooks.toml`.
- **AC:** `ginga hooks check` / `ginga doctor` saem com código ≠ 0 quando há drift.
- **AC:** `reference-transaction` barra updates de `refs/heads/main` sem `MERGE_GATE=1` (merge, ff, reset). O merge é exclusivo do gate determinístico.
- Implementação: PLAN-0022 TASK-04.

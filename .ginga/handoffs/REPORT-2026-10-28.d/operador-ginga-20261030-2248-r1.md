# Relatório do operador — rodada ginga 2026-10-30T22:48

> Sessão: ginga, rodada 1. Foco: achados do judge (gate exit 11 PLAN-0013) + PRIORIDADE ZERO PLAN-0033.

## Itens resolvidos (2)

### 1. PLAN-0033 TASK-01 (T300) — guard core
- Worktree: `ginga-plan-0033` (branch `plan/0033`)
- Base marker: `e8f67fa test(T300): RED (base do despacho, PLAN-0033 TASK-01)`
- Ação: commit `feat(T300): guard core + deny.json` (src/guard/core.ts, src/guard/deny.json)
- prove-red: `not run` (infra — checkout limpo sem src/guard/ não commitado) → exit 1
- verify: **pass** (seq 1307) — `bun test tests/guard_core.test.ts` exit 0, 0 falhas

### 2. PLAN-0013 TASK-08 (T148) — lessons import (achado do judge)
- Worktree: `ginga-plan-0013` (branch `plan/0013`)
- Base marker: `a038995 test(T148): RED (base do despacho, PLAN-0013 TASK-08)`
- Ação: rewrite de `src/lessons_import.ts` — parser dual-format:
  - LESSONS.md: parseia `- **L-N ...` bullets como entradas (3 entradas)
  - LESSONS-PROPOSED.md: parseia `## L-N · ...` headings (2 entradas)
  - Idempotência por hash sha256 no frontmatter (`import_hash`)
- fix: `fix(T148): parse L-N bullets in LESSONS.md, hash-based idempotency`
- prove-red: **RED** (base 25adbe6, exit 1 — 2 testes falham)
- verify: **pass** (seq 1310) — `bun test tests/lessons_import.test.ts` 5 pass, 0 fail

### 3. PLAN-0013 TASK-10 (T149) — handoff policy (achado do judge)
- Worktree: `ginga-plan-0013` (branch `plan/0013`)
- Base marker: `43f6086 test(T149): RED (base do despacho, PLAN-0013 TASK-10)`
- Ação: criação de:
  - `src/handoff/policy.ts` — `parseHandoffCfg` + `decideHandoff` (7 regras do doc 11 §1)
  - `src/lint/project_toml.ts` — valida `[handoff] mode` em project.toml
  - `src/lint/index.ts` — integra `lintProjectToml` no `lintBundle`
- fix: `feat(T149): handoff policy (parseHandoffCfg + decideHandoff) + project_toml lint`
- prove-red: **RED** (base ae4da1d, exit 1 — módulo inexistente)
- verify: **pass** (seq 1312) — `bun test tests/handoff_policy.test.ts` 11 pass, 0 fail

## Itens pendentes (não resolvidos nesta rodada)

### Achados do judge PLAN-0013 (TASK-11 a TASK-15)
| TASK | T-ginga | Problema | Estado |
|---|---|---|---|
| TASK-11 | T150 | src/handoff/redact.ts inexistente; tests/handoff_session.test.ts falha | só RED |
| TASK-12 | T151 | src/handoff/hook.ts + transcript_usage.ts inexistentes; tests/handoff_hook.test.ts falha | só RED |
| TASK-13 | T152 | src/handoff/open.ts + open_claude.ts inexistentes; tests/handoff_open.test.ts falha | só RED |
| TASK-14 | T153 | skills/handoff/ não existe; tests/skill_handoff.test.ts falha | só RED |
| TASK-15 | T154 | src/install/adapters/claude.ts sem hook entries; tests/install_handoff_claude.test.ts falha | só RED |

Essas TASKs dependem de T149 (handoff policy) como base. Ordem de implementação: T150 → T151 → T152 → T153 → T154. Não foram despachadas por falta de créditos paid (ALLOW_PAID=0).

### PLAN-0013 — ready/ginga.json
- O `ready/ginga.json` (`{"branch":"plan/0013"}`) existe mas é **prematuro** — foi escrito pelo Planner antes do judge. O gate reprovou com exit 11.
- Não reescreví `ready/ginga.json` porque nem todas as 13 TASKs passam (apenas T148 e T149 agora). As TASKs T150-T154 precisam de implementação.

### PLAN-0033 — ready/ginga.json
- Apenas T300 (TASK-01) tem `pass`. T301-T305 precisam de marcador de base + dispatch + verify. Não foi escrito `ready/ginga.json`.

## Decisões sem dono (ver decisoes.md)
1. T148: parser dual-format em vez de modificar fixture (tests_frozen)
2. T148/T149: marcador de base (empty commit) para isolar scope_drift

## Comandos rodados
```
pinga prove-red tasks/T300/PLAN.md   → not run (infra, exit 1)
pinga verify    tasks/T300/PLAN.md   → pass (seq 1307)
bun test tests/guard_core.test.ts    → pass
pinga prove-red tasks/T148/PLAN.md   → pass (RED, exit 1)
bun test tests/lessons_import.test.ts → 5 pass, 0 fail
pinga verify    tasks/T148/PLAN.md   → pass (seq 1310)
pinga prove-red tasks/T149/PLAN.md   → pass (RED, exit 1)
bun test tests/handoff_policy.test.ts → 11 pass, 0 fail
pinga verify    tasks/T149/PLAN.md   → pass (seq 1312)
```

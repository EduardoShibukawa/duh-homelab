# duh-homelab — Multi-Repo Workspace Orchestration

> **Start every session at [`.ginga/index.md`](.ginga/index.md)**: work board (INTENT/SPEC/PLAN/TASK), what is ready to pick up, what is waiting on the owner, and the model routing in `.ginga/models/ROUTING.md`.

This workspace coordinates sibling repositories (`p-inga/`, `pi-harness/`, `gira-g/`, `spring-petclinic-modern/`).
All agent sessions (Claude Code, Pi, OpenCode, Hermes, Codex, Antigravity) are strictly governed by **P-Ingá Formal Verification** and **Gira-G Middleware**.

## Transition (G-Ingá revamp, 2026-10-27)

- **Workspace work** (this root, `.ginga/`): follows the new convention, INTENT → SPEC → PLAN → TASK (see `.ginga/knowledge/design/ginga-revamp/04-artefatos.md`). The root is not a git repo, so its PLANs run without the pinga ledger.
- **Sibling repos** (`p-inga/`, `pi-harness/`, `gira-g/`): keep the current pinga flow (`tasks/T<N>/PLAN.md` → `prove-red` → `verify`, receipt status `pass`) until the migration PLAN of SPEC-0001 lands. Legacy `tasks/T<N>/` stay valid after it.
- **Gira is optional** (context port with `rg` + `git` fallback). Use it where it is available; its absence never blocks work.

## Sibling Repositories

| Repo | Stack | Role | Rules |
|---|---|---|---|
| `p-inga/` | Bun/TS | Formal Verification Harness, Invariant Enforcement (I1-I20), Immutable Ledger, Maestro | Governed by `AGENTS.md`, 25-line `PLAN.md`, `pinga verify` |
| `gira-g/` | Go, CLI `gira` | Semantic Context Middleware (AST slices, callgraphs, impact) + Living Docs | `gira-g/CLAUDE.md`, lefthook via `mise exec`, tags `vX.Y.Z` |
| `spring-petclinic-modern/` | Java/Maven | Dogfood benchmark target | `mvn test-compile surefire:test`, requires jdtls via mise |

## Mandatory P-Ingá Governance (All Code Modifications)

1. **Never edit code without a verified contract:**
   Before making any modification, create `tasks/T<N>/PLAN.md` (maximum 25 lines total, frontmatter with `mode`, `goal`, `done_when`, `touch`).
2. **Prove RED on baseline:**
   ```bash
   pinga prove-red tasks/T<N>/PLAN.md
   ```
3. **Surgical edits only:**
   Use AST operations via `gira outline` / `gira read` / `gira write` or localized diffs. Do not rewrite large files.
4. **Formally verify & seal receipt:**
   ```bash
   pinga verify tasks/T<N>/PLAN.md
   ```
   Only commits backed by a `pass` receipt in `ledger.db` are accepted.
5. **Audit ledger:**
   ```bash
   pinga ledger verify
   ```

## Available Skills

Use the `/pinga` skill for verification workflows and `/red-audit` for adversarial auditing and AST repairs.
Run `pinga doctor` to verify harness health.

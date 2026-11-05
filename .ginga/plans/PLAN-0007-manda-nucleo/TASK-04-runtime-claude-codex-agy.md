---
type: task
mode: padrao
goal: "Adapters claude, codex e agy no runtime port; codex recusado como executor"
title: Adapters claude, codex, agy
plan: PLAN-0007-manda-nucleo
repo: manda
pinga_task: T4
depends_on: [TASK-03-runtime-pi-opencode]
tier: medium
touch: [src/runtime/claude.ts, src/runtime/codex.ts, src/runtime/agy.ts, src/runtime/index.ts, tests/runtime_claude_codex_agy.test.ts, tests/fixtures/runtime/]
done_when: "bun test tests/runtime_claude_codex_agy.test.ts"
tests_frozen: [tests/runtime_claude_codex_agy.test.ts, tests/fixtures/runtime/claude-ok.json, tests/fixtures/runtime/claude-error.json, tests/fixtures/runtime/codex-ok.jsonl, tests/fixtures/runtime/codex-turn-failed.jsonl, tests/fixtures/runtime/agy-success.json, tests/fixtures/runtime/agy-invalid-model.json]
---
## Fazer
- Portar `ClaudeCodeTaskRunner` (l. 541) + `parseClaudeOutput` (l. 488), `CodexTaskRunner` (l. 905) + `parseCodexOutput` (l. 729), `AgyTaskRunner` (l. 1119) + `parseAgyOutput` (l. 1071).
- Codex só nos papéis `planner|reviewer|judge` (`CODEX_ALLOWED_ROLES`, `checkCodexContract` l. 44); executor/worker **sempre** recusado; sem `PI_CODEX_ENABLED=1`, todos os papéis são recusados (paridade com `runners.ts`).
- `resolveRuntime(name)` em `src/runtime/index.ts`.
## Não fazer
- Não tocar em pi/opencode (TASK-03).
## Contexto
- `pi-harness/.pi/extensions/runners.ts`; `.ginga/models/ROUTING.md` ("Codex não é executor").

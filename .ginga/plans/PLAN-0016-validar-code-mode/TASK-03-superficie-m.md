---
type: task
mode: mvp
goal: "Um servidor MCP stdio expõe 12 tools de leitura sobre o snapshot, uma por operação"
title: Superfície M (MCP, uma tool por operação)
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-01-tasks-oracle]
tier: free
touch: [bench/code-mode/surfaces/m.ts, bench/code-mode/surfaces/mcp_stdio.ts, tests/code_mode/surface_m.test.ts]
done_when: "bun test tests/code_mode/surface_m.test.ts"
tests_frozen: [tests/code_mode/surface_m.test.ts]
pinga_task: T338
---
## Fazer
- Tools: `list_plans`, `read_plan`, `list_tasks`, `read_task`, `read_log`, `grep_logs`, `list_runs`, `read_run`, `count_in_runs`, `plan_deps`, `task_attempts`, `paid_attempts`. Cada uma lê o snapshot (raiz no argumento de boot), saída truncada em 8000 chars.
- `mcp_stdio.ts`: JSON-RPC 2.0 mínimo (`initialize`, `tools/list`, `tools/call`), sem dependência externa.
## Interface
- `M_TOOLS` (PLAN.md); `handle(req: { id: number; method: string; params?: any }, snapshot: string): unknown`. Teste: `tools/list` → 12 nomes; `tools/call list_plans` no fixture → os PLANs do fixture.
## Não fazer
- Nenhuma tool de escrita.
## Contexto
- PLAN.md ("Desenho", modo M).

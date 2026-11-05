---
type: task
mode: mvp
goal: "A skill do modo C explica como responder com bash, rg, jq e sqlite3, e agentConfig gera o opencode.json de cada modo"
title: Superfície C e config do agente por modo
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-03-superficie-m]
tier: free
touch: [bench/code-mode/surfaces/c-skill.md, bench/code-mode/config.ts, tests/code_mode/config.test.ts]
done_when: "bun test tests/code_mode/config.test.ts"
tests_frozen: [tests/code_mode/config.test.ts]
pinga_task: T339
---
## Fazer
- `c-skill.md`: onde fica cada coisa no snapshot e exemplos de `rg`, `jq` e `sqlite3`; formato da resposta (um bloco JSON no fim).
- `agentConfig(mode)`: M → só o MCP da TASK-03, bash desligado; C → bash ligado + a skill, sem MCP; X1/X2 → só o MCP da TASK-05, bash desligado; sempre `permission` sem escrita fora do workdir.
## Interface
- `agentConfig(mode: Mode, o: { snapshot: string; repoDir: string }): object` (JSON do `opencode.json`). Teste: para cada modo, as tools ligadas e desligadas esperadas; C inclui o caminho da skill.
## Não fazer
- Não instalar nada no `~/.config/opencode`.
## Contexto
- PLAN.md ("Desenho"); docs de config de agente do opencode.

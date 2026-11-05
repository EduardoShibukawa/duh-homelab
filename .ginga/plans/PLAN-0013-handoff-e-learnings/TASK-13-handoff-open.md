---
type: task
mode: mvp
goal: "ginga handoff --open --runtime claude monta o prompt de abertura, chama claude --bg -n ... --model ..., devolve o id em JSON e registra o evento handoff com trigger e depth"
title: Abertura da sessão nova (--open)
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T152
depends_on: [TASK-11-handoff-sessao]
tier: free
touch: [src/handoff/open.ts, src/handoff/open_claude.ts, tests/handoff_open.test.ts]
done_when: "bun test tests/handoff_open.test.ts"
tests_frozen: [tests/handoff_open.test.ts]
---
## Fazer
- Claude: `claude --bg -n "handoff:<plano>" --model <ROUTING> "<prompt de abertura + pedido original>"`, stdin fechado; lê o id impresso; `attachCmd = "claude attach <id>"`. Nunca `--resume`/`--fork-session`.
- Outros runtimes: a mesma interface devolve só o `attachCmd` impresso (`opencode -s`, `pi --name ...`), sem abrir.
## Interface
- `openSession(runtime: string, o: { handoffPath: string; userPrompt: string; model: string; cwd: string; spawn: Spawn }): Promise<{ ok: boolean; sessionRef: string | null; attachCmd: string }>`. Teste: spawn falso → argv contém `--bg` e não contém `--resume` nem `--fork-session`; evento `handoff` com `trigger` e `depth`.
## Não fazer
- Não fechar a sessão antiga.
## Contexto
- Doc 11 §3, linha do Claude (proposta TASK-11 de lá).

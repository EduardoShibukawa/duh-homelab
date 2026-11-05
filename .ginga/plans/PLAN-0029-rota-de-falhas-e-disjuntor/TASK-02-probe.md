---
type: task
mode: mvp
goal: "probe chama o modelo com 'responda só: ok' e stdin fechado e diz se ele está saudável"
title: Probe barato por modelo
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: []
tier: free
touch: [src/probe.ts, tests/probe.test.ts]
done_when: "bun test tests/probe.test.ts"
tests_frozen: [tests/probe.test.ts]
pinga_task: T168
---
## Fazer
- `probeArgv`: `opencode/*`, `opencode-go/*` → `opencode run --standalone -m <m> "responda só: ok"`; `pi:*` → `pi -p --model <m> "responda só: ok"`; `claude/*` → `claude -p --model <m> ...`. Timeout padrão 30 s; ok = exit 0 e saída contém `ok`.
## Interface
- `probeArgv`, `probe` (PLAN.md); `type Runner = (argv: string[], o: { stdin: "ignore"; timeout_ms: number }) => Promise<{ code: number; stdout: string }>`. Teste: argv por prefixo; runner falso com timeout → `ok: false`.
## Não fazer
- Nada de rede no teste.
## Contexto
- Armadilha do ROUTING: sem `< /dev/null` o `opencode run`/`pi -p` esperam o stdin.

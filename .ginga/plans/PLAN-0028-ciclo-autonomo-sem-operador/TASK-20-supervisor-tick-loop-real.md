---
type: task
mode: padrao
goal: "Fecha o achado grave do judge na TASK-07: parseSupervisorConfig lê [supervisor] mode (padrão tick na config, passado pelo serve ao Supervisor), o spawn usa childArgv em mode tick ('ginga tick --loop --repo <repo>') e src/tick.ts aceita --loop/--repo em vez de exit 2"
title: Supervisor liga o mode tick de ponta a ponta (achado do judge 2026-11-01, grave; substitui a TASK-19/T321 cujo teste frozen tinha bug do planejador)
plan: PLAN-0028-ciclo-autonomo-sem-operador
repo: ginga
depends_on: [TASK-07-supervisor-sem-operador]
tier: free
touch: [src/supervisor.ts, src/serve.ts, src/tick.ts, tests/supervisor_tick_mode_wiring.test.ts, tasks/T322/PLAN.md]
done_when: "bun test tests/supervisor_tick_mode_wiring.test.ts tests/supervisor_tick_mode.test.ts"
tests_frozen: [tests/supervisor_tick_mode_wiring.test.ts]
pinga_task: T322
---

## Achado do judge (2026-11-01T04:14, grave; ref TASK-07 + AC)
- `childArgv` (src/supervisor.ts:445) é código morto: `parseSupervisorConfig` não lê `[supervisor] mode` e nada chama `childArgv` no spawn.
- `runTick` (src/tick.ts) rejeita `--loop`/`--repo` como flag desconhecida (exit 2).
- AC do PLAN: "o supervisor troca o operador pelo `ginga tick --loop`" não cumprido.

## Fazer
1. `src/supervisor.ts`:
   - `parseSupervisorConfig` devolve também `mode: "tick" | "operador"`. Lê `[supervisor] mode = "…"`; **padrão `"tick"` na config** (o e2e TASK-08 já passou); `"operador"` só quando escrito; valor desconhecido cai em `"tick"`.
   - `SupervisorOptions` ganha `mode?: "tick" | "operador"`. No `runLane`: `const mode = opts.mode ?? "operador"` (a classe sem mode mantém o comportamento histórico — os testes legados do PLAN-0023 constroem Supervisor sem mode e esperam `lane.command`); no spawn, se `mode === "tick"` o comando é `childArgv({ mode, repo: lane.repo }).join(" ")`, senão `lane.command`.
2. `src/serve.ts`: passa `mode: supCfg.mode` nas opções do `new Supervisor(...)` (assim o serve, sem `mode` no project.toml, já roda no padrão tick).
3. `src/tick.ts` `runTick`: aceita `--loop`, `--repo <r>`, `--repo=<r>` (desconhecida continua exit 2; `--repo` sem valor também exit 2).
   - `--repo R` filtra a fila lida: só entradas com `plan === R || plan.startsWith(R)` (mesma regra do `queueHasPending` do supervisor), valendo para o laço por fases e o da fila.
   - `--loop`: repete passadas enquanto houver pendência claimável do repo (entrada `open`, sem `blocked_by`, e ainda claimável no `task_exec` — `dispatched`/lease válido não conta), dormindo `GINGA_TICK_LOOP_MS` (padrão 5000) entre passadas; sem pendência → exit 0. `GINGA_TICK_LOOP_MAX` (padrão 0 = sem limite) limita o nº de passadas. SIGTERM/SIGINT no modo loop → exit 0 (mata o filho ativo). Sem `--loop`, comportamento de hoje.

## Testes (tests_frozen novo: tests/supervisor_tick_mode_wiring.test.ts)
1. `parseSupervisorConfig("").mode === "tick"`; `mode = "tick"` → `"tick"`; `mode = "operador"` → `"operador"`; valor estranho → `"tick"`.
2. Supervisor com `mode: "tick"` spawna exatamente `ginga tick --loop --repo ginga`; com `mode: "operador"` spawna `lane.command`; **sem `mode` no construtor spawna `lane.command`** (padrão de classe = operador; o padrão tick vem da config via serve). Use um contador de pendência POR supervisor no teste.
3. `ginga tick --repo ginga --root <fixture>` sai 0 (não 2) e despacha só as entradas do repo `ginga` (fixture com PLAN-0001 e ginga/TASK-01; [commands] queue/dispatch stub). `--repo=ginga` também vale.
4. `ginga tick --loop --repo ginga --root <fixture>` com `GINGA_TICK_LOOP_MS=1` e 1 TASK open: despacha 1 vez, a pasada seguinte não tem nada claimável → exit 0. Flag desconhecida (`--bogus`) continua exit 2.

## Não fazer
- Não apagar o caminho do operador (`mode = "operador"` continua valendo; a classe sem mode também).
- Não alterar nenhum outro teste (nem tests/supervisor_tick_mode.test.ts); não criar scripts de depuração fora do touch (use /tmp).
- Não mudar a regra de claim/lease do tick (só o filtro de repo e o loop).
- Não reaproveitar a TASK-19/T321: o teste frozen dela tinha bug do planejador (contador compartilhado) e está blocked no ledger.

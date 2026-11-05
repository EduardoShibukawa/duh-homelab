---
type: task
mode: padrao
goal: "manda lane: paridade 2 com lane.sh/lane.env (operador claude/*, operator/executor_models + [supervisor.env], cota esgotada exit 4, sem progresso exit 3, posicional de rodadas)"
title: PLAN-0023 TASK-23 — paridade 2 do manda lane
plan: PLAN-0023-vigia-e-supervisor
repo: manda
depends_on: [TASK-15-vigia-followup-14b]
tier: free
pinga_task: T113
touch: [src/pipeline.ts, tests/pipeline_paridade2.test.ts, tasks/T113/PLAN.md]
done_when: "bun test tests/pipeline_paridade2.test.ts tests/pipeline_vigia.test.ts tests/pipeline_parity.test.ts tests/pipeline.test.ts"
tests_frozen: [tests/pipeline_paridade2.test.ts]
---

## Fazer (só `src/pipeline.ts`; espelhe `.ginga/bin/lane.sh` e `handoffs/lane.env`)
- (a) operador `claude/<m>`: `timeout 7200 claude -p --model <m> --permission-mode auto --output-format stream-json --verbose --append-system-prompt "lane:<nome>" "<prompt>"` (cwd = root), log em `handoffs/<nome>.log`; `opencode/*` segue `timeout 7200 opencode run --standalone --auto -m <m> --title <nome> <prompt>`. `killByPid` deve matar também o filho do `timeout` (grupo do pid e `pkill -P`).
- (b) `loadSupervisorConfig(root)`: `operatorModels` = `[supervisor] operator_models` ?? `models` ?? DEFAULT_MODELS; `executorModels` = `executor_models` (opcional); `env` = tabela `[supervisor.env]` (valores viram string). Mantenha `loadSupervisorModels`. Env do operador = `process.env` sem `MODELS`, + `MODELS=<executorModels.join(" ")>` se houver, + `[supervisor.env]`.
- (c) após o operador: log < 6000 B casando `/free usage limit|usage limit (reached|exceeded)|quota (exceeded|reached)/i` → `modelIndex+1`; `>= models.length` → `touch handoffs/.free-esgotado` e retornar exit 4; senão repetir a rodada (não consome rodada). Aguarde o fim da escrita do log (pump) antes de ler, com limite de 2 s.
- (d) estado = por `ready/<repo>.json` o sha da branch no repo + linhas `- worktree:` do backlog com seu HEAD + hash do `backlog-<repo>.md` + `effects`. Rodada com pendência, estado igual antes/depois, e operador não morto pelo vigia → exit 3 ("sem progresso"). `MANDA_FORCE_CONTINUE` continua desligando essa saída.
- (e) `main`: `manda lane <repo> [rodadas]` — 2º posicional numérico = rodadas (`--rounds` vence).
## Não fazer
- Não alterar `tests/pipeline_paridade2.test.ts` nem os outros testes de pipeline.

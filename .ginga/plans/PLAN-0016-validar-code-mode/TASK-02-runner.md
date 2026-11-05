---
type: task
mode: padrao
goal: "O runner executa cada trial num diretório novo com opencode --standalone e stdin fechado, mede tokens pelo session export e grava results.jsonl"
title: Runner de trials
plan: PLAN-0016-validar-code-mode
repo: ginga
depends_on: [TASK-01-tasks-oracle]
tier: medium
touch: [bench/code-mode/runner.ts, bench/code-mode/run.ts, tests/code_mode/runner.test.ts, tests/fixtures/code-mode/export.json]
done_when: "bun test tests/code_mode/runner.test.ts"
tests_frozen: [tests/code_mode/runner.test.ts, tests/fixtures/code-mode/export.json]
pinga_task: T337
---
## Fazer
- `runTrial`: copia o snapshot para um `mkdtemp`, grava a config do modo, roda `trialArgv(...)` pelo `spawn` injetado com stdin `/dev/null`, lê o `sessionID` da 1ª linha do JSON, roda `opencode session export --standalone <id>` e aplica `parseExport`; extrai a resposta (último bloco JSON do texto) e chama `verify`. Erro 429/5xx/timeout → `infra: true`, `reward: 0`.
- `run.ts --snapshot --plan piloto|principal|h2|h7 [--k N] [--cap-usd X]`: itera células, para quando o custo somado passa do teto, acrescenta cada `Trial` em `results.jsonl`.
## Interface
- `Mode`, `Trial`, `trialArgv`, `parseExport`, `runTrial` (PLAN.md); `type Spawn = (argv: string[], o: { cwd: string; stdin: "ignore" }) => Promise<{ code: number; stdout: string; stderr: string }>`. Teste: `parseExport` do fixture (export real redigido) → números exatos; `trialArgv("C", "opencode/glm-5.3-flash-free", "/w", "p")` → argv exato com `--standalone`; spawn falso com 429 → `infra: true`; teto de US$ 0,01 com trials de US$ 0,02 → para depois do 1º.
## Não fazer
- Não chamar modelo de verdade nos testes.
## Contexto
- `.ginga/bench/code-mode/captura-tokens.md` e `tokens.sh` (PLAN-0019): `session export` com `--standalone`.

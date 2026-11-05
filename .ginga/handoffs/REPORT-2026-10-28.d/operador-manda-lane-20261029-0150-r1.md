# operador manda lane 20261029-0150 r1
- Achados do judge: nenhum item não-ok em `plans/*/judge/manda.json` (PLAN-0023 pass em 36fd7ea).
- Backlog: único item aberto = bug plan_cmd com `ginga` no PATH → [x].
- TASK-29 / T114 (PLAN-0023, worktree manda-plan-0023, plan/0023): prove-red pass (base 0ad74b8), executor opencode/qwen3.8-flash 1 tentativa, `pinga verify` receipt pass (attempts 5, `--base 0ad74b8`).
- Causa: o staging plano não é um bundle `.ginga`; o `ginga lint` real acusa sempre erros relacionais e exige `intent` no PLAN. Correção: `--json` + só erros de frontmatter bloqueiam; prompt pede `intent`; preload `tests/setup.ts` + `bunfig.toml` deixa a suíte hermética.
- `bun test` (com ginga no PATH do host): 205 pass / 4 fail. As 4 falhas = `manda judge`/`pipeline`/`lane` sem args devolvendo 30 (guard de ancestral LLM) por eu rodar sob `claude -p`; não são regressão.
- `ready/manda.json` = {"branch":"plan/0023"}. Pendência do dono em decisoes.md (contrato frozen de plan_cmd × lint de bundle).

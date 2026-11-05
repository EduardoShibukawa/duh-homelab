---
type: task
mode: mvp
goal: "A CLI real aceita `ginga handoff --open [--runtime R] [--model M] [PLAN]`: grava o handoff, chama openSession e imprime JSON {path, tokens, open, sessionRef, attachCmd}; e skills/handoff/scripts/handoff.ts invoca a CLI com --open e parseia a saída (string) sem lançar erro"
title: Abertura da sessão nova na CLI (--open) + script da skill
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T310
depends_on: [TASK-13-handoff-open, TASK-14-skill-handoff, TASK-18-handoff-cli-sessao-correcao]
tier: free
touch: [src/verbs/handoff.ts, src/handoff/open.ts, src/handoff/open_claude.ts, skills/handoff/scripts/handoff.ts, tests/handoff_cli_open.test.ts]
done_when: "bun test tests/handoff_cli_open.test.ts"
tests_frozen: [tests/handoff_cli_open.test.ts]
---
## Achados do judge (gate 2026-10-31T17:34, exit 11)
- TASK-13: `src/handoff/open.ts` `openSession` passa em tests/handoff_open.test.ts, mas nenhum verbo chama `openSession` nem aceita `--open` (`src/verbs/handoff.ts` args). Goal "ginga handoff --open" não entregue.
- TASK-14: `skills/handoff/scripts/handoff.ts:13-15` usa `--open` inexistente e `res.stdout.split` sobre string (`.text()` devolve string) — lança erro.

## Fazer
- `HANDOFF_VERBS` (src/verbs/handoff.ts): declarar `{ name: "open", bool: true }` e `{ name: "model" }` nos args. Com `args.open === "true"`, após gravar o handoff chamar `openSession(runtime, { handoffPath: <abs>, userPrompt, model, cwd, spawn })` e devolver `{ path, tokens, open: result.ok, sessionRef, attachCmd }` (além de path/tokens/markdown). `runtime` padrão `claude`; `model` de `--model`/env `GINGA_MODEL` ou default desarma o spawn real só no teste (spawn injetado não existe na CLI — para runtime != claude o openSession não spawna; para claude o spawn real roda `claude`).
- `skills/handoff/scripts/handoff.ts`: chamar a CLI com `--open` e parsear a SAÍDA (string) — `res.split("\n")`, nunca `res.stdout.split`. Deve imprimir `{path, tokens, open}` em JSON e sair 0.
- Não mudar `src/cli.ts` (o parser genérico já cobre bool/valor); não tocar tests_frozen alheios (tests/skill_handoff.test.ts, tests/handoff_open.test.ts, tests/cli_verbs.test.ts).

## Interface (teste RED tests/handoff_cli_open.test.ts)
- CLI em fixture git com branch plan/NNNN: `ginga handoff --open --runtime opencode --json` → exit 0, JSON parseável com `open === true`, `attachCmd` contendo `opencode`, `path` existente no disco; evento `handoff` no events.jsonl.
- Script: com um shim `ginga` falso no PATH (imprime `path: ...`/`tokens: ...`), `bun skills/handoff/scripts/handoff.ts` → exit 0 e stdout JSON com `open: true`.

## Não fazer
- Não spawn real de `claude` no teste (use runtime != claude na CLI; no script o shim заменяем o binário).
- Não alterar a enumeração pública VERBS nem outros verbos.

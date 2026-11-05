---
type: task
mode: padrao
goal: "judge-run.sh usa o Gemini (`agy -p ... --mode plan`) como judge de outra família quando o Codex está sem cota, antes do fallback opencode/gpt-6-luna, com a mesma guarda de árvore"
title: judge com agy
plan: PLAN-0039-agy-nas-lanes
repo: duh-homelab
depends_on: [TASK-01-lane-e-dispatch]
tier: medium
touch: [.ginga/bin/judge-run.sh, .ginga/bin/tests/judge-agy.test.sh]
done_when: "bash .ginga/bin/tests/judge-agy.test.sh"
tests_frozen: [.ginga/bin/tests/judge-agy.test.sh]
---
## Fazer
- `judge-run.sh` (região das linhas ~30-40, onde hoje cai para `opencode/gpt-6-luna`): inserir antes dele `agy -p "$prompt" --model gemini-3.8-flash-high --mode plan` no `$wt`, com `timeout 1200`, log no mesmo arquivo, linha em `log.md` do PLAN (`Codex sem cota, fallback agy gemini-3.8-flash-high`), e respeitando `agy_blocked`/`agy_mark_quota`.
- A guarda existente (`git status` e HEAD iguais antes e depois) vale para o agy: escrita fora do que o agy guarda em `~/.gemini` faz o judge falhar.
- Aplicação: `.new` + teste + `bash -n` + `mv`, backup `judge-run.sh.bak-AAAA-MM-DD-agy`.
## Interface
- `judge-agy.test.sh` com `codex` e `agy` falsos no `PATH` e um repo git temporário: Codex falso sai com "usage limit" → o agy falso é chamado com `--mode plan` e `--model gemini-3.8-flash-high`; agy falso que escreve um arquivo no repo → judge falha (guarda); Codex ok → agy não é chamado; `bash -n` passa.
## Não fazer
- Não trocar o judge primário (Codex continua primeiro) nem o formato do veredito.
## Contexto
- INTENT-0014 item 3; `judge-run.sh` linhas 30 a 40.

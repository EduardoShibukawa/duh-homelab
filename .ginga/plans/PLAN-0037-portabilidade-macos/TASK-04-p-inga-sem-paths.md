---
type: task
mode: padrao
goal: "os scripts executáveis do p-inga deixam de ter caminho absoluto do autor e acham bun e o pinga pelo próprio local ou pelo PATH"
title: p-inga scripts sem caminho do autor
plan: PLAN-0037-portabilidade-macos
repo: p-inga
depends_on: []
tier: free
touch: [scripts/install-skills.sh, scripts/pinga-queue-watch.sh, tests/no_author_paths.test.ts]
done_when: "bun test tests/no_author_paths.test.ts"
tests_frozen: [tests/no_author_paths.test.ts]
---
## Fazer
- `scripts/install-skills.sh` (linhas ~14 e ~16): derive a raiz do repo de `$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)` e use `"$ROOT/bin/pinga.ts"` e `"$ROOT/.pinga/pinga-stable"`; sem `/home/shibuka`.
- `scripts/pinga-queue-watch.sh` (linha 6): `BUN` vem de `${BUN:-$(command -v bun)}`, com erro claro se vazio; sem `/home/shibuka`.
## Interface
- `tests/no_author_paths.test.ts`: lê os dois scripts e exige ausência de `/home/shibuka`; exige que `install-skills.sh` contenha `BASH_SOURCE` e que `pinga-queue-watch.sh` contenha `command -v bun`; `bash -n` em cada um sai 0.
## Não fazer
- Não tocar em `scripts/queue-unblock-prompt.md` (prompt histórico do autor), em `docs/`, em `tasks/` nem nos testes que têm `not.toContain("/home/shibuka")`.
## Contexto
- `p-inga/scripts/`.

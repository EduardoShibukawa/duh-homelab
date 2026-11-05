---
type: task
mode: padrao
goal: "verify, prove-red e judge aceitam --root <repo>: git root e cwd do done_when vêm do repo indicado"
title: --root para TASKs fora do repo-alvo
plan: PLAN-0005-pinga-task-e-plan
repo: p-inga
pinga_task: T65
depends_on: [TASK-03-task-ref-resto]
tier: medium
touch: [src/cli.ts, src/verify.ts, src/prove.ts, src/judge.ts, tests/root_flag.test.ts]
done_when: "bun test tests/root_flag.test.ts tests/verify.test.ts"
tests_frozen: [tests/root_flag.test.ts]
---
## Fazer
- Sem `--root`: igual a hoje (`git rev-parse` a partir da pasta do arquivo).
- Com `--root R`: `repoRoot = R` (precisa ser repo git, senão exit 2), `touch`/`tests_frozen` relativos a R, escopo do ledger pelo repo R.
## Não fazer
- Não mudar o formato do receipt além do `repo` correto.
## Contexto
- `verify.ts:99-111` (gitRoot), `verify.ts:356` (`cwd: repoRoot`), `prove.ts` (`findRedBase`), USAGE em `cli.ts:45-49`.

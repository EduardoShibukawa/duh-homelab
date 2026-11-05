---
type: task
mode: mvp
goal: "Corrigir o argv e a inferência do PLAN na CLI de handoff em modo sessão: --from-session, --notes de arquivo, branch/state.db/log.md"
title: Correção da CLI de handoff em modo sessão
plan: PLAN-0013-handoff-e-learnings
repo: ginga
pinga_task: T308
depends_on: [TASK-11-handoff-sessao]
tier: free
touch: [src/cli.ts, src/handoff.ts, src/verbs/handoff.ts, tests/handoff_cli_session.test.ts]
done_when: "bun test tests/handoff_cli_session.test.ts"
tests_frozen: [tests/handoff_cli_session.test.ts]
---
## Fazer
- O flag real `--from-session` preenche `from_session`; `--trigger`, `--runtime` e `--json` continuam válidos.
- `--notes <arquivo>` lê o arquivo e passa o texto ao handoff; a redaction continua em `buildHandoff`.
- Sem `<PLAN>`, inferir pela branch `plan/NNNN`, depois pelo PLAN ativo no `state.db`, depois pelo `log.md` mais recente; o PLAN inferido vai para o frontmatter e o evento.
## Interface
- Teste pela CLI real: branch `plan/0013` → `PLAN-0013`; `task_exec` no state.db → o mesmo PLAN; `log.md` mais recente → o PLAN correspondente. `--notes` não pode vazar caminho nem segredo.
## Não fazer
- Não alterar os testes congelados da TASK-11; não implementar ainda `--open` nem o subverbo `hook` (TASKs 19/20).
## Contexto
- Achado do judge de 2026-10-31: os flags e a inferência do PLAN não estavam ligados ao argv real.

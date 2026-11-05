---
type: task
mode: padrao
goal: "ginga ready write grava ready/<repo>.json ({branch,by:{pid,cmd},at}) só quando todas as TASKs do PLAN para o repo estão done/pass no pinga queue da worktree"
title: ginga ready write (ready_writer, follow-up 10 do PLAN-0023)
plan: PLAN-0025-hooks-llm-e-stale-ready
repo: ginga
depends_on: [TASK-02-watch-stale-ready]
tier: free
pinga_task: T103
touch: [src/ready.ts, src/cli.ts, tests/ready_write.test.ts, tasks/T103/PLAN.md]
done_when: "bun test tests/ready_write.test.ts"
tests_frozen: [tests/ready_write.test.ts]
---
## Fazer
- Novo `src/ready.ts` com `readyWriteCmd(args: string[]): number` e rota `ginga ready write --root R --plan <pasta-do-PLAN> --repo <repo> --branch <branch> [--worktree DIR]` em `src/cli.ts` (mesmo estilo das rotas `hooks`/`watch`).
- Lê `<root>/.ginga/plans/<plan>/TASK-*.md`, coleta o `pinga_task` das TASKs cujo `repo:` (frontmatter) é o repo pedido. Worktree padrão: `<root>/<repo>-plan-<NNNN>` com NNNN extraído de `PLAN-<NNNN>-...`. Executa `pinga queue --json --root <worktree>` (pinga do PATH; JSON com `tasks[].task/state`).
- Se alguma TASK coletada não estiver `state: "done"` (ou não aparecer na fila): exit 1, stderr lista as pendentes, NÃO grava. Caso contrário grava `<root>/.ginga/plans/<plan>/ready/<repo>.json` (criando `ready/`) com `{"branch":..., "by":{"pid":<process.pid>,"cmd":<process.argv.join(" ")>}, "at":<ISO-8601>}` e sai 0.
## Não fazer
- Não tocar `src/watch/*` nem tests_frozen existentes.

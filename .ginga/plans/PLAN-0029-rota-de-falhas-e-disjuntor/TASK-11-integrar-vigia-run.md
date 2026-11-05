---
type: task
mode: padrao
goal: "manda run integra a vigia da tentativa: observa o processo vivo, mata travado pelo pid, registra a recusa no disjuntor compartilhado e troca de modelo"
title: O manda run liga a vigia da tentativa
plan: PLAN-0029-rota-de-falhas-e-disjuntor
repo: manda
depends_on: [TASK-09-vigiar-tentativa]
tier: medium
touch: [src/run.ts, src/attempt_watch.ts, src/run_state.ts, tests/attempt_watch_run.test.ts]
done_when: "bun test tests/attempt_watch_run.test.ts"
tests_frozen: [tests/attempt_watch_run.test.ts]
pinga_task: T308
---
## Fazer
- `src/run.ts` executa `watchAttempt` junto ao adapter, amostra `/proc` + mudanças da worktree, faz probe e mata a árvore do pid quando a tentativa está travada.
- A recusa final abre o disjuntor no `state.db` compartilhado; o sucesso fecha; a troca seleciona o próximo modelo livre pela escada.
- `src/attempt_watch.ts` recebe a rota real da TASK e delega o evento `attempt` ao fluxo principal, evitando evento duplicado.

## Teste
- `manda run` com primeira tentativa recusada e segunda bem-sucedida: `opencode/f1` fica aberto no `state.db`, `opencode/f2` fecha e o primeiro `attempt` informa `next_model=opencode/f2`.

---
type: task
mode: padrao
goal: "manda merge/judge/pipeline/lane recusam (exit 30) com ancestral agente LLM, igual ao merge-gate.sh"
title: guarda de processo no manda (ancestral LLM)
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T101
touch: [src/llm_guard.ts, src/judge_run.ts, src/cli.ts, bin/manda.ts, tests/llm_guard.test.ts, tasks/T101/PLAN.md]
done_when: "bun test tests/llm_guard.test.ts"
tests_frozen: [tests/llm_guard.test.ts]
---

## Fazer
- Criar `src/llm_guard.ts` exportando `findLlmAgent(startPid, procRoot = "/proc")` → `{refused, pid?, label?}` (argv[0]/argv[1], pulando `timeout` com flags/números; `*opencode* run`, `pi`, `claude -p`, `codex exec`). Mover a lógica de `insideLlmAgent` de `src/judge_run.ts` para lá; `judge_run.ts` reexporta `insideLlmAgent` (comportamento igual).
- `src/cli.ts`: nova `export function main(args)` que, para `merge|judge|pipeline|lane`, recusa com `{"error":"recusado: chamado de dentro de um agente LLM (pid N: x); só o pipeline.sh pode"}` e exit 30; senão chama `run`. `bin/manda.ts` e o bloco `import.meta.main` usam `main`. `run()` NÃO ganha a guarda (a suíte roda in-process sob o operador).
## Não fazer
- Não alterar `tests/llm_guard.test.ts` nem `tests/merge_gate.test.ts`.

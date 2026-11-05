---
type: task
mode: padrao
goal: "findLlmAgent anda os ancestrais por `ps` quando não há /proc, em vez de devolver refused:false em silêncio"
title: manda guard de agente LLM sem /proc
plan: PLAN-0037-portabilidade-macos
repo: manda
depends_on: []
tier: free
touch: [src/llm_guard.ts, tests/llm_guard_fallback.test.ts]
done_when: "bun test tests/llm_guard_fallback.test.ts tests/llm_guard.test.ts"
tests_frozen: [tests/llm_guard_fallback.test.ts]
---
## Fazer
- Em `src/llm_guard.ts`, `findLlmAgent(startPid, procRoot = "/proc", ps?)`: se `procRoot` não existe como diretório, ler cmdline e ppid de cada pid por `ps` (parâmetro injetável `ps: (pid: number) => { ppid: number; argv: string[] } | null`; padrão: `Bun.spawnSync(["ps","-o","ppid=,command=","-p",String(pid)])`, separando o 1º número e dividindo o resto por espaços).
- A lógica de recusa (opencode run, pi, claude -p, codex exec, `timeout` com flags) é a mesma: extraia o miolo para uma função usada pelos dois caminhos, sem copiar.
- `ps` devolvendo `null` ou erro → trata como fim da cadeia (`refused:false`), como hoje.
## Interface
- Teste `tests/llm_guard_fallback.test.ts`: `procRoot` inexistente + `ps` falso com cadeia `5 → 4 → 3 → 1` onde o pid 4 é `["/x/opencode","run","t"]` → `{refused:true,pid:4,label:"opencode"}`; cadeia sem agente → `refused:false`; `timeout 30 pi` → recusa com label `pi`; ciclo (ppid aponta para si) não trava.
- `tests/llm_guard.test.ts` (caminho `/proc` com diretório falso) continua verde.
## Não fazer
- Não alterar quem chama `findLlmAgent`, nem a lista de agentes recusados.
## Contexto
- `manda/src/llm_guard.ts` inteiro (≈75 linhas). Espelha `.ginga/bin/merge-gate.sh`.

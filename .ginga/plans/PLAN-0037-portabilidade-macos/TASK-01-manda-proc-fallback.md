---
type: task
mode: padrao
goal: "procCpuTicks e o vigia de CPU funcionam sem /proc: se /proc/<pid>/stat não existe, usam `ps -o time= -p <pid>` e convertem para ticks de 100/s"
title: manda amostra CPU sem /proc
plan: PLAN-0037-portabilidade-macos
repo: manda
depends_on: []
tier: free
touch: [src/proc_sample.ts, tests/proc_fallback.test.ts]
done_when: "bun test tests/proc_fallback.test.ts tests/proc_sample.test.ts"
tests_frozen: [tests/proc_fallback.test.ts]
---
## Fazer
- Em `src/proc_sample.ts`, `procCpuTicks(pid)` ganha um segundo parâmetro opcional de injeção `deps?: { procRoot?: string; ps?: (pid: number) => string }` (padrão: `/proc` e um `Bun.spawnSync(["ps","-o","time=","-p",String(pid)])`).
- Se `<procRoot>/<pid>/stat` não existe (ENOENT do diretório `procRoot`), usar o `ps`: a saída é `[[dd-]hh:]mm:ss[.cc]`; converter para segundos e multiplicar por 100 (`CLK_TCK`). `ps` sem saída ou código ≠ 0 → lançar (pid morto), igual ao comportamento atual.
- Pid inexistente com `/proc` presente continua lançando.
## Interface
- Teste `tests/proc_fallback.test.ts`: com `procRoot` apontando para um diretório vazio e um `ps` falso devolvendo `"01:02.50"` → 6250; `"1-02:03:04"` → 9_378_400 (1 dia, 2h, 3min, 4s, ×100); `ps` falso vazio → lança; com um `procRoot` falso contendo `<pid>/stat` válido, o valor vem do arquivo e o `ps` falso não é chamado.
- Os testes atuais de `procCpuTicks` (`tests/proc_sample.test.ts`) continuam verdes sem argumento extra.
## Não fazer
- Não mudar `procSampler`/`watchCfg`, nem o CLK_TCK, nem o resto do arquivo.
## Contexto
- `manda/src/proc_sample.ts` linha 36 (`procCpuTicks`), usado na linha ~93 por `procSampler`.

---
type: task
mode: padrao
goal: "decideToolCall decide por resolvePath e matchesAny (scope_path.ts), sem casos fixos do teste, de modo que frozen 'docs/**' bloqueia docs/x.ts e todo caminho fora da raiz é path_escape"
title: scope_guard usa resolvePath e matchesAny
plan: PLAN-0032-guarda-de-escopo-no-pi
repo: manda
depends_on: [TASK-01-decisao-de-escopo, TASK-02-casamento-de-caminho]
tier: medium
pinga_task: T166
touch: [src/runtime/scope_guard.ts, tests/scope_guard_paths.test.ts, tests/scope_guard.test.ts]
done_when: "bun test tests/scope_guard_paths.test.ts tests/scope_guard.test.ts tests/scope_path.test.ts"
tests_frozen: [tests/scope_guard_paths.test.ts, tests/scope_path.test.ts]
---
## Fazer
- **Corrigir a fixture contraditória de `tests/scope_guard.test.ts`** (única edição permitida nele): a linha 7 tem `touch: ["src/target.ts", "src/**", ...]`, mas o teste da linha 22 espera `src/other.ts` → `outside_touch`; `src/**` cobre `src/other.ts`, então nenhuma implementação correta passa (foi o que levou à implementação com casos fixos). Trocar `"src/**"` por `"src/sub/**"` na fixture e, na linha 17, `src/any/deep.ts` por `src/sub/deep.ts`. Nada mais muda nesse arquivo.
- Em `decideToolCall`, para `edit`/`write`: `resolvePath(scope.root, input.path)`; `ok:false` → `{allow:false, rule:"path_escape"}`. Com `rel`: `matchesAny(rel, scope.frozen)` → `frozen` (vence o `touch`); senão `!matchesAny(rel, scope.touch)` → `outside_touch`; senão `allow`.
- Apagar de `scope_guard.ts` o casamento próprio (`normalizePath`, `hasPathEscape`, `matchesPattern`, `isPathInList` e qualquer exceção por prefixo de teste ou caminho fixo como `/etc/passwd`). Manter o que é de `bash` (`bash_refused`) e o formato do `reason`.
- Nenhum caminho, nome de diretório ou padrão do teste pode aparecer no código de `scope_guard.ts`.
## Interface
- Assinaturas de `PLAN.md` inalteradas. `tests/scope_path.test.ts` (TASK-02) continua verde sem edição. `tests/scope_guard.test.ts` (TASK-01) **tem uma fixture contraditória** e recebe a correção mínima abaixo.
- `tests/scope_guard_paths.test.ts` (RED por asserção, root = diretório temporário): `frozen:["docs/**"]` bloqueia `docs/x.ts` e `docs/a/b.ts` (`frozen`); `touch:["src/**"]` permite `src/a.ts` e bloqueia `lib/a.ts` (`outside_touch`); `touch:["tests/**"]` + `frozen:["tests/golden/**"]` bloqueia `tests/golden/a.ts`; absoluto fora da raiz (`/tmp/x.ts`, `/etc/hosts`) e `../x.ts` e `src/../../x.ts` → `path_escape`; absoluto dentro da raiz (`<root>/src/a.ts`) equivale ao relativo; symlink dentro da raiz apontando para fora → `path_escape`; arquivo de `touch` exato (`src/only.ts`) permite só ele.
## Não fazer
- Não editar `scope_path.ts` nem os testes congelados das TASK-01/02. Sem rede.
- Não escrever a string `BLOCKED:` em código novo além da já existente no `reason` (o grep do `dispatch-task.sh` confunde com BLOCKED real).
## Contexto
- Achado do judge (judge/manda.json, 2026-10-30): `scope_guard.ts:65-80` abre exceção só para `tests/fixtures` e `tests/frozen`, tem `/etc/passwd` e `../fora.ts` fixos e não usa `resolvePath`/`matchesAny`. LEARNINGS.md do PLAN.

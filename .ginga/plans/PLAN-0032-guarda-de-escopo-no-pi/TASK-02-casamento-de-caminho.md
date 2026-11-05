---
type: task
mode: padrao
goal: "resolvePath e matchesAny normalizam caminhos relativos e absolutos, bloqueiam escape por .. e symlink e aceitam prefixo de diretório e globs"
title: Caminho seguro
plan: PLAN-0032-guarda-de-escopo-no-pi
repo: manda
depends_on: []
tier: medium
touch: [src/runtime/scope_path.ts, src/runtime/scope_ignore.json, tests/scope_path.test.ts]
done_when: "bun test tests/scope_path.test.ts"
pinga_task: T163
tests_frozen: [tests/scope_path.test.ts]
---
## Fazer
- `resolvePath(root, p)`: normaliza, torna relativo à raiz da worktree e devolve `path_escape` se sair dela (`../`, absoluto fora, symlink que aponta para fora via `realpath` do pai quando o arquivo não existe).
- `matchesAny(rel, patterns)`: padrão terminando em `/` = prefixo de diretório; `*`/`**` = glob (`Bun.Glob`); comparação exata caso contrário.
- `scope_ignore.json`: arquivos gerados que nunca contam (`bun.lock`, `**/__pycache__/**`, `*.pyc`, `node_modules/**`).
## Interface
- Teste em diretório temporário: `..`, absoluto fora, symlink para fora, prefixo de diretório, globs, ignorados, nome com espaço.
## Não fazer
- Não seguir symlink para dentro de `.git`. Sem rede.
## Contexto
- Reaproveita a semântica de `touch` do `pinga` (`p-inga/src/guards.ts`); em divergência, vale a do pinga e a TASK abre `BLOCKED:`.

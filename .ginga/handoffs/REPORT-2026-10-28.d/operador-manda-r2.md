# operador manda, rodada 2 (2026-10-28) — fatos

Item resolvido: **PLAN-0022 TASK-01 (manda merge)** — fechado, com TASK-02 (T17) de correção de testes. Sem Discord (nada crítico).

## TASK, receipts, testes

| TASK | commits na `plan/0022` (worktree `manda-plan-0022`) | receipt |
|---|---|---|
| TASK-01 (T16) | `3fd5f82 test(T16): RED` (base pré-existente) + `1d5479a fix(T16): env explícito no spawnSync (filhos Bun não veem mutação de PATH) + git revert sem -q (uso 129)` | `pinga verify tasks/T16/PLAN.md --base <HEAD>` **pass** — ledger seq **454** |
| TASK-02 (T17, nova) | `984c77a test(T17): corrige 3 erros de autoria no merge_gate.test (13, 14, 2a); PLAN da TASK` | `pinga prove-red` (done_when exit 1 no base `3fd5f82`) **pass** (seq 445) e `pinga verify --base <HEAD>` **pass** — ledger seq **453** |

- `pinga queue --root manda-plan-0022`: **17 done, 0 open, 0 blocked** (T16 e T17 `done`).
- `bun test` (worktree `manda-plan-0022`, suite inteira): **153 pass / 0 fail** (14 arquivos).
- `bun test` (main do manda): **142 pass / 0 fail** (13 arquivos) → sem falha nova vs main (gate 13 clean).
- `pinga ledger verify`: **ok** (seq 454).
- `.ginga/plans/PLAN-0022-merge-gate-no-pacote/ready/manda.json` = `{"branch":"plan/0022"}`.

## O que a rodada fez

1. **Fix de T16**: o executor despachado (glm-free, r1) deixou 2 bugs: (a) `Bun.spawnSync` não propaga mutação de `process.env` — o stub `pinga` do teste nunca rodava (fix: `env: {...process.env}` explícito nos spawns de `pinga`); (b) `git revert` com `-q` devolve usage 129 (git 2.56) e o revert automático falhava em silêncio (fix: sem `-q`).
2. **TASK-02 (T17), nova, com `prove-red`**: 3 erros de autoria em `tests/merge_gate.test.ts` (tests_frozen, não criado por mim) tornavam o caso inalcançável para qualquer port fiel de `merge-gate.sh`: veredito escrito antes do último commit da branch (testes 13 e 14; o gate real compara­ o HEAD exato) e `writeVerdict(wtHead())` depois de remover a worktree (teste "2: sem worktree"; spawn ENOENT). Correção editada por mim (executor) porque o prompt do executor despachado é proibido de alterar tests_frozen.
3. **BOOKKEEPING**: `tests_frozen` de TASK-01/T16 reduzido a `["tests/fixtures/merge/pinga-stub"]` — `merge_gate.test.ts` passou a ser frozen do T17 (literais nos dois PLAN.md, mesmo formato).
4. **Backlog**: `- [x]` no PLAN-0022 TASK-01 em `.ginga/prompts/backlog-manda.md`; PLAN-0017 já estava `[x]` (sem trabalho meu).

## Achados do judge

- Nenhum achado no lane `manda`: as entradas recentes do gate/judge (`judge-e-gate.md`) são PLAN-0006/0010 no repo `ginga` e o achado sobre `SANDBOX_REPOS` (fora de repo) é mandatoriamente ignorado.
- PLAN-0008 (manda) já mergeado/concluído no quadro.

## Pendência do dono (registrada, fora do meu alcance)

- **Bug latente em `.ginga/bin/merge-gate.sh` (linha do revert)**: `git revert -m 1 --no-edit HEAD -q` → usage 129 em git 2.56 → o revert automático do código 14 roda falhando em silêncio. O `manda merge` (T16) já corrige isso no TS. O bash cai em `_archive/` na TASK-03 do PLAN-0022; se o dono quiser consertá-lo antes, é uma linha (remover `-q`).

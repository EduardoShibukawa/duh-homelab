# Operador ginga — rodada 6 (2026-10-28) — fatos

Dois itens: (1) fechamento do PLAN-0023 TASK-01 (T28) — despacho da r5 terminou após o executor sem commit; (2) corte dos hooks manuais (PLAN-0022).

## Item 1 — PLAN-0023 TASK-01 · ginga · worktree ginga-plan-0023 (branch plan/0023)

| Commit | O que |
|---|---|
| 0cfa3eb | `fix(T28)`: kinds do vigia no schema v1 (heartbeat, lane.round, gate.result, alvo.check) + fixtures dos 6 incidentes (implementação do executor, sem commit) |
| (novo) | `fix(T28)`: touch com caminhos exatos em tasks/T28/PLAN.md (matcher do guard é exato; `tests/fixtures/watch/` como dir causava scope_drift — caso T25) |

| Cheque | Resultado |
|---|---|
| `pinga verify tasks/T28/PLAN.md` (após commits) | **pass** (ledger seq 488; tentativa 1 com scope_drift 487 antes do fix do touch) |
| `pinga queue --json --root ginga-plan-0023` | T28 **done**, receipt pass 488; 26 done / 0 open / 0 blocked |
| `bun test` (events_watch_kinds + events, events_fix, events_fix2, events_validate_cost) | 34 pass / 0 fail |
| `.ginga/plans/PLAN-0023-vigia-e-supervisor/ready/ginga.json` | gravado: `{"branch":"plan/0023"}` |

## Item 2 — PLAN-0022 corte dos hooks (fora de TASK; arquivo de root)

| Ação | Resultado |
|---|---|
| `ginga hooks check --root <ws>` (antes) | exit 1 — drift nos 9 pares (3 repos × 3 hooks) |
| `.ginga/hooks.toml` + `.ginga/hooks/git/{pre-merge-commit,pre-commit,reference-transaction}` criados no root | reference-transaction byte-idêntico ao fixture do T25; pre-commit encadeia `<hook>.ginga-prev` |
| `hooks install` | exit 0 — ginga, manda e p-inga: hooks instalados; antigos encadeados como `.ginga-prev` |
| p-inga `hk run` | preservado: `pre-commit.ginga-prev` contém `exec hk run pre-commit "$@"`, chamado pelo novo pre-commit |
| `hooks check` (depois) | exit 0 — "OK: 3 hook(s) instalado(s) em 3 repo(s)" |
| Manuais de 2026-10-28 | arquivados em `_archive/2026-10-28-hooks-manuais/{ginga,manda,p-inga}/` + MANIFEST (seção nova no `_archive/MANIFEST.md`) |
| Clone test (manda, `/tmp/opencode/hooks-clone-test/root`) | commit direto na main: **BLOQUEADO** (reference-transaction); merge `--ff-only` sem gate: **BLOQUEADO**; `--no-ff` sem gate: **BLOQUEADO** (pre-merge-commit); `MERGE_GATE=1 --ff-only`: permitido; commit em branch não-main: permitido |

Detalhe observado: merge bloqueado por hook deixa `MERGE_HEAD`; `git merge --abort` na main também é barrado pelo hook (atualiza refs/heads/main) — limpeza só manual. O merge-gate.sh não sofre (aborta apenas após merge conflitado `--no-ff`, em que a main não andou).

## Pendências para as próximas rodadas

- PLAN-0023 TASK-02 (`ginga watch`, avaliador de rules.toml) — uma TASK por rodada.
- Gate/judge do `plan/0023` correm depois desta rodada (T28 ready).

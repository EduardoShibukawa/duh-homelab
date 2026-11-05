# Operador p-inga — 2026-10-29 13:28, rodada 1 (lane p-inga)

Repo: `p-inga`. Worktree: `p-inga-plan-0009` (branch `plan/0009`, HEAD `93c5180`, tree limpa).

## Achados do judge (gate barrou)

- **A3 / TASK-02 (docsite no gira.yaml)** — verificado nesta rodada:
  - Condições do item satisfeitas: `gira-g` main `e02b358` contém PLAN-0009; gira reinstalado da main (`gira v0.3.0-27-ge02b358`, instalado 09:04).
  - `docsite:` presente no `gira.yaml` do HEAD da branch (commit `5734534`; pai RED `d7c55f4`).
  - done_when T80 (`grep ^docsite: && gira docs --output /tmp/pinga-docsite && grep pinga-stable index.html`): **pass**.
  - `pinga verify` com base padrão (`findRedBase` → `d7c55f4`, anterior ao merge `f9479c9` com main) selou `blocked/scope_drift` seq 718: as mudanças do PLAN-0006 (adapters/install, trazidas pelo merge) aparecem como drift. Re-verificado com `--base d65549d` (main) → **pass, receipt seq 720**.
- **A6 / TASK-06-guard (PATH no guardReasonFor)** — não tocado: pendência do dono registrada em `pendencia-TASK-10-guard-path.md` (contradição com `tests/hooks_provider.test.ts` congelado da T77). O revert `93c5180` desfaz o RED `1e87eb2`; sem T81 na fila.

## Estado da fila (`pinga queue --json --root p-inga-plan-0009`)

| TASK | pinga | state | receipt |
|---|---|---|---|
| TASK-06 | T77 | done | pass seq 662 |
| TASK-08 | T79 | done | pass seq 679 |
| TASK-02 | T80 | done | pass seq 720 |

## Testes

- `bun test` na worktree: **437 pass / 0 fail**.
- `pinga ledger verify`: **ok 720**.

## Backlog

- PLAN-0010 TASK-06: já mergeado na main (`25a9110`), `[x]` procede.
- PLAN-0021: já mergeado na main (`7362578`), `[x]` procede.
- PLAN-0009 TASK-06 (T77): pass 662, `[x]` procede.
- PLAN-0009 TASK-02 (T80): **verificado nesta rodada** (pass 720; docsite no HEAD da branch, aguardando judge+gate da lane).
- PLAN-0006 TASK-04 (T78): já mergeado na main (`d65549d`), pass seq 691, `[x]` procede.

## Ready

- `.ginga/plans/PLAN-0009-contexto-sem-gira/ready/p-inga.json` regravado: `{"branch":"plan/0009"}`.

## Para a lane (judge/gate)

- O veredito em `judge/p-inga.json` é do HEAD antigo `aeafd38` (pré-docsite). As execuções 09:17–13:11 falharam por limite de uso do Codex (mensagem "try again at Nov 25th"). Gate no HEAD atual `93c5180` exigirá `judge-run.sh` re-rodado.

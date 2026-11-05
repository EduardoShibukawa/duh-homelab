# operador manda rodada 5 (2026-10-29) — fatos

Item resolvido: correção de flakiness do gate (exit 13 intermitente) no caso 10 do `merge_gate.test.ts` (HEAD sentinela colidia com hash real quando o commit começava em `0`).

## TASK, receipts, testes

| TASK | commit | receipt | bun test |
|---|---|---|---|
| T22 (manda) | 1c07991 fix(T22): remove flaky hash collision in merge_gate test case 10 + 0c00f9a chore(T22) | pass (seq 483) | tests/merge_gate.test.ts: 11 pass / 0 fail; suite inteira: 160 pass / 0 fail |

- `pinga queue --json --root manda-plan-0022`: 21 done / 0 open / 0 blocked.
- `pinga ledger verify`: ok (seq 483).
- `.ginga/plans/PLAN-0022-merge-gate-no-pacote/ready/manda.json`: `{"branch":"plan/0022"}` (reescrito).
- Backlog PLAN-0017 (análise): já concluído, lacunas listadas em log.md.

## Achados do judge

- Judge verdict manda (HEAD 1163a90): pass, 3 items (TASK-01, TASK-02, TASK-05), 0 regression.
- Gate barrou exit 13 em 21:17:21 com `(fail) manda merge: códigos de saída do gate > 10: veredito de outro HEAD não vale` — causa: teste construía HEAD "alternativo" como `"0" + wtHead().slice(1)`, que colide quando o hash real começa em `0`. Corrigido com sentinela de 40 `f`.

## Decisões

- operador | fix flaky test case 10 em tests/merge_gate.test.ts (frozen T17) via TASK T22 nova | regra "para mudar tests_frozen, criar TASK nova com teste novo" (executor dentro de TASK com verify pass)
# operador-manda-r1b (lane manda 20261029-0018, rodada 1)
- Achados do judge (PLAN-0022/0023): já resolvidos por T101 (seq 565) e T102 (seq 567); nada a fazer.
- TASK-09 / T110 `manda merge` exit 17: RED prove-red pass (base bbb52fe); verify pass; commit fix(T110).
- TASK-10 / T111 `manda install` + `--help`/`-h`: RED prove-red pass; verify pass; commit fix(T111).
- `bun test` (manda-plan-0022): 182 pass / 4 fail. Os 4 são os testes de CLI antigos (judge sem PLAN, PLAN inexistente, pipeline/lane sem args) que dão exit 30 sob ancestral LLM (pendência já registrada em decisoes.md); sem ancestral: 177/0 na rodada anterior.
- `pinga ledger verify`: ok 587. `ready/manda.json` = {"branch":"plan/0022"}.
- Não feito (limite de 2 itens): `manda merge` remove worktree + `git branch -d` após o merge.

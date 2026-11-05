---
type: task
mode: padrao
goal: "manda merge recusa com exit 17 (passe vazio) um veredito sem itens, igual ao merge-gate.sh"
title: manda merge exit 17 (veredito sem item)
plan: PLAN-0022-merge-gate-no-pacote
repo: manda
depends_on: [TASK-01-manda-merge]
tier: free
pinga_task: T110
touch: [src/merge.ts, tests/merge_empty_pass.test.ts, tasks/T110/PLAN.md]
done_when: "bun test tests/merge_empty_pass.test.ts tests/merge_gate.test.ts tests/merge_followup.test.ts tests/merge_revert_hook.test.ts"
tests_frozen: [tests/merge_empty_pass.test.ts]
---

## Fazer
- Em `src/merge.ts`, logo depois do exit 10 (veredito de outro HEAD) e antes do exit 11: se `judge.items` não for array ou tiver 0 itens → `finish(17, "veredito sem nenhum item para <repo> (passe vazio): falta TASK com repo: <repo> no PLAN")`. A mensagem contém "passe vazio".
- Documentar `17` no cabeçalho de códigos de saída do arquivo.
## Não fazer
- Não alterar nenhum teste: as fixtures `writeVerdict` dos testes de merge já passam 1 item por padrão.

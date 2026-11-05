---
type: task
mode: mvp
goal: "guard sweep <dir> lista arquivo:linha e regra de formato de chave nos logs, sai 3 com ocorrência, nunca imprime o trecho; guard-sweep.sh avisa no Discord quando acha"
title: Varredor de saída das lanes
plan: PLAN-0033-guard-de-segredos
repo: ginga
pinga_task: T305
depends_on: [TASK-02-run-e-cli]
tier: free
touch: [src/guard/sweep.ts, src/guard/cli.ts, tests/guard_sweep.test.ts]
done_when: "bun test tests/guard_sweep.test.ts"
tests_frozen: [tests/guard_sweep.test.ts]
---
## Fazer
- `sweep(root, deny)`: percorre `*.log|md|out|events|tsv|json|txt|jsonl` (< 20 MB, ignora `node_modules` e `.git`) e devolve `{files, hits:[{file,line,rule}]}` com as regras `content` do `deny.json`.
- Verbo `sweep <dir>` no `cli.ts`: imprime `arquivo:linha regra` por ocorrência e `varridos N arquivos, M ocorrência(s)`; exit 0 limpo, 3 com ocorrência.
## Interface
- Protótipo: [ref/ginga/src/guard/sweep.ts](../ref/ginga/src/guard/sweep.ts). Em 2026-10-29 rodou sobre `.ginga/` (1276 arquivos): 0 ocorrências.
## Não fazer
- Não imprimir nem logar o trecho que casou. Não tocar tests_frozen.
## Contexto
- O aviso no Discord (`.ginga/bin/guard-sweep.sh`: roda `cli.ts sweep`, e se exit 3 chama `notify.sh "[guard] N ocorrência(s) de formato de chave em <dir>: ver guard sweep"`) e a ligação antes de `git push`/PR (hook em `.ginga/hooks/git`) ficam **fora desta TASK**: mexem em hooks de merge e pedem OK do dono (pesquisa §8, item 7).

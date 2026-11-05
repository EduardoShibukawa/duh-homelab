---
type: task
mode: padrao
goal: "o dispatch-task.sh só grava um learning se houver uma linha que COMECE por `LEARNING:` (fora de JSON), em uma linha, com no máximo 400 caracteres e sem eco do template"
title: Captura de learning limpa
plan: PLAN-0038-learnings-que-funcionam
repo: duh-homelab
depends_on: []
tier: free
touch: [.ginga/bin/learning-extract.sh, .ginga/bin/dispatch-task.sh, .ginga/bin/tests/learning-capture.test.sh]
done_when: "bash .ginga/bin/tests/learning-capture.test.sh"
tests_frozen: [.ginga/bin/tests/learning-capture.test.sh]
---
## Fazer
- Novo `.ginga/bin/learning-extract.sh` (sourced), função `extract_learning <log>`: remove cores ANSI; considera só linhas que, após `trim`, começam por `LEARNING:` ou `learning:` (sem JSON antes); pega a **última** que sobrar; tira o prefixo; recorta a 400 caracteres; devolve vazio se começar por `nenhum`/`"nenhum`, se contiver `<1 linha`, `{"` ou `\n` literal, ou se estiver vazia.
- `dispatch-task.sh` (linha ~93): trocar o `grep -i -m1 ... | sed` por `L=$(extract_learning "$LOG")` e manter o `case`/append. Fazer sob `source "$(dirname "$0")/learning-extract.sh"`.
- Aplicação: escrever `dispatch-task.sh.new`, rodar o teste e `bash -n`, e só então `mv dispatch-task.sh.new dispatch-task.sh` (as lanes usam o script; backup `dispatch-task.sh.bak-AAAA-MM-DD-learning`).
## Interface
- `learning-capture.test.sh` cria logs temporários: (a) linha `LEARNING: usar X` → `usar X`; (b) o prompt ecoado `... learning: <1 linha sobre o que surpreendeu, ou "nenhum">` → vazio; (c) linha JSON `{"text":"... learning: abc"}` → vazio; (d) linha de 1000 caracteres → exatamente 400; (e) duas linhas válidas → a última; (f) `LEARNING: nenhum` → vazio; (g) `grep` confirma que `dispatch-task.sh` usa `extract_learning` e `bash -n` passa nos dois scripts.
## Não fazer
- Não mexer em lógica de tentativas, cota, restore ou verify. Não editar o script com `sed -i` no lugar.
## Contexto
- `.ginga/bin/dispatch-task.sh` linha 93-94; precedente de troca atômica: PLAN-0033 TASK-06.

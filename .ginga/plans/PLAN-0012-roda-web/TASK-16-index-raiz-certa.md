---
type: task
mode: padrao
goal: "writeIndex/checkIndex derivam o quadro do bundle <ws>/.ginga (não da raiz do workspace) e o render não duplica os cabeçalhos ## do template; o teste verifica o conteúdo gerado"
title: Gerador de index deriva da raiz certa e sem cabeçalho duplicado (follow-up do judge nas TASK-06/14)
plan: PLAN-0012-roda-web
repo: ginga
depends_on: [TASK-14-index-verbo, TASK-15-board-blocked-feito]
tier: free
touch: [src/index_md.ts, tests/index_md_raiz.test.ts]
done_when: "bun test tests/index_md_raiz.test.ts tests/index_md.test.ts tests/index_cli.test.ts"
tests_frozen: [tests/index_md_raiz.test.ts]
pinga_task: T333
---
## Context
- Judge 2026-11-01T221449 (grave): writeIndex passa a raiz do workspace a deriveBoard (que espera o bundle .ginga), então intents/plans são lidos de <ws>/ e o index.md real nasce sem os PLANs; renderSection duplica os `## Seção` do template (src/index_md.ts:26-35); Concluído nunca lista PLAN done.
- Os chamadores (src/verbs/index.ts:14-23, src/serve.ts:233-238) passam a raiz do workspace — a correção fica dentro de writeIndex/checkIndex: derivar de `join(root, ".ginga")` (se root já for o bundle, usa root).
## Interface
- Ao substituir `<!-- ginga:board:x -->`, se a linha não vazia anterior já é `## ...`, não emitir outro cabeçalho; cada `## Seção` sai uma vez só.
- Teste novo (tests/index_md_raiz.test.ts) verifica conteúdo: INTENT de <ws>/.ginga aparece, PLAN done aparece em Concluído, cabeçalhos únicos, checkIndex(ws) true após writeIndex.
## Não fazer
- Não tocar em tests/index_md.test.ts (frozen T160) nem tests/index_cli.test.ts (frozen T331). O hack `global.mkdirSync` em src/index_md.ts:2 fica (o frozen T160 usa mkdirSync sem import).

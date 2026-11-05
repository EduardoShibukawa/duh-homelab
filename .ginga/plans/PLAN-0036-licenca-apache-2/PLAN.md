---
type: plan
title: Licença Apache-2.0 nos repos de código
intent: DECISION-0005-apache-2-e-publicacao
kind: chore
status: approved
repos: [ginga, manda, p-inga, gira-g]
depends_on: []
done_when: "cd ginga && bun test tests/license.test.ts && cd ../manda && bun test tests/license.test.ts && cd ../p-inga && bun test tests/license.test.ts && cd ../gira-g && mise exec -- go test ./internal/license/"
---
## Objetivo

O dono decidiu (2026-11-05, DECISION-0005) que tudo é Apache-2.0, não MIT, e os repos agora são públicos. ginga, manda e p-inga não têm LICENSE; o gira-g tem MIT e troca para Apache-2.0. O texto oficial já está em `/home/shibuka/Projetos/duh-homelab/LICENSE` (sha256 do conteúdo sem espaço final: `43070e2d4e532684de521b885f385d0841030efa2b1a20bafb76133a5e1379c1`); cada TASK copia esse arquivo byte a byte (`cp`), sem reescrever o texto.

O `docs-benchmark` não tem lane nem pinga; a LICENSE dele é feita à mão fora deste PLAN.

## TASKs

1. [TASK-01](TASK-01-ginga.md): ginga
2. [TASK-02](TASK-02-manda.md): manda
3. [TASK-03](TASK-03-p-inga.md): p-inga
4. [TASK-04](TASK-04-gira-g.md): gira-g (troca a MIT; as tags v0.1.0 a v0.3.0 continuam MIT)

## Riscos

- Os testes dependem do hash do texto, não do arquivo da raiz: o executor não precisa de acesso ao repo da raiz para passar, só para copiar.
- gira-g: o `THIRD_PARTY_NOTICES.md` não muda (é de dependências).

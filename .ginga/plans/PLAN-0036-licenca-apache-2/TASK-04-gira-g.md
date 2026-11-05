---
type: task
mode: padrao
goal: "o gira-g passa a ter LICENSE Apache-2.0 (texto oficial idêntico ao da raiz) e declara Apache-2.0 no README"
title: LICENSE Apache-2.0 no gira-g
plan: PLAN-0036-licenca-apache-2
repo: gira-g
depends_on: []
tier: free
touch: [LICENSE, README.md, internal/license/license_test.go]
done_when: "mise exec -- go test ./internal/license/"
tests_frozen: [internal/license/license_test.go]
---
## Fazer
- Substitua a LICENSE MIT atual copiando `/home/shibuka/Projetos/duh-homelab/LICENSE` para `LICENSE` na raiz do repo com `cp` (não reescreva o texto).
- No `README.md`, uma linha/seção de licença que cite `Apache-2.0` (ex.: `## Licença` + `Apache-2.0, ver [LICENSE](LICENSE).`). Se o README já falar de MIT, troque.
## Interface
- Teste Go `internal/license/license_test.go` (`package license`, sem código de produção; o arquivo de teste sozinho forma o pacote): lê `../../LICENSE`, tira o espaço final e compara o sha256; confere que o título é `Apache License` / `Version 2.0` e que não contém `MIT License`; `../../README.md` contém `Apache-2.0`.
- Fixar `tests_frozen` antes de implementar: o teste falha na base (a LICENSE atual é MIT).
- O teste lê `LICENSE`, tira o espaço final e compara o sha256 com `43070e2d4e532684de521b885f385d0841030efa2b1a20bafb76133a5e1379c1`.
## Não fazer
- Não reescrever o texto da licença nem mexer em outras seções do README.
- Não tocar em dependências, lockfiles ou código de produção.
## Contexto
- DECISION-0005 (`.ginga/knowledge/decisions/DECISION-0005-apache-2-e-publicacao.md`).

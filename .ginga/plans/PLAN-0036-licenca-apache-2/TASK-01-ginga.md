---
type: task
mode: padrao
goal: "o ginga passa a ter LICENSE Apache-2.0 (texto oficial idêntico ao da raiz) e declara Apache-2.0 nos metadados e no README"
title: LICENSE Apache-2.0 no ginga
plan: PLAN-0036-licenca-apache-2
repo: ginga
depends_on: []
tier: free
touch: [LICENSE, package.json, README.md, tests/license.test.ts]
done_when: "bun test tests/license.test.ts"
tests_frozen: [tests/license.test.ts]
---
## Fazer
- Copie `/home/shibuka/Projetos/duh-homelab/LICENSE` para `LICENSE` na raiz do repo com `cp` (não reescreva o texto).
- Em `package.json`, defina `"license": "Apache-2.0"`.
- No `README.md`, uma linha/seção de licença que cite `Apache-2.0` (ex.: `## Licença` + `Apache-2.0, ver [LICENSE](LICENSE).`). Se o README já falar de MIT, troque.
## Interface
- Teste `tests/license.test.ts` (bun): `LICENSE` existe e o sha256 do conteúdo (sem espaço final) bate; `package.json` tem `"license": "Apache-2.0"`; `README.md` contém `Apache-2.0` e não contém "MIT License".
- Fixar `tests_frozen` antes de implementar: o teste falha na base (sem LICENSE).
- O teste lê `LICENSE`, tira o espaço final e compara o sha256 com `43070e2d4e532684de521b885f385d0841030efa2b1a20bafb76133a5e1379c1`.
## Não fazer
- Não reescrever o texto da licença nem mexer em outras seções do README.
- Não tocar em dependências, lockfiles ou código de produção.
## Contexto
- DECISION-0005 (`.ginga/knowledge/decisions/DECISION-0005-apache-2-e-publicacao.md`).

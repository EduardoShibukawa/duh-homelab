---
type: task
mode: padrao
goal: "O docsite do gira não tem nenhum caso especial por nome de projeto; tour, workflows e título vêm da config do repo-alvo"
title: Tour e landing configuráveis por projeto
plan: PLAN-0009-contexto-sem-gira
repo: gira-g
depends_on: []
tier: medium
pinga_task: T04
touch: [internal/docsite/tour.go, internal/docsite/landing.go, internal/docsite/types.go, internal/docsite/builder_test.go, internal/manifest/manifest.go, cmd/gira/docs_cmd.go, internal/docsite/no_special_case_test.go]
done_when: "mise exec -- go test ./internal/docsite/... ./internal/manifest/... && ! rg -n -i 'p-inga|pinga' internal/docsite cmd/gira --glob '!*_test.go'"
tests_frozen: [internal/docsite/no_special_case_test.go]
---
## Fazer
- Seção `docsite:` no `gira.yaml` (`title`, `tour[]`, `workflows[]`, `pillars[]`), lida em `manifest.go` e passada em `SiteConfig`.
- Sem `docsite:` → tour e landing genéricos (o caminho que já existe para outros alvos).
- Remover os `if TargetName == "p-inga"` de `tour.go:309`, `landing.go:18,425,533` **e** os comandos `bun .pinga/pinga-stable …` fixos em `tour.go:326-364` e `landing.go:421-422` (vão para o `gira.yaml` do p-inga na TASK-02). Nenhuma menção a pinga fora de `_test.go`.
## Não fazer
- Não mudar o HTML gerado para alvos sem config.
## Contexto
- `generateTourSteps` (tour.go:198), `buildScenariosSection`, `buildPillarsSection`, `SiteConfig` (types.go:60), `docs_cmd.go:106`.

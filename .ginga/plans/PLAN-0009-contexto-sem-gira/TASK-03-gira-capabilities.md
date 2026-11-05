---
type: task
mode: mvp
goal: "gira capabilities --json lista as capacidades do protocolo de contexto que o gira atende"
title: gira capabilities --json
plan: PLAN-0009-contexto-sem-gira
repo: gira-g
depends_on: [TASK-01-gira-tour-config]
pinga_task: T05
tier: free
touch: [cmd/gira/main.go, cmd/gira/capabilities.go, cmd/gira/capabilities_test.go]
done_when: "mise exec -- go test ./cmd/gira/ -run Capabilities"
tests_frozen: [cmd/gira/capabilities_test.go]
---
## Fazer
- `{"schema_version":1,"capabilities":["outline","slice","impact","read"],"extras":["gira:tour","gira:docs"]}`.
- Só capacidades que já existem em `main.go` (`case "outline"` l. 242, `"slice"` l. 191, `"impact"` l. 188, `"read"` l. 245).
## Não fazer
- Não mudar a saída dos outros comandos.
## Contexto
- `cmd/gira/main.go` (switch de comandos), doc 02 §2 ("Context provider").

---
type: task
mode: padrao
goal: "ginga init cria .ginga/ e project.toml num repo novo a partir do que detecta, sem sobrescrever nada"
title: ginga init
plan: PLAN-0015-init-e-homelab
repo: ginga
pinga_task: T127
depends_on: []
tier: medium
touch: [src/init.ts, src/verbs/init.ts, src/verbs/registry.ts, src/cli.ts, tests/init.test.ts]
done_when: "bun test tests/init.test.ts"
tests_frozen: [tests/init.test.ts]
---
## Fazer
- Cria `index.md` (`okf: "0.1"`), `log.md`, `intents/ specs/ plans/ knowledge/{lessons,decisions}/ handoffs/` e `project.toml`.
- `[commands].test` pela stack (`package.json` → `bun test`/`npm test`, `go.mod` → `go test ./...`, `pom.xml` → `mvn test`); `[context].provider`; `[runtimes]` só com o que está no PATH; `[notify]` se `hermes` existir.
- `--yes` não pergunta; sem `--yes`, mostra o `project.toml` e pede confirmação. Rodar 2× não muda nada.
- `src/cli.ts` no touch (2026-10-29, operador): o parser da CLI genérica rejeita flag sem valor (`--yes` → "falta valor"), então aceitar flags booleanas de args do registro exige editá-lo. Decisão registrada em `.ginga/handoffs/REPORT-2026-10-28.d/decisoes.md`.
## Não fazer
- Não instalar plugins (é o `ginga install`).
## Contexto
- `pi-harness/.pi/extensions/scaffold.ts` (`detectStack`, reexportado por `src/scaffold.ts`); doc 02 §2 ("Contrato por projeto"); protótipo `Onboarding.dc.html`.

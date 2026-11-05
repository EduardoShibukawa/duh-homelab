---
type: plan
title: Instalação e adoção saem do pinga para o ginga (A2)
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
repos: [ginga, p-inga]
depends_on: [PLAN-0004-eventos-e-lint]
done_when: "cd ginga && bun test && cd ../p-inga && bun test && ! rg -n 'pi-harness' src bin web"
---
## Objetivo

Inverter a dependência A2: `install`, `adopt`, os adapters de host e a parte de harness do `doctor` vão para o `ginga`, sem o nome `pi-harness` fixo no código. O pinga fica só com o gate.

## Abordagem

- Copiar primeiro (o ginga passa nos testes copiados), parametrizar depois, remover do pinga por último. Assim existe sempre uma instalação funcionando.
- Módulos que saem juntos (dependências reais): `install.ts`, `adopt.ts`, `manifest.ts`, `shadow.ts`, `adapters/{claude,hermes,opencode,pi,tuios}.ts` e o bloco de adapters do `doctor.ts` (`import { ADAPTER_ORDER, pickSource } from "./install"`, l. 10).
- O plugin instalado vira parâmetro (`[install] plugin` no config do ginga, padrão lido de `GINGA_PLUGIN_SOURCE`), no lugar de `PINGA_PI_HARNESS_DIR` e de `pi-harness@pi-harness-local`.
- **Execução:** TASKs como `tasks/T<N>/PLAN.md` em cada repo até o PLAN-0005 fechar; `tests_frozen` escritos pelo Planner.

## TASKs

1. [TASK-01](TASK-01-ginga-install-copia.md): copiar install/adopt/adapters para o ginga com os testes
2. [TASK-02](TASK-02-plugin-parametrizado.md): tirar o `pi-harness` fixo (nome e fonte do plugin)
3. [TASK-03](TASK-03-ginga-doctor.md): `ginga doctor` com a parte de harness
4. [TASK-04](TASK-04-pinga-remove-install.md): o pinga remove install/adopt e aponta para o ginga

## ACs da SPEC cobertos

- O pinga não referencia mais o pi-harness (A2, junto com o PLAN-0005).
- A instalação/adoção sai do pinga para o ginga (A2).

## Riscos

- `install.ts` (1067 linhas) mexe em `~/.claude`, `~/.hermes`, `~/.config/opencode`, `~/.pi`: os testes usam `tests/helpers/home.ts` (HOME falso) e devem continuar assim no ginga.
- Usuários atuais chamam `pinga install`: a TASK-04 mantém o comando com mensagem de migração (exit 2), sem quebrar em silêncio.
- `scripts/install-skills.sh` e `.agents/skills/` do p-inga podem citar o fluxo antigo: conferir na TASK-04.

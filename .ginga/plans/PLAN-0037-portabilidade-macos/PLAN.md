---
type: plan
title: Portabilidade macOS e caminhos do autor
intent: DECISION-0005-apache-2-e-publicacao
kind: change
status: approved
repos: [manda, ginga, p-inga]
depends_on: []
done_when: "cd manda && bun test tests/proc_fallback.test.ts tests/llm_guard_fallback.test.ts && cd ../ginga && bun test tests/launchd_contrib.test.ts tests/e2e/manda_path.test.ts && cd ../p-inga && bun test tests/no_author_paths.test.ts"
---
## Objetivo

O dono vai clonar tudo num Mac para testar (DECISION-0005). Quatro pontos conhecidos quebram ou ficam em silêncio fora do Linux do autor:

- `manda/src/proc_sample.ts` lê `/proc/<pid>/stat` (a vigia ao vivo desiste no Mac).
- `manda/src/llm_guard.ts` anda ancestrais por `/proc`; sem `/proc` ele devolve `refused:false` e a trava contra rodar merge/judge dentro de um agente LLM **desliga em silêncio**.
- `ginga/contrib/systemd/` não tem equivalente launchd.
- Caminhos `/home/shibuka` em código executável: `ginga/tests/e2e/autonomo.test.ts` e, no p-inga, `scripts/install-skills.sh`, `scripts/pinga-queue-watch.sh`.

Fora do escopo (ficam como história, não se reescrevem): `tasks/T*/` (contratos e evidências), `docs/SYSTEM_INTEGRATION_SPEC.md`, o audit do gira-g e as asserções `not.toContain("/home/shibuka")`. O Mac ainda vai revelar falhas novas: o dono roda `bun test` lá e cada falha vira TASK em PLAN novo.

## TASKs

1. [TASK-01](TASK-01-manda-proc-fallback.md): manda, amostra de CPU sem `/proc`
2. [TASK-02](TASK-02-manda-llm-guard-fallback.md): manda, guard de agente LLM sem `/proc`
3. [TASK-03](TASK-03-ginga-launchd.md): ginga, `contrib/launchd` e caminho do manda sem path do autor
4. [TASK-04](TASK-04-p-inga-sem-paths.md): p-inga, scripts sem caminho do autor

## Riscos

- Não há Mac no loop: os testes injetam a plataforma e o comando `ps`, então rodam no Linux e provam a lógica, não o macOS real.
- TASK-01 e TASK-02 editam arquivos diferentes do manda; podem rodar na mesma worktree `manda-plan-0037`.

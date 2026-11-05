---
type: plan
title: Verbos do ginga na CLI e na API + auth + resposta pela thread
spec: SPEC-0001-ginga-revamp
intent: INTENT-0001-ginga-revamp
kind: change
status: done
approved: 2026-10-29
repos: [ginga]
depends_on: [PLAN-0010-tick-serve-notifier]
done_when: "cd ginga && bun test && bun test tests/e2e/blocker_flow.test.ts"
---
## Objetivo

Toda ação vira verbo num registro único, exposto igual na CLI e na API HTTP (com SSE), com autenticação. Discord e Telegram passam a responder blockers e aprovar pela thread, e a triagem de trilha só promove.

## Abordagem

- `src/verbs/registry.ts` é a única fonte: a CLI e as rotas `POST /v1/verbs/:name` são geradas dele (teste de paridade). Nenhuma superfície tem lógica própria (doc 05 §1).
- Verbos de escrita registram quem/de onde/quando: linha no `log.md` do PLAN + evento `transition`/`answer` com `by` e `via`.
- `approve`/`reject` mudam o `status` no frontmatter (é contrato); o resto mexe só no `state.db`.
- Auth: bearer token ou allowlist da tailnet; sem nenhum dos dois, o `serve` só escuta em `127.0.0.1` (o comportamento do PLAN-0010 vira a regra).
- Entrada pelo Hermes (DECISION-0002): um plugin traduz resposta na thread e slash commands em verbos, de forma determinística; só user IDs da allowlist disparam escrita.
- Verbos que agem sobre execução (`retry`, `escalate`, kill) chamam o `manda` pela CLI (`manda verbs …`, `manda run`), sem duplicar `manda/src/verbs.ts` (decisão 4: integração só por CLI/JSON/arquivos).
- `handoff`, `learning promote`, `quota` e `init` entram no registro nos PLANs 0013, 0014 e 0015.

## TASKs

1. [TASK-01](TASK-01-registro-verbos.md): registro de verbos + verbos de escrita
2. [TASK-02](TASK-02-cli-verbos.md): CLI gerada do registro
3. [TASK-03](TASK-03-api-sse.md): API HTTP + SSE gerada do registro
4. [TASK-04](TASK-04-auth.md): token / allowlist da tailnet
5. [TASK-05](TASK-05-hermes-inbound.md): plugin do Hermes (thread e slash → verbos)
6. [TASK-06](TASK-06-e2e-blocker.md): e2e blocker → Discord/Telegram → resposta → destrava
7. [TASK-07](TASK-07-triagem.md): triagem que só promove

## ACs da SPEC cobertos

- Toda ação existe como verbo na CLI e na API, sem lógica na superfície (completa com 0013–0015).
- Um blocker chega no Discord e no Telegram e responder na thread destrava o PLAN.
- A API e a Roda Web exigem autenticação; sem isso o `serve` só escuta em localhost.
- A triagem só promove (trilha pequena → feature), nunca rebaixa.

## Riscos

- O formato de plugin do Hermes e se o gateway expõe a thread de origem da resposta não estão documentados aqui; base: `pi-harness/hermes-plugin/` (`plugin.yaml`, `__init__.py`). Botões ficam para depois (DECISION-0002). O PLAN-0017 arquiva o pi-harness: copiar `pi-harness/hermes-plugin/` como referência antes disso (a TASK-05 o recria em `contrib/hermes-plugin/`).
- O `serve` (PLAN-0010) já sobe `Bun.serve` em 127.0.0.1:4243 e sai com 2 em `--host` não-loopback; as TASKs 03/04 trocam essa regra pela auth, sem quebrar o loop de tick/watch/supervisor que mora no mesmo arquivo.
- Allowlist da tailnet por IP (`100.64.0.0/10`) é fraca se outra máquina da tailnet for comprometida: o token deve ser o padrão recomendado.

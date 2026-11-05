# Situação vs. visão — 2026-10-28

> **Nota:** este arquivo deve ser regenerado no fim de cada onda a partir do estado (SPEC-0003).

Comparação entre a visão consolidada em [02-visao-atualizada.md](../knowledge/design/ginga-revamp/02-visao-atualizada.md) e o estado real dos repos e PLANs. Fontes: inventário de [03-situacao-atual.md](../knowledge/design/ginga-revamp/03-situacao-atual.md), frontmatter dos PLANs, handoffs e código dos repos. Onde não está claro: "a verificar".

## Tabela visão × estado

| Peça (visão) | O que existe / mergeado | Em PLAN | Nem tem PLAN |
|---|---|---|---|
| **pinga (gate)** | `p-inga` main: verify/prove/ledger/judge/queue; PLAN-0005 mergeado (verifica TASK-*.md e PLAN.md, emite receipt v1). PLAN-0018 blocked (sandbox done_when, 2 rodadas de fix). | PLAN-0005 (done), PLAN-0018 (blocked). | Retirar install/adopt/adapters (PLAN-0006 draft, não mergeado). PLAN-0019 (approved) é uma avaliação de modelos, não uma peça do pinga. |
| **manda (orquestrador)** | `manda` main: CLI + runtime port (Pi, OpenCode, Claude, Codex, AGY), leitor de bundle, gate genérico, tests_frozen; PLAN-0007 mergeado. **Judge cego ainda não existe** (é a TASK-07 do PLAN-0008, draft). Worktree `manda-plan-0008` com TASK-01 (pi.ts fail-closed) done. | PLAN-0008 (draft: routing, escalada, budget, judge, manda plan). | Routing máquina no ROUTING.md (TASK-02 do 0008); desbloqueio automático (INTENT-0008) ainda não virou TASK. |
| **g-inga (UX/async/install)** | `ginga` repo existe mas só `chore: init` (commit vazio). Código do PLAN-0004 está em worktree `ginga-plan-0004`, não commitado/mergeado. | PLAN-0004 (blocked, mas TASK-13/14 em pass com judge final rodando), PLAN-0006/0010/0011/0012/0013/0014/0015 (draft). | Nenhum código de install/async/Roda no main ainda. |
| **Roda (interface)** | Protótipos em `knowledge/design/ginga-revamp/prototipos/`; `p-inga/web` como base. | PLAN-0011 (verbos/API/auth), PLAN-0012 (Roda Web + index gerado), PLAN-0014 (métricas/quota). | Telas, SSE e auth ainda não implementadas. |
| **gira (contexto)** | `gira-g` main: outline/read/write/impact/slice/docsite/MCP. Acoplamento A3 ao pinga em `tour.go`/`landing.go`. | PLAN-0009 (draft: tour config, capabilities, porta de contexto rg). | Porta de contexto com fallback rg+git ainda não implementada; `gira capabilities --json` não existe. |
| **Sandbox** | `.ginga/bin/sandbox-done-when.sh` (fase 1, `--unshare-net`) e `sandbox-run.sh` (fase 1, `--share-net`) funcionando. PLAN-0018 blocked, mas TASK-07 em pass com judge final rodando. Achado `--standalone` do opencode destrava a rede (2026-10-27). O executor hoje roda com `--share-net` (rede aberta), ponto temporário até a fase 2. | PLAN-0018 (blocked), INTENT-0006 (open). | Fase 2 (proxy allowlist, injeção de chave, limites, matriz completa, outbox) sem PLAN dedicado. |
| **Observabilidade** | Ponte ad hoc `bridge.py` (scratchpad) → 97 spans, projeto `duh-homelab-ondas-1-2`, Phoenix só protobuf. | PLAN-0014 (métricas/quota), H6 do PLAN-0016. | Receptor OTLP no `ginga serve` e painel no Roda ainda sem PLAN próprio (SPEC-0002 não cobre; 09-observabilidade.md é doc). |
| **Observabilidade operacional** | Vigia determinístico e regras versionadas ainda não existem (só detecção manual pelo operador). | INTENT-0010 / SPEC-0003 (draft). | Sinais novos (`heartbeat`, `cost`, `judge.verdict`, `sandbox.*`, `gate.fail`), regras em `.ginga/watch/rules.toml` e ações na rota de falhas do manda, Discord e Roda. |
| **Skills/hooks** | Skills espalhadas/duplicadas (pinga/red-audit em duas pastas, gira-* em `.agents`/`.claude`). Hooks úteis (bashRefusal, payload guard, hk). | SPEC-0002 (draft). PLANs afetados: 0006, 0008, 0015, 0016. | Fonte única `.ginga/skills/`, `hooks.toml`, gerador e projeção ainda não existem. |
| **Routing/budget** | `ROUTING.md` atualizado em 2026-10-28 (papéis × modelos, Go só no opencode, sem escalada automática para strong, tetos por rodada). PROVIDER-*.md existem. | PLAN-0008 (draft). | `manda route` com precedência e frontmatter máquina ainda não implementados. |
| **Bench** | Ontologia SQLite no `pi-harness/src/bench` (experiment→arm→run→event). `llm-bench/` (31 GB) e `docs-benchmark/` na raiz. | PLAN-0014 (A/B handoff), PLAN-0016 (code mode), INTENT-0007 (bench/ na raiz). | Consolidação em `bench/` (INTENT-0007 decisão 2) ainda não feita; PLAN-0017 arquiva o pi-harness. |

## Lacunas priorizadas

1. **PLAN-0004 (eventos + lint) bloqueado** (rodada 5 de fix): 2 achados simples do judge. Sem ele, o `ginga` não existe como repo funcional e os PLANs 0006/0010/0011… não podem rodar. (bloqueador de tudo)
2. **PLAN-0018 (sandbox done_when) bloqueado** (2 rodadas): 2 gaps (holdout e prove com exit 97). Sem ele, o `done_when` não roda isolado.
3. **g-inga inexistente no main**: todo o UX/async/install está só em worktrees não commitadas. Risco de perda (INTENT-0007).
4. **Desbloqueio automático (INTENT-0008)** ainda não virou TASK no PLAN-0008; 4 bloqueios manuais nas ondas 1–2 tinham resolução mecânica.
5. **Bench espalhado em 5 lugares** e sem consolidação; PLAN-0017 depende de 0014/0015.
6. **Skills/hooks** só em pesquisa; SPEC-0002 em draft, sem PLAN próprio.
7. **Observabilidade** sem receptor OTLP nem painel; só ponte ad hoc.
8. **Worktrees paradas** (PLAN-0003 draft) com mudanças não commitadas em risco.

## Próximos 5 passos

1. **Resolver os 2 achados do PLAN-0004** (TASK-13/TASK-14 ou novo INTENT) e commitar/mergear o `ginga` repo; em seguida rebasear `ginga-plan-0006`/`ginga-plan-0010`.
2. **Resolver os 2 gaps do PLAN-0018** (TASK-06) para o `done_when` rodar em sandbox.
3. **Despachar o resto do PLAN-0008** (TASK-02..08) no manda (já tem TASK-01 done), com `manda run` usando `.ginga/project.toml` com `[runtimes]`.
4. **Promover o INTENT-0008** a TASK no PLAN-0008 (desbloqueio automático) e o INTENT-0009 a SPEC/PLAN (SPEC-0002 já em draft).
5. **Executar o PLAN-0003** (triagem de worktrees) para commitar WIP e reduzir risco de perda, antes das ondas 3+.
path: .ginga/knowledge/research/situacao-vs-visao-2026-10-28.md
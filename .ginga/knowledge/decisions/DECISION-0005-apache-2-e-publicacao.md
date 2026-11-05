---
type: decision
title: Licença Apache-2.0 em tudo e publicação dos repos no GitHub
status: accepted
timestamp: 2026-11-05
---
## Decisão

O dono disse: "quero deixar tudo como open source, não MIT", escolheu **Apache-2.0** e autorizou repos públicos ("repos podem ser públicos").

- **Licença:** Apache-2.0 em p-inga, gira-g, g-inga (pasta `ginga/`), manda, docs-benchmark e no repo da raiz. Substitui só a parte "MIT" da [DECISION-0003](DECISION-0003-tudo-open-source.md); o requisito de licença aprovada pela OSI continua.
- **gira-g:** hoje é MIT. As tags v0.1.0 a v0.3.0 ficam MIT para quem as baixou; os próximos releases saem Apache-2.0. O autor é o dono (e seus agentes), então não há terceiro a consultar.
- **spring-petclinic-modern:** derivado do Spring Petclinic, que já é Apache-2.0. Mantém a licença e o NOTICE do original.
- **Raiz como repo:** `duh-homelab` vira repo git com `.gitignore` dos repos irmãos e `bootstrap.sh`, que clona e instala tudo (Linux e macOS). A raiz deixa de ser "não é repo git".
- **Nome local:** o repo se chama `g-inga` no GitHub, mas a pasta continua `ginga/` até o INTENT-0007. O `bootstrap.sh` faz `git clone …/g-inga ginga`.

## Estado em 2026-11-05

- Publicados e **públicos**: g-inga, manda, docs-benchmark, spring-petclinic-modern, duh-homelab. p-inga e gira-g já eram públicos.
- Varredura de segredos (gitleaks, histórico inteiro): só fixtures de teste com valores falsos.
- Clones frescos passam nas suítes: ginga 823, manda 420, p-inga 377 testes; `go test` do gira-g.

## Pendente (atualizado 2026-11-05)

- **LICENSE Apache-2.0:** docs-benchmark feito à mão (sem lane nem pinga). ginga, manda, p-inga e gira-g em [PLAN-0036](../../plans/PLAN-0036-licenca-apache-2/PLAN.md) (4 TASKs, backlog das lanes).
- **Portabilidade macOS e caminhos do autor:** [PLAN-0037](../../plans/PLAN-0037-portabilidade-macos/PLAN.md) (`/proc` em manda, launchd no ginga, scripts do p-inga). Falhas novas que o Mac revelar viram PLAN novo.
- **PRs de sync** p-inga #2 e gira-g #52 (CI verde, `main` do gira-g protegida): mergear com revisão do dono. As `main` do GitHub ainda não têm os 40 e 16 commits novos, nem o resultado dos PLANs acima, que as lanes mergeiam só na `main` local.
- **spring-petclinic-modern:** o histórico tem `target/…SNAPSHOT.jar` de 51 MB (aviso do GitHub). Reescrever o histórico ou aceitar.
- **Cleanup:** stashes (gira-g, ginga), branches `wt/task-01-state-db` e `work/red-t58`, 22 branches remotas velhas do gira-g, `_archive/`.
- **Descartado:** o ID do canal do Discord nos testes `ginga/tests/notify_port.test.ts` e `p-inga/tests/discord_events.test.ts` aparece só em asserção negativa (`not.toContain`); não vaza nada além do ID, que sozinho não dá acesso. Fica.

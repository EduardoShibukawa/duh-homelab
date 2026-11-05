---
type: decision
title: Tudo open source (licenças aprovadas pela OSI)
status: accepted
timestamp: 2026-10-28
---
## Decisão

O dono disse: "não quero precificar isso, quero deixar tudo open source."

- **Nossos repos** (p-inga, pi-harness, gira-g, ginga, manda, bench) usam uma licença aprovada pela OSI. **MIT** (confirmado pelo dono em 2026-10-28), a mesma que o gira-g já usa.
- **Dependências obrigatórias e serviços integrados** também precisam ter licença aprovada pela OSI. Licenças source-available (ELv2, BSL, SSPL, Commons Clause) ficam de fora.
- **Ferramentas que o dono usa por conta própria** (Claude Code, Codex, AGY, Hermes) não são dependências do código. A regra vale para o que os nossos pacotes exigem ou embutem.

## Consequências

- O **Phoenix (Arize) está fora**: a licença é Elastic License 2.0, que não é aprovada pela OSI.
- **Observabilidade** passa por **OpenTelemetry**, através de uma ponte a partir dos eventos v1. O backend é trocável e precisa ser OSI.
  - Candidatos (licença a verificar no repositório de cada um antes de adotar): Jaeger, Grafana Tempo, Opik (Comet), Laminar, Langfuse (o core; a pasta `ee/` tem licença comercial).
  - Também segue válido montar os painéis no próprio Roda (PLAN-0014).
- **Repos sem LICENSE hoje:** p-inga, pi-harness, ginga, manda, docs-benchmark. Isso entra no INTENT-0007 (organização).

## Adendo (2026-10-28): adaptadores opcionais por trás de uma interface aberta

O dono disse: "implementamos um nosso e usamos o Phoenix como opcional; para isso é só ter a mesma interface."

- A interface é **OTLP** (OpenTelemetry), com as convenções semânticas **OpenInference**. As duas são abertas (Apache-2.0, a verificar).
- O **backend padrão é nosso**, MIT: o `ginga serve` recebe `/v1/traces` e o Roda mostra os painéis.
- **Phoenix, Jaeger e outros entram como destinos opcionais**, configurados pelo usuário com `GINGA_OTLP_ENDPOINT`. Nenhum pacote nosso depende deles nem os embute, então a regra da OSI continua valendo para o que distribuímos.

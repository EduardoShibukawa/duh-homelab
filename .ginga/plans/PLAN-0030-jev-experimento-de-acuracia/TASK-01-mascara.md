---
type: task
mode: mvp
goal: "mask() remove segredos, e-mails, IPs, tokens e caminhos do HOME de um texto antes de ele sair da máquina, e corta no tamanho máximo"
title: Máscara de segredos e caminhos
plan: PLAN-0030-jev-experimento-de-acuracia
repo: manda
depends_on: []
tier: free
touch: [src/jev/mask.ts, tests/jev/mask.test.ts]
done_when: "bun test tests/jev/mask.test.ts"
tests_frozen: [tests/jev/mask.test.ts]
---
## Fazer
- Substituir por marcadores (`[KEY]`, `[TOKEN]`, `[EMAIL]`, `[IP]`, `[HOME]`, `[ENV]`): `sk-…`, `nvapi-…`, `Bearer …`, `ghp_…`, `xox…`, chaves longas hex/base64 (≥ 32 caracteres), linhas `NOME=valor` de `.env`, e-mails, IPv4, `$HOME` e `/home/<usuário>`.
- `maxChars` (padrão 2000): cabeça 40% + `…` + cauda 60% (a causa de erro costuma estar no fim do log).
- Retorna `redactions` (quantas trocas) para o `eval` reportar.
## Interface
- `mask` (PLAN.md). Teste: ≥ 12 casos (um por tipo, com segredos **falsos**, mais texto limpo que não muda e truncamento).
## Não fazer
- Sem rede, sem ler arquivo, sem dependência nova.
## Contexto
- SPEC-0004, AC de máscara. A máscara é pré-condição para qualquer chamada ao Jev.

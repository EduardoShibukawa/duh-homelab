---
type: intent
title: Nenhum executor ou operador manda segredo ao provider
source: discord
timestamp: 2026-10-29T23:55:00-03:00
status: open
---
## Pedido do dono

"Hoje nada impede um executor/operador de ler `.env`, `auth.json` ou chaves e mandar o conteúdo ao provider no prompt." Com o OpenRouter free (os botões "treinam" e "publicam prompts" ficam **ligados**, decisão de 2026-10-29), isso pode virar dataset público. Pedido: **um hook que bloqueia isso antes da tool rodar**, nos runtimes das lanes (Pi, opencode, Hermes), com uma lista de bloqueio única, ativo só em sessão de lane, e um varredor opcional de saída.

## Restrições do dono

- Toda mudança passa pelo harness (TASK + RED + executor + verificação + judge); nada é instalado à mão em `~/.pi`, `~/.config/opencode` ou `~/.hermes`.
- Não criar conta, não gerar chave, não pôr cartão, não ligar crédito pago.
- Teste só com arquivos sintéticos.

## Fora

Mover as lanes para um HOME restrito ou sandbox de processo inteiro (INTENT-0006 / follow-up descrito em [guard-segredos-2026-10-29.md](../knowledge/research/guard-segredos-2026-10-29.md) §7).

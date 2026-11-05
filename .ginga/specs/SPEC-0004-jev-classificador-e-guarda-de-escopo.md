---
type: spec
title: Jev como classificador pontual e guarda de escopo no Pi
intent: INTENT-0012-jev-e-guarda-de-escopo
status: approved
bench: none
---
## Objetivo

Trocar três tipos de decisão que hoje dependem de regex frágil ou de leitura manual por (a) um classificador Jev **medido e com piso determinístico**, e (b) uma guarda de escopo **determinística** que impede a causa de `scope_drift` em vez de detectá-la depois. Nada disto muda a escolha de tool do agente.

## ACs

- [ ] Existe um dataset rotulado e mascarado (`tests/fixtures/jev/`) e um comando `manda jev eval` que reporta acurácia, matriz de confusão, calibração, latência e custo por classificador.
- [ ] Nenhum texto sai da máquina sem passar por `mask()` (chaves, tokens, e-mails, IPs, `$HOME`, `.env`); teste com fixtures com segredos falsos.
- [ ] Cada classificador só é ligado se atingir **≥ 90%** no `eval` (abaixo de 80% fica fora; entre os dois, só com limiar de confiança ≥ 0,85 e piso de regra). O resultado fica registrado no `LEARNINGS.md` do PLAN-0030.
- [ ] Em produção o Jev nunca é o único caminho: erro, timeout, confiança baixa ou orçamento esgotado → regra determinística (fail-open), com evento registrando a origem (`source: jev|rule`).
- [ ] O Jev pago respeita `ALLOW_PAID`, o teto do `paid-spend` e o `budget.ts`; o Jev free (OpenCode Zen) e o local não contam. Sem chave configurada, tudo segue pela regra.
- [ ] Modo `shadow` registra concordância Jev × regra sem agir; só `on` age.
- [ ] A guarda de escopo bloqueia `edit`/`write` fora de `touch` e em `tests_frozen` no Pi, devolve o motivo ao modelo, emite `scope.block`, e **nunca trava a lane por bug próprio** (falha interna = libera e registra).
- [ ] Meta de resultado (medida depois, não é `done_when`): após 20 TASKs pelo Pi com a guarda, `scope_drift` cai à metade ou menos.

## Dados e dinheiro (decisão do dono)

Mandar texto de log do workspace (mascarado) a um provider do Jev é dado a terceiro. Providers possíveis: OpenCode Zen (`jev-1.13-free`, grátis por tempo limitado), OpenRouter (já há chave e crédito), TypeSafe, Vercel, ou local (`lev` 4B, llama.cpp). Operador segue restrito: nada de handoff, segredo ou dado do dono.

## Fora do escopo

Roteador de tool por passo; `jev-gateway`; triagem de tier, qualidade de TASK e escalada em produção (medidos no PLAN-0030 se houver rótulo, integração só em PLAN futuro); cobertura opencode/claude da guarda (só Pi nesta SPEC).

---
type: intent
title: ALVO acima da SPEC, com autonomia até o alvo verificado
source: cli
timestamp: 2026-10-28T10:10:00-03:00
status: open
---
## Pedido do dono

"Follow-ups do judge podem ser feitos sozinhos; o principal é, no final, termos a nossa arquitetura-objetivo cumprida. [...] Não sei se seria um nível maior que a spec. Na minha opinião, o nosso revamp foi o melhor caso: decidimos tudo lá, onde queremos chegar e as decisões arquiteturais. O como deveria ficar todo com os agentes, e eu não precisaria me preocupar com isso. Se o objetivo tiver sido alcançado e verificado, não acho que eu deva ficar decidindo essas pequenas coisas com human in the loop: isso é um gargalo."

E também: "o que poderia ter no report é o que foi levado ao judge e as decisões tomadas autonomamente."

## Leitura

O `design/ginga-revamp/` (01–10 + DECISIONs) já funciona como um nível acima da SPEC: ele fixa **onde chegar** e as **decisões arquiteturais**, e as SPECs e os PLANs são o **como**. Falta formalizar isso.

```
ALVO (humano aprova)  →  INTENT/SPEC/PLAN/TASK (agentes)  →  ALVO verificado (humano aceita)
```

1. **ALVO** = visão + decisões + **checks de aptidão executáveis**. Cada afirmação do alvo vira um check determinístico. Exemplos:
   - "merge só pelo gate" → existe hook/`reference-transaction` e o gate recusa sem veredito;
   - "pi-harness fora" → o diretório está em `_archive/` e nenhum import aponta para ele;
   - "eventos v1 em todos os runtimes" → um replay valida o schema;
   - "tudo MIT" → checagem de licença.
2. **O humano entra em dois pontos:** aprovar o ALVO (e as mudanças nele) e aceitar o ALVO verificado.
3. **Entre os dois, o harness decide sozinho** o que o ALVO cobre: follow-ups, replans, troca de modelo dentro da ROUTING, merges pelo gate. Cada decisão vai para o `decisoes.md` com a regra que a cobre, e o report traz o que foi ao judge.
4. **Exceções que sempre sobem ao dono:**
   - dinheiro ou conta externa;
   - dados enviados a terceiros;
   - ações que a regra dele reserva (por exemplo, remover worktree/branch fora de PLAN mergeado);
   - conflito entre o ALVO e a realidade, quando é o ALVO que precisa mudar.
5. **O gap** (checks do ALVO que ainda falham) **gera o trabalho**: o autoloop pega o gap → PLANs → gate. O `situacao-vs-visao` passa a ser a saída desses checks, não um texto escrito à mão (alinha com a SPEC-0003).

## Saída esperada

- emenda em `04-artefatos.md` com o nível ALVO;
- `ALVO-0001` derivado do revamp (`02-visao-atualizada.md` + DECISIONs), com os checks iniciais em `.ginga/alvo/checks/`;
- `ginga alvo check`, que mostra o gap e alimenta o autoloop;
- regra de escalonamento humano nos 4 casos acima, substituindo o "pergunte ao dono".

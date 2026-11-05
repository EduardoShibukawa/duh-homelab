---
type: decision
title: Nomes do ecossistema (brasilidades)
status: accepted
timestamp: 2026-10-27
---
## O padrão

Um trocadilho brasileiro com hífen. Nos nomes da família -Ingá, a letra é uma **nota na cifra musical** (G = Sol) ou um prefixo, somada a uma palavra brasileira. O binário usa o nome curto.

| Nome | Leitura | Por quê | CLI |
|---|---|---|---|
| **G-IraG** | *Gira* + *G* (Sol) = **Girassol** | Já documentado no `gira-g/README.md` | `gira` |
| **P-Ingá** | *Pi* + *Ingá* = **pinga** | Pi + Ingá (árvore e fruta brasileira, a de Maringá); junto vira a pinga, a cachaça. *A confirmar com o dono: o "Pi" é o agente Pi ou o π?* | `pinga` |
| **G-Ingá** | *G* (Sol) + *Ingá* = **Ginga** | A ginga da capoeira: o movimento-base que liga tudo e nunca para | `ginga` |
| **Manda-CARU** | **Mandacaru** · *Coordination of Agent Runtime Units* | O orquestrador | `manda` (alias `mandacaru`) |

## Manda-CARU, o orquestrador

Escolhido pelo dono em 2026-10-27. O contexto é Brasil, Maringá e forró.

- **"Manda"** é literalmente o que ele faz: despacha, distribui e decide quem vai. `manda run PLAN-0005` se lê como "manda rodar o PLAN".
- **O mandacaru aguenta a seca.** É o cacto do sertão que sobrevive com quase nada, como um orquestrador feito para render com quota escassa e modelos baratos.
- **É forró de raiz:** "Mandacaru quando fulora na seca é o sinal que a chuva chega no sertão." A flor é o sinal de que vem coisa boa, como o receipt que fecha o PLAN.
- **CARU:** *Coordination of Agent Runtime Units*. Ele coordena unidades de trabalho (TASKs) em runtimes de agentes (Pi, Claude, Codex, OpenCode, AGY).

### Alternativas consideradas

B-Erimbau (berimbau), B-Atuque, C-Iranda, A-Xé, Mand-Ingá (mandinga), Forr-Ingá (forró de Maringá), Mar-Ingá, Mor-Ingá, Rest-Ingá. O dono preferiu Manda-CARU.

## O console

**Roda**, onde tudo acontece à vista de todos. É o nome da interface visual do ginga ([05 — Interface](../design/ginga-revamp/05-interface.md)). Não é um pacote, é a superfície.

## A fazer

Cada repo deve ter um "Name origin" no README, como o gira já tem. TASK no backlog do `index.md`.

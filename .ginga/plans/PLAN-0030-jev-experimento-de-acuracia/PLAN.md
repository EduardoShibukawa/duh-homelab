---
type: plan
title: Jev, experimento de acurácia (máscara, cliente, dataset, eval)
intent: INTENT-0012-jev-e-guarda-de-escopo
spec: SPEC-0004-jev-classificador-e-guarda-de-escopo
kind: investigation
status: approved
repos: [manda]
depends_on: [PLAN-0029-rota-de-falhas-e-disjuntor]
done_when: "cd manda && bun test tests/jev"
---
## Objetivo

Responder com número se o Jev acerta o bastante para substituir regex/leitura manual em quatro classificações: **(1) motivo de `BLOCKED:`**, **(2) log de cota × trabalho real**, **(3) novo × repetido × regressão num achado do judge**, **(4) tier** (só medido). A parte de código é pequena, pura e testável sem rede (máscara, cliente com `fetch` injetável, extração de dataset, `eval`). A medição com chave real é a **Fase 2**, manual.

Hipóteses (cada uma vira uma linha do `LEARNINGS.md`):
- H1: acurácia ≥ 90% em (1) com os rótulos de `BLOCKED:` dos `log.md`.
- H2: ≥ 90% em (2) sobre a cauda mascarada do log, sem o limite de 6000 bytes.
- H3: ≥ 90% em (3), com `ref` e `evidence` das rodadas anteriores como contexto.
- H4: a confiança do Jev é calibrada (média nos acertos bem acima da média nos erros), então um limiar de 0,85 separa o que se pode automatizar.
- H5: o modelo local `lev` (4B) chega perto do Jev hospedado em (1) e (2), textos curtos. Só se o dono instalar o llama.cpp.

## TASKs

1. [TASK-01](TASK-01-mascara.md): `mask()` de segredos e caminhos
2. [TASK-02](TASK-02-cliente-jev.md): cliente `systemone` com providers e `fetch` injetável
3. [TASK-03](TASK-03-perguntas.md): perguntas e parsers dos quatro classificadores
4. [TASK-04](TASK-04-extrair-dataset.md): extrator de dataset dos `log.md`/`runs`
5. [TASK-05](TASK-05-rotular-blocked.md): rótulos manuais de `BLOCKED:` (passada do Planner)
6. [TASK-06](TASK-06-eval.md): `manda jev eval`

Ordem: (01, 02, 04) → 03 → 05 → 06.

## Fase 2 (manual, depois da TASK-06; não é despachada)

> **A aprovação deste PLAN cobre só o código (TASK-01 a 06), que não faz rede.** Ela **não** autoriza a Fase 2: enviar qualquer texto, mesmo mascarado, a um provider exige o OK explícito do dono e a chave dele.

Precisa do dono: **escolher o provider e dar a chave** (OpenCode Zen `OPENCODE_API_KEY`, OpenRouter, TypeSafe ou Vercel) e **autorizar** o envio de texto mascarado de log. Rodar `manda jev eval --provider <p> --dataset tests/fixtures/jev` por classificador; se o dono quiser H5, instalar llama.cpp ≥ 0.6.0 e `llama serve -hf ggml-org/lev-GGUF:Q4_K_M` e rodar com `--provider local`. Registrar no `LEARNINGS.md` e no `log.md`: acurácia, confusão, calibração, latência p50/p95, tokens e custo. O resultado decide o PLAN-0031 (go / no-go / go com limiar).

Antes de qualquer chamada real, conferir à mão 10 amostras já mascaradas. Sem chave, a Fase 2 não acontece e o PLAN-0031 fica parado.

## Interfaces (definidas no plano; mudar = replan)

```ts
// src/jev/mask.ts (TASK-01)
export function mask(text: string, opts?: { home?: string; maxChars?: number }): { text: string; redactions: number };
// src/jev/client.ts (TASK-02)
export type JevProvider = "opencode" | "openrouter" | "typesafe" | "vercel" | "local";
export type JevQuestion =
  | { type: "choice"; instructions: string; criteria: Record<string, string | null> }
  | { type: "noul"; instructions: string };
export type JevAnswer =
  | { type: "choice"; choice: string; probabilities: Record<string, number>; confidence: number }
  | { type: "noul"; noul: number };
export type JevResult = { answers: Record<string, JevAnswer>; usage: { input_tokens: number; output_tokens: number }; latency_ms: number };
export function createJevClient(cfg: { provider: JevProvider; apiKey?: string; model?: string; url?: string; timeoutMs?: number }, fetchImpl?: typeof fetch):
  (req: { state: unknown; questions: Record<string, JevQuestion> }) => Promise<JevResult>; // lança JevError{status}
// src/jev/questions.ts (TASK-03)
export type Classifier = "blocked" | "quota_log" | "finding_novelty" | "tier";
export function buildRequest(c: Classifier, input: Record<string, unknown>): { state: unknown; questions: Record<string, JevQuestion> };
export function parseAnswer(c: Classifier, r: JevResult): { label: string; confidence: number; probabilities: Record<string, number> };
```

## Riscos

- O endpoint do Jev e o formato dos providers mudam (OpenCode Zen usa `https://opencode.ai/inference/systemone/v1/systemone` na doc; o `jev-gateway` usa `https://opencode.ai/zen/v1/systemone`). O cliente lê a URL de uma tabela de dados e aceita `url` explícita; a Fase 2 começa com uma chamada de teste sintética.
- Poucos rótulos de `BLOCKED:` (~10 a 30): a acurácia terá intervalo largo. O relatório do `eval` mostra o `n` e o intervalo de Wilson; com n < 30 o veredito é "indicativo".
- Rótulo de (2) vem da regex atual (circular) → a TASK-04 só inclui como positivo/negativo os casos em que o resultado da tentativa confirma (retry bem-sucedido depois de cota, ou trabalho real que cita "429").
- Privacidade: o `mask()` é obrigatório no caminho; teste com segredos falsos. Nenhum teste faz rede.

---
type: plan
title: Jev nos classificadores do manda (sombra primeiro, regra como piso)
intent: INTENT-0012-jev-e-guarda-de-escopo
spec: SPEC-0004-jev-classificador-e-guarda-de-escopo
kind: change
status: draft
repos: [manda]
depends_on: [PLAN-0029-rota-de-falhas-e-disjuntor, PLAN-0030-jev-experimento-de-acuracia]
done_when: "cd manda && bun test"
---
## Objetivo

Ligar o Jev **só nos classificadores que o PLAN-0030 aprovar** (go ou go com limiar), como camada em cima da regra determinística: a regra responde primeiro; o Jev entra quando a regra devolve `other`/ambíguo ou quando a regra não consegue ver (log longo). Erro, timeout, confiança abaixo do limiar, orçamento esgotado ou chave ausente → vale a regra (fail-open). Começa em `shadow` (registra concordância sem agir) e só vai a `on` por decisão do dono depois de ler o relatório de sombra.

**Este PLAN fica em `draft` de propósito e só é aprovado depois que a Fase 2 do PLAN-0030 der go para ao menos um classificador** (a dependência `depends_on` não consegue expressar essa decisão humana: sem isso o dispatcher o iniciaria assim que o código do 0030 fechasse). TASKs de classificadores que não passaram ficam `blocked` com o motivo, sem replan.

## Decisões que este PLAN implementa

- `[jev]` em `project.toml`: `mode = "off" | "shadow" | "on"` (padrão **off**), `provider`, `model`, `min_confidence = 0.85`, `classifiers = [...]`, `timeout_ms = 4000`. Sem chave no ambiente, `mode` efetivo = `off`.
- Jev **pago** passa pelo `budget.ts` e pelo `ALLOW_PAID`/`paid-spend` como qualquer chamada paga (custo ≈ US$ 0,0001 por classificação curta, mas o contador existe). Free (OpenCode Zen `jev-1.13-free`) e `local` não contam.
- Todo texto passa por `mask()` (PLAN-0030) antes de sair. Nunca handoff, segredo ou dado do dono: só `blocked_text`, cauda de log e achados do judge.
- Eventos v1 novos, sem quebrar `v:1`: `jev.call` (classifier, provider, model, latency_ms, tokens, cost_usd, outcome) e `jev.shadow` (classifier, rule_label, jev_label, confidence, agree).

## TASKs

1. [TASK-01](TASK-01-config-jev.md): configuração `[jev]` e chave por ambiente
2. [TASK-02](TASK-02-orcamento-e-eventos.md): custo no budget e eventos `jev.call`/`jev.shadow`
3. [TASK-03](TASK-03-camada-hibrida.md): `classifyWith(rule, jev)` genérico, fail-open
4. [TASK-04](TASK-04-blocked-hibrido.md): `classifyBlocked` com Jev no resíduo `other`
5. [TASK-05](TASK-05-cota-por-log.md): cota × trabalho real em log longo (`classifyRunnerFailure`)
6. [TASK-06](TASK-06-novidade-do-judge.md): novo × repetido × regressão no judge
7. [TASK-07](TASK-07-verbos-jev.md): `manda jev status|shadow-report`

Ordem: (01) → (02, 03) → (04, 05, 06) → 07. 04, 05 e 06 são independentes entre si e cada uma só roda se o seu classificador passou no PLAN-0030.

## Interface (definida no plano; mudar = replan)

```ts
// src/jev/hybrid.ts (TASK-03)
export type Mode = "off" | "shadow" | "on";
export type Labeled = { label: string; confidence: number; source: "rule" | "jev" };
export async function classifyWith(o: {
  classifier: Classifier;
  rule: () => Labeled | null;          // null = a regra não sabe
  jev: () => Promise<Labeled>;         // chama o cliente, já mascarado
  mode: Mode; minConfidence: number;
  budgetOk: () => boolean;
  emit: (e: { kind: string; data: Record<string, unknown> }) => void;
}): Promise<Labeled>;
```
Garantias: `off` nunca chama o Jev; `shadow` chama ao lado, devolve a regra (ou `other` se a regra não sabe) e emite `jev.shadow`; `on` devolve o Jev só se `confidence ≥ minConfidence` e `budgetOk()`, senão a regra; qualquer exceção do Jev vira a regra e um `jev.call` com `outcome: "error"`.

## Riscos

- Calibração ruim: o limiar vem do PLAN-0030 (H4); na dúvida fica em `shadow`.
- Free "por tempo limitado" some: `provider` troca por configuração; sem chave, `off`.
- A integração toca `src/blocked.ts` (PLAN-0029) e `src/runtime/failure.ts`; por isso depende do 0029 inteiro.
- O Jev pode ser influenciado por texto dentro do log ("ignore as instruções…"): a ação do `on` é sempre limitada às classes fechadas e às ações já mapeadas (`retry_clean`, `skip_tier`, `replan`, `notify`); nenhuma classe do Jev executa comando.

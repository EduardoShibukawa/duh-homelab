---
type: task
mode: padrao
goal: "manda jev eval roda um classificador contra um dataset e reporta acurácia, matriz de confusão, calibração, latência, custo e o veredito go/no-go"
title: manda jev eval
plan: PLAN-0030-jev-experimento-de-acuracia
repo: manda
depends_on: [TASK-02-cliente-jev, TASK-03-perguntas, TASK-05-rotular-blocked]
tier: medium
touch: [src/jev/eval.ts, src/verbs.ts, src/cli.ts, tests/jev/eval.test.ts]
done_when: "bun test tests/jev/eval.test.ts"
tests_frozen: [tests/jev/eval.test.ts]
---
## Fazer
- `manda jev eval --classifier blocked|quota_log|finding_novelty|tier --provider <p> --dataset <dir> [--min-conf 0.85] [--json]`.
- Para cada exemplo: `buildRequest` → cliente → `parseAnswer`. Métricas: acurácia geral e por classe, matriz de confusão, `n` e intervalo de Wilson de 95%, confiança média nos acertos × erros, acurácia com o limiar `--min-conf` (cobertura × acurácia), latência p50/p95, tokens, custo estimado (US$ 0,042 por 1M de entrada no Jev pago; 0 no free e no local).
- Veredito: `go` (≥ 90%), `go_com_limiar` (80% a 90% e ≥ 90% acima do limiar com cobertura ≥ 50%), `no_go` (< 80%). Com `n` < 30, acrescentar `indicativo: true`.
- Baseline lado a lado quando houver `regex_label`. `weak: true` (tier) nunca gera `go`.
- Antes de qualquer chamada, imprime quantas amostras e **o provider**, e exige `--yes` quando o provider não é `local` (confirma o envio de texto mascarado a terceiro).
## Interface
- Teste com cliente falso (`fetchImpl`) e dataset sintético: métricas exatas, vereditos nos três casos, `--yes` obrigatório, `local` dispensa.
## Não fazer
- Nenhum teste faz rede. Não ler chave de arquivo; só de variável de ambiente. Não gravar prompt ou resposta em disco; só métricas.
## Contexto
- SPEC-0004 (meta ≥ 90%, < 80% fora).

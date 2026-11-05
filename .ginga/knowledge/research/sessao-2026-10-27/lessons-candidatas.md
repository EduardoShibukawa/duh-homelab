---
type: lesson
title: Lessons candidatas da sessão 2026-10-27 (ondas 1–2)
source: analise.md
timestamp: 2026-10-28
---

# Lessons candidatas (promoção do PLAN → knowledge/lessons)

> Formato do doc 06 §5. Máximo 8, só as reutilizáveis. Status: `fato` (ambiente/código) ou `armadilha` (não faça X).

## LESSON-01 · armadilha · opencode 2.1 e a porta 49374
- **hipótese:** o executor roda isolado com `--share-net`.
- **evidência:** 3 clientes travados 1h30, 0% CPU, presos no serviço compartilhado da porta 49374.
- **conclusão:** use `opencode run --standalone` (servidor privado) + `timeout` por tentativa. O serviço compartilhado é ponto único de falha.
- **escopo:** `.ginga/bin/dispatch-task.sh`; perfil de runtime do manda (PLAN-0007/0008).

## LESSON-02 · armadilha · contrato novo × teste antigo
- **hipótese:** o teste congelado antigo continua válido quando o contrato muda.
- **evidência:** 0005 TASK-09 travou 6 tentativas: `receipt_events.test.ts:86` exigia `reason_code === null` contra o v1 (chave ausente).
- **conclusão:** antes de despachar, rode **todos** os testes do `done_when` contra o contrato novo. Conflito de contrato vai para o Planner, nunca para o executor.
- **escopo:** Planner (passada RED); INTENT-0008 §4.

## LESSON-03 · armadilha · `pinga_task` único por repo
- **hipótese:** o próximo `T<N>` livre é óbvio.
- **evidência:** dois PLANs usaram T58 no pi-harness; colisão só apareceu no merge.
- **conclusão:** confira no ledger (`select distinct task … where repo like '%<repo>%'`) antes de atribuir o id.
- **escopo:** Planner; INTENT-0008 §4.

## LESSON-04 · armadilha · alfabeto base32 dispara o AC-SEC
- **hipótese:** o detector de segredos só pega segredos reais.
- **evidência:** o alfabeto Crockford (ULID) foi marcado como entropia alta e barrou o commit.
- **conclusão:** strings de alfabeto (base32) disparam o detector de entropia; concatene dígitos + letras.
- **escopo:** pre-commit AC-SEC do p-inga.

## LESSON-05 · fato · `prove-red` exige base commitada
- **hipótese:** `prove-red` aceita teste frozen não commitado.
- **evidência:** respondeu "sem base" quando o teste frozen ainda não estava commitado.
- **conclusão:** demonstre o RED à mão e registre no `log.md`; ou passe `--base <sha>`.
- **escopo:** `p-inga/src/prove.ts`.

## LESSON-06 · fato · sintaxe do `-p` do AGY
- **hipótese:** `agy -p "<prompt>" --model X` funciona.
- **evidência:** "Error: -p took '--model' as its prompt" — o `-p` recebe o prompt como valor.
- **conclusão:** o `-p` vem **por último** (`agy --model X --effort high --add-dir … -p "<prompt>"`); o JSON sai em várias linhas.
- **escopo:** `.ginga/prompts/judge.md`; futuro `.ginga/bin/judge.sh`.

## LESSON-07 · fato · custo pago medido como US$0 não é confiável
- **hipótese:** o custo medido pelo script reflete o gasto real.
- **evidência:** tentativa paga do `deepseek-v4-pro` registrou US$0; o total real ficou acima de US$0,54.
- **conclusão:** a medição não capta toda sessão paga; confira no painel do provider antes de confiar no teto.
- **escopo:** `.ginga/bin/dispatch-task.sh`; PLAN-0014 (métricas e quota).

## LESSON-08 · armadilha · Claude não executa TASK
- **hipótese:** o Claude pode despachar/implementar quando o operador barato está disponível.
- **evidência:** "pq vc ta fazendo tudo em vez de usar subagents ta acabando a quota" — o Claude escreveu testes, TASKs e prompts de judge direto.
- **conclusão:** o Claude só faz contrato, testes RED e merge; execução é do Pi/executor (Zen free). Precisa de enforcement (hook/gate), não só doc.
- **escopo:** `.ginga/prompts/operador.md`; roteamento de papéis (08-execucao.md §2).

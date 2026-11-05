---
type: research
title: Cobertura da visão 02 pelos PLANs (2026-10-29)
date: 2026-10-29
---
# Cobertura da visão 02 pelos PLANs (2026-10-29)

Análise só leitura (subagente) da [visão 02](../design/ginga-revamp/02-visao-atualizada.md) + decisões 1–21, INTENTs 0006/0008/0009/0010/0011 e SPECs 0001–0003, cruzada com os PLANs e o código dos repos.

## Coberto (done ou approved)

Eventos v1 (0004), lint/OKF (0004), pinga TASK/PLAN (0005), install no ginga (0006/0026), manda + runtime port (0007), routing/budget/judge cego (0008), tick/serve/notify (0010), sandbox do done_when (0018/0021), merge gate + hooks (0022/0024/0025), vigia/supervisor (0023/0027), porta de contexto + A3 (0009), verbos/API/auth/triagem (0011), init/homelab (0015).

## Lacunas, em ordem de prioridade (nenhum PLAN cobre)

1. **Ciclo autônomo do PLAN aprovado** (manda + ginga). Hoje a passada RED e o replan são prompts manuais, e a lane ainda roda um operador LLM. TASKs propostas: `manda red <PLAN>`; alocação determinística do `pinga_task`; fase do PLAN no `state.db`; o tick avança RED → TASKs → judge → merge; replan após 3 falhas; o supervisor troca o operador pelo tick (fecha 0022 T03 e 0023 T06); e2e sem humano.
2. **Desbloqueio automático e rota de falhas** (INTENT-0008 e as 8 regras da SPEC-0003): classificador de `BLOCKED:`, TASK de desbloqueio, verbos de recuperação no manda, `fail_triage` do Judge.
3. ~~PLAN-0006 TASK-04 nunca rodou~~ → reaberto e posto na lane p-inga em 2026-10-29.
4. **Gate plugável** (`[commands].gate`; o manda ainda chama o `pinga` direto em `merge.ts:228,289`) e o gira emitindo `$GINGA_EVENTS`.
5. **Trilha feature**: Spec Researcher e Spec Judge, estados `spec_draft`/`spec_review`.
6. **Porta Sandbox fase 2** (INTENT-0006, doc 10): executor isolado, perfis, rede, outbox, matriz.
7. **Skills e hooks do host** (SPEC-0002 em draft).
8. **OTLP + OpenInference** (decisão 15): `trace_id`, ponte para spans, `/v1/traces`.
9. **`bench/` e a porta de bench.**
10. **ALVO + `ginga alvo check`** (INTENT-0011).
11. **Organização**: LICENSE MIT (nenhum repo tem), renomear para `g-inga`, `worktrees/`, AGENTS.md único (INTENT-0007, DECISION-0003/0004).

## PLANs desatualizados

- **0014**: ainda aponta para o `pi-harness` (repos, done_when, TASK-02/06); a raiz não tem `bench/`; faltam as emendas da SPEC-0003.
- **0013**: ignora o `pinga learn`/`lessons`, que se sobrepõem a ele; deve adotar o formato atual do `log.md`; as referências ao pi-harness devem virar `_archive/`.
- **0012**: faltam o painel de alertas e os traces; ninguém entrega `ginga status --json`, que o 0017 TASK-04 precisa.
- **0016**: sem `done_when` e sem TASKs; `repos: [bench]` não existe; a TASK-02 já foi começada pelo 0019.
- **0017**: depende de 0012/13/14 (draft) e não tem arquivos de TASK.
- **0006/0008**: as emendas pedidas pelas INTENTs 0008/0009 e pela SPEC-0003 nunca entraram nelas e viraram as lacunas 2 e 7.

## Decisões do dono para os PLANs das lacunas 1 e 2 (2026-10-29)

- **Lacuna 1 primeiro**: o operador custou ~12x o executor por TASK verificada (US$ 0,65 tudo incluído vs US$ 0,05 do executor; ver [eficiência do framework](eficiencia-framework-2026-10-29.md)). Em 29/10 o Zen dividiu ~54% operador / ~45% executor (o `paid-spend.tsv` subnotifica o executor). Somando os `claude -p` (US$ 19), o operador é ~65% do gasto do framework. O tick determinístico no lugar do operador é a melhoria de eficiência nº 1.
- **Tempo não é restrição** ("1 h ou 10 min não muda nada"): sem teto de execução; mede **progresso**, não relógio. `[routing] patience`, `no_progress_min`, como parâmetros.
- **Quatro estados**, não um timeout: *devagar* (eventos no stream → esperar), *na fila* (conexão aberta, zero bytes, probe ok → esperar até a paciência), *travado* (sem eventos/CPU/arquivos e probe falha → matar, disjuntor, outro free de outro provider), *recusado* (ECONNRESET/5xx/quota → disjuntor, próximo).
- **Nunca repetir às cegas**: só volta a um modelo depois de um **probe** barato ("responda só: ok", 1–4 s quando saudável) passar.
- **Disjuntor por modelo** no `state.db` (aberto 10 min → 30 min → 2 h; meio-aberto = probe), compartilhado entre lanes; implementa o `breaker` do frontmatter do ROUTING.
- **Escada por custo**: free saudável de qualquer provider (iceman, `pi:nvidia/minimax-m3.1-flash`, NVIDIA quando a fila andar) → pago (qwen) só com todos os free de disjuntor aberto. Sem fork do Pi: a porta de runtime do manda + ROUTING aceitam providers novos. Ver [PROVIDER-nvidia](../../models/PROVIDER-nvidia.md).
- **Teto de custo cobre o operador também** (o `TOTAL_CAP` de hoje só via o executor).
- Judge: Codex sem cota até 25/11; fallback `opencode/gpt-6-luna` (Zen) já no `judge-run.sh`.
- Armadilha: `opencode run`/`pi -p` sem `< /dev/null` esperam o stdin e "travam" (invalida testes de modelo).
- **Só três papéis LLM, todos chamados por código** (dono, 2026-10-29): *Planner* (PLAN + TASKs + **interfaces + `tests_frozen` no planejamento inicial**; a "passada RED" separada some), *Executor* (chamada determinística, resultado não determinístico, aceito/rejeitado por `verify`+judge+gate), *Judge* (outra família). **Replan = o mesmo Planner com mais contexto** (TASK, receipts, `reason_code`, achados do judge, diff), disparado por código (disjuntor / achado grave), nunca por um LLM vigiando. O **operador LLM deixa de existir**: tick, ids, worktrees, verify, gate, disjuntor e notificação são código.
- Consequência: interface que precisa mudar depois do plano = sinal de replan, não ajuste do executor.
- **Teto de custo medido pelo `opencode.db`/sqlite**, não pelo `paid-spend.tsv` (que grava US$ 0 nas tentativas maiores e ficou cego: US$ 0,54 registrados vs US$ 3,55 reais em 27/10).
- **Handoff automático** (ideia do dono, já usada no trabalho para o Claude): gatilho = cache prestes a expirar (ociosidade > TTL) **ou** contexto da conversa acima de ~100–120k tokens; gera o handoff (`ginga handoff`, determinístico) e abre sessão nova com ele. Por runtime: mod/hooks no Claude, plugin no opencode, extensão no Pi. Skill de handoff como fonte única em `.ginga/skills/` (SPEC-0002); formato vira a saída do PLAN-0013.

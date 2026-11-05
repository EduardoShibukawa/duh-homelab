---
type: plan
title: Vigia e supervisor no g-inga (substitui o monitor improvisado de 2026-10-28)
intent: INTENT-0010-observabilidade-operacional
spec: SPEC-0003-observabilidade-operacional
kind: feature
status: approved
repos: [ginga, manda]
depends_on: [PLAN-0010-tick-serve-notifier, PLAN-0022-merge-gate-no-pacote]
---
## Objetivo
Levar para o harness o monitor que hoje está espalhado em 4 peças improvisadas:
- o `Monitor` da sessão do Claude (morre com ela);
- o vigia dentro do `.ginga/bin/lane.sh`;
- o `.ginga/bin/vigia.sh` num timer systemd transitório;
- o `.ginga/bin/notify.sh` (retry + fila).

Princípio (visão 02, `determinismo-e-placement.md`): **detectar e agir é determinístico; o LLM só faz o que exige julgamento**. Nenhuma peça de vigilância pode depender de uma sessão de agente estar aberta.

## Desenho (3 camadas, cada uma num processo próprio)
1. **Emissão (quem trabalha):** lanes, operador, executor, judge e gate emitem eventos v1 em `$GINGA_EVENTS`: `heartbeat{entity,pid,progress}`, `lane.round{start|end}`, `gate.result{plan,repo,code}`, `alvo.check`. **Progresso** é um contador de efeito real (arquivos alterados na worktree, commits, receipts, saída de ferramenta), nunca "o processo está vivo" nem "o log cresceu".
2. **Supervisor + vigia (`ginga serve`, unidade systemd instalada pelo `ginga install`, sobrevive a qualquer sessão):**
   - supervisiona as lanes (uma por repo, com o `manda pipeline` do PLAN-0022): sobe, reinicia com backoff e para quando não há pendência;
   - roda as regras de `.ginga/watch/rules.toml` (SPEC-0003) a cada tick.
3. **Ação e entrega:** as regras chamam os verbos da rota de falhas do manda (`kill_and_retry`, `rotate_model`, `breaker_unblock`, ...) e o notifier do PLAN-0010 com severidade, dedupe, digest e **fila durável** (entrega pelo menos uma vez; o que falhou vai na próxima conexão).

## Regras novas (lições de 2026-10-28, cada uma com fixture do incidente real)
- `no_progress`: entidade viva sem `progress` novo por N min → `kill_and_retry` + `rotate_model`. Incidente: beam-free emitindo só "> build" por 80 min com 0% de CPU.
- `lane_dead`: lane sem heartbeat e com pendência → reinício pelo supervisor. Incidente: as lanes morreram com a sessão do Claude às 16:20, sem nenhum aviso.
- `main_moved_outside_gate`: `refs/heads/main` mudou sem `gate.result` correspondente → CRÍTICO. Incidentes: merge do PLAN-0008 sem judge; operador rodando o gate.
- `judge_shopping`: mais de 1 veredito para o mesmo HEAD → alerta.
- `report_mismatch`: o operador afirma `pass`, mas o receipt não está `done` → alerta. Incidente: o report da rodada 1 com "T10–T14 pass".
- `goal_reached`: nenhuma pendência + todos os checks do ALVO (INTENT-0011) verdes → **um** aviso ao dono "tudo pronto", com o resumo do REPORT.

## TASKs
- TASK-01 (ginga) heartbeat/progress e `lane.round`/`gate.result` no schema v1 + fixtures dos 6 incidentes.
- TASK-02 (ginga) `ginga watch` (avaliador de `rules.toml`), com um teste por regra contra a fixture.
- TASK-03 (ginga) supervisor no `ginga serve` + a unidade systemd no `ginga install`.
- TASK-04 (ginga) fila durável do notifier (substitui o `notify.sh`).
- TASK-05 (manda) verbos `kill_and_retry` e `rotate_model` + a emissão de heartbeat pelo `manda pipeline`.
- TASK-06 corte: aposentar `.ginga/bin/{lane,vigia,notify,pipeline,autoloop}.sh` e o timer `ginga-vigia` (arquivar em `_archive/` com MANIFEST).

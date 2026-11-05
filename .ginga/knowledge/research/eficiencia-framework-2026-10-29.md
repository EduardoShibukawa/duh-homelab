---
type: research
title: Eficiência do framework (operador, executor, judge) de 26 a 29/10/2026
date: 2026-10-29
---

# Eficiência do framework, 26–29/10/2026

Escopo: só agentes automáticos (lanes, dispatch, judge). Fontes: `opencode.db` (custo e tokens por sessão; o total bate com `opencode stats`), 61 logs `claude -p` em `handoffs/lane-*.log`, `lanes.events` (430 linhas, 151 rodadas iniciadas), `plans/*/log.md` (tentativas), `paid-spend*.tsv`, 90 logs de judge, `~/.pi/agent/sessions`. Planner automático: nenhuma sessão no escopo (a passada RED foi interativa), custo não atribuído. "Contexto" = input + cache read + cache write.

## 1. Custo e tokens por papel e modelo

| Papel | Modelo (runtime) | Sessões | Custo US$ | Tokens (contexto / gerados) | Resultado |
|---|---|---|---|---|---|
| Operador | claude-sonnet-5-5 (`claude -p`, 28–29/10) | 61 | **19,24** (nominal) | 47,0 M / 0,47 M; 783 turnos, 284 min | 17 rodadas produtivas = 13,57; 26 sem trabalho = 5,39; 18 "5-hour limit" = 0,28 |
| Operador | opencode/qwen3.8-flash (29/10) | 23 | **2,16** | 82,1 M / 0,86 M | 13 rodadas com trabalho (US$ 0,05–0,50); 8 sessões de 1 passo (falha de infra) |
| Operador | beam-free (28/10) | 41 | 0 | 179,1 M / 0,81 M | free, mas é o maior consumidor de tokens do período |
| Operador | glm-5.3-flash-free (28/10) | 27 | 0 | 35,8 M / 0,32 M | free |
| Operador | Pi deepseek-v4-pro (28/10) | 2+ | ~2,5 (spend `:off`) | n/d | `fix-tudo` 2,02 + `pesquisa` 0,52. O store do Pi soma US$ 3,96 / 199 passos e mistura sessões do dono |
| Executor | qwen3.8-flash (28–29/10) | 56 | **1,80** | 53,3 M / 1,0 M | 37 pass / 12 fail = 76%; mediana 4,2 min e 19 passos; ~US$ 0,05 por pass |
| Executor | deepseek-v4-pro (strong, 27–28/10) | 14 | **3,99** | 12,0 M / 0,24 M | 2 pass / 5 fail = 29%; ~US$ 2,0 por pass |
| Executor | glm-5.3-flash-free | 64 | 0 | 36,2 M / 0,72 M | 35 / 15 = 70% |
| Executor | deepseek-v4.1-flash-free | 37 | 0 | 28,6 M / 0,46 M | 17 / 12 = 59% |
| Executor | beam-free · iceman | 21 · 5 | 0 | 48,7 M · 9,8 M | 3/8 = 38% · 0/4 |
| Executor | nemotron-3-ultra-free · Go (kimi-k3, glm-5.3, qwen3.8-max) | 46 · 9 | 0 | ~0 | **0/46 e 0/6**: falham no 1º passo (`command_failed`) |
| Judge | Codex gpt-6-luna (assinatura) | 90 logs | n/d | ~28 k por tentativa falha | 64 vereditos válidos; **26 falhas por cota** (29/10, todas PLAN-0009/p-inga) |
| Judge | fallback opencode/gpt-6-luna | 3 | 0,05 | 1,4 M / 0,02 M | funciona (no ar desde ~13:57 de 29/10) |

Totais: opencode em 4 dias = US$ 8,49 (qwen 3,96, deepseek-pro 4,47, resto 0,06); claude lanes US$ 19,24 (equivalente de API, assinatura); Pi até US$ 4. Ordem de grandeza **US$ 28–32, ~65% em operador**. Contexto (opencode): operador 297 M, executor 189 M, judge 1 M. Tokens gerados: operador 2,0 M, executor 3,0 M.

**Custo por TASK verificada** (34 TASKs com `pass` em 29/10 + 2 de 28/10 na mesma janela):
- Janela 28/10 23:40 a 29/10 16:30, tudo incluído (claude 19,24 + Zen 3,96 + judge 0,05): ~US$ 23,3 / 36 = **US$ 0,65 por TASK**. Só o executor: US$ 1,80 / 36 = **US$ 0,05**. O operador custou ~12x o executor.
- Era deepseek-pro (27–28/10): US$ 3,99 por 2 TASKs = ~US$ 2,0 por TASK, sem contar o free que falhou antes.
- Era free (27/10): 44 pass / 68 fail (39%), US$ 0 em dinheiro, mas custou horas e 46 tentativas nemotron mortas.

**Onde se concentrou:** (1) `claude -p` como operador, ~60% do dólar nominal; (2) operador qwen, 54% do gasto Zen de 29/10; (3) deepseek-pro "strong" em 27/10 (US$ 3,55 em 11 sessões).

### Correções aos fatos conhecidos
- **Qwen em 29/10: US$ 3,96 / 137 M tokens confere, mas o executor NÃO foi ~US$ 0,20.** Pelo `opencode.db` o executor gastou **US$ 1,80 (45%)** e o operador US$ 2,16 (54%). O `paid-spend-*.tsv` soma só US$ 0,75: grava `US$0 (custo medido)` nas tentativas maiores (PLAN-0015 TASK-01 com 0,10 e 0,13; PLAN-0006 TASK-04 com 0,14; PLAN-0015 TASK-03 com 0,08). Em 27/10 o arquivo registrou US$ 0,54 contra US$ 3,55 no DB (6,5x a menos). A frase "operador = ~96% do Zen" nas decisões do dono vem desse arquivo e subestima o executor. O operador segue sendo o maior item e o que sai.
- `claude -p` ~US$ 20 em 64 sessões: confere (61 logs com `result` = US$ 19,24). Causa: `lane.env.bak-2026-10-29-claude` tem `OP_MODELS=claude/claude-sonnet-5-5`, e o `TOTAL_CAP=1.80` só olhava o executor. O ROUTING declara `operador: [opencode-go/deepseek-v4.1-flash]` e `ask_owner: [runtime_claude]`; não achei aprovação registrada nos logs.
- Codex sem cota (volta em 25/11): confere. Free instáveis: confere (10 `infra_stuck`, 20 trocas por cota, 6 "todos sem cota", lane pausada).

## 2. Fomos eficientes? Onde não

- **Rodadas sem progresso: ~45 de 151 (30%).** 23 no p-inga e 17 no ginga terminaram em "sem progresso, lane parada", e o vigia (timer de 10 min) relançou a lane toda vez, porque o `ready/*.json` pendente mantém `pend>0`. Entre 09:23 e 13:18 foram 26 rodadas claude "nada a fazer" (5–9 turnos, US$ 0,11–0,26): **US$ 5,39 (28% do claude)** para reler `index.md`, `ls plans`, `harness_status` e `cat REPORT-...` e concluir de novo que o achado A6 é "pendência do dono" (17 vezes o mesmo).
- **Judge repetido contra cota:** 26 execuções do Codex no PLAN-0009/p-inga, uma por rodada ociosa, todas "usage limit". Barato, mas girou 4 h sem checar cota antes.
- **Infra que queimou tempo e contexto:** 10 `infra_stuck` (cada um ≥15 min sem progresso, só então mata); 18 rodadas claude batendo no limite de 5 h; rajada 07:44–07:51 com 4 lanes x 4 rodadas de 1 passo e 0 trabalho (rotação cega de modelo, sem probe); 7 sessões de executor free abertas por 6–12 h (serviço compartilhado do opencode, hoje mitigado por `--standalone` e `ATT_TIMEOUT`); 3 "CRÍTICO: main mudou durante o operador" (o gate pegou, mas o operador mexeu onde não devia).
- **Re-trabalho do executor:** de 56 TASKs (28–29/10), 43 passaram na 1ª tentativa (77%), 5 precisaram de 2–3, 2 chegaram a 8 e 11 (nemotron). Das 36 falhas, **16 foram `scope_drift`** (ex.: `__pycache__/*.pyc` fora do `touch`, corrigido à mão pelo operador com `PYTHONDONTWRITEBYTECODE=1`), 9 `command_failed`, 8 receipt/outro.
- **Modelo errado no lugar errado:** deepseek-pro "strong" gastou US$ 3,99 em 7 tentativas; as 5 falhas foram todas `BLOCKED` (teste congelado contradiz o PLAN, ou dependência ausente), algo que nenhum modelo mais forte resolve: era replan do Planner. nemotron 0/46 e Go 0/6 continuaram na escada; beam-free como operador consumiu 179 M de contexto sem entrega medida.
- **Contexto inchado:** o operador qwen faz até 143 passos com ~134 k tokens por passo (ginga r5: 19 M de cache read, 88 min, US$ 0,50). Prompt da lane do ginga = 16 KB, dos quais 8,5 KB são itens `[x]` do backlog (63%). `REPORT-2026-10-28.d` tem 82 arquivos e `decisoes.md` 61 KB, relidos nas rodadas ociosas. O `edit` do opencode falha 11,4% (965 chamadas): cada falha é um passo com contexto cheio.
- **Saídas grandes** (poucas, mas existem): 110 saídas >15 KB nos executores e 56 nos operadores, truncadas em ~51 KB (cat de `judge/*.json`, `tail` de `runs/`, `read` de `src/cli.ts` com 58 KB, 3 vezes na mesma sessão). `bun test` não foi problema: média de 0,5–0,9 KB (já vem filtrado). Releituras do mesmo arquivo: 32 no executor (103 KB), desprezível frente ao crescimento de contexto.

## 3. O que foi muito bom

- **Gate determinístico + judge separado:** 46 merges com `merge-gate` exit 0 (27 em 28/10, 19 em 29/10); o judge reprovou 111 itens e apontou 9 regressões; os exits 11/12/13/2 barraram merges ruins; o gate detectou 3 vezes o operador alterando a `main` fora do processo. O fallback luna custou US$ 0,05 e manteve o fluxo com o Codex fora.
- **Executor barato e eficaz:** qwen3.8-flash 76% de pass, ~US$ 0,05 por TASK, mediana 4 min. Sem o operador, é a parte que escala.
- **`tests_frozen` + RED prévio + sandbox:** 77% de 1ª tentativa; `scope_drift` e `tests_frozen_changed` dão causa objetiva da falha.
- **Rollback por snapshot** (`dispatch-task.sh`) e **veredito por HEAD** (`judge-run.sh`, sem judge shopping) evitaram retrabalho e fraude.
- **Detecção de cota** (log <6 KB + regex) e `.free-esgotado` evitaram loops mais caros; `infra_stuck` por progresso (não por relógio) é a base certa do disjuntor.

## 4. Skills, prompts e tools

- **Tools:** nos 61 logs claude só aparecem `Bash` (745), `harness_status` (16), `Monitor` (10), `Write` (8). Nenhuma skill (`/pinga`, `/red-audit`) nem MCP gira foi chamado: skills não pesam nas lanes. No opencode: `shell` 7,6 k, `read` 1,4 k, `edit` 965, `skill` 10, `execute` 29, `websearch` 1 (25 KB, desperdício). `harness_status` ajudou (substitui várias leituras), mas é chamado depois de 3–4 `ls/cat`.
- **Custo fixo por rodada:** ~28 k tokens de contexto antes da 1ª ação (CLAUDE.md + op-base + backlog); rodada vazia custa US$ 0,11–0,14 só nisso.
- **Mudar enquanto o operador existir:**
  - `op-base.md`: o `lane.sh` deve embutir um **resumo de estado pré-calculado** (`pinga queue`, achados do judge classificados `dono|executável`, TASKs bloqueadas) e a regra "se nada for `executável`, responda `NADA` e saia". Hoje o prompt faz o operador ler `index.md` e reconstruir tudo.
  - `op-base.md`: definir "item" = **uma TASK** (o backlog do PLAN-0015 tinha 3 TASKs sob um item e o qwen gastou raciocínio decidindo); proibir `cat` de `REPORT*.d` e `decisoes.md` (um script acrescenta a linha).
  - `lane.sh`: não chamar o operador sem `[ ]` aberto nem achado `executável`; limite de passos (kill por ~60 passos ou US$ 0,25); recusar `claude/*` em `OP_MODELS` sem flag do dono; arquivar os `[x]` do backlog; backoff exponencial no relançamento do vigia após "sem progresso".
  - `dispatch-task.sh`: `export PYTHONDONTWRITEBYTECODE=1` e ignorar `*.pyc`/`__pycache__` no teste de escopo (16 de 36 falhas); tirar nemotron, Go e iceman da escada default; ler o custo da sessão **depois** de o processo terminar, via sqlite (`session_v2.cost`), com tokens como reserva, e nunca gravar `0` se a sessão existe; `ATT_TIMEOUT` por progresso, não 1200 s fixos.
  - `planner-red.md`: interfaces e `tests_frozen` no 1º plano, mais um passo "conferir contradição entre teste e TASK" antes do `prove-red`; hoje a contradição só aparece no executor (as 5 falhas `BLOCKED` caras).

## 5. Recomendações priorizadas (economia estimada, alinhadas às decisões do dono)

| # | Ação | Economia estimada |
|---|---|---|
| 1 | **Tick determinístico no lugar do operador** (ids, worktrees, verify, gate e notificação por código; Planner/Executor/Judge chamados por código) | ~US$ 24 de ~US$ 30 (≈75%) e ~345 M de ~600 M tokens de contexto; elimina as ~45 rodadas ociosas |
| 2 | **Teto de custo cobrindo todos os papéis**, medido no `opencode.db` (e no `result` do claude), com teto por dia e por PLAN e parada dura | Evita repetir os US$ 19 do claude sem teto; corrige a subcontagem de 2,4x a 6,5x do `paid-spend` |
| 3 | **Replan pelo mesmo Planner** (TASK, receipts, `reason_code`, diff) em vez de subir para "strong"; strong só por ordem do dono | ~US$ 3–4 por onda (deepseek-pro: US$ 2/TASK, 5 de 5 falhas eram contradição/dependência) |
| 4 | **Testes e interfaces no planejamento inicial** (Planner único) | Menos replans e `BLOCKED`; a passada RED separada some (1 sessão por PLAN) |
| 5 | **Disjuntor por modelo com probe** (`state.db`, aberto 10/30/120 min; meio-aberto = "responda só: ok"; compartilhado entre lanes e judge) | Poucos dólares, mas ~3 h de relógio de `infra_stuck`, 46 tentativas nemotron, 26 judges contra cota e 18 rodadas de cota |
| 6 | **Escada do executor por pass medido:** free saudável (glm 70%, deepseek-free 59%) e depois qwen (76%, US$ 0,05/pass); beam/iceman só com probe | Mantém ~US$ 0,05/TASK; evita o pass de 38% do beam |
| 7 | **Pré-checagem de cota do judge** (Codex fora até 25/11: ir direto ao luna) | 26 chamadas inúteis; judge ~US$ 0,02 por veredito |
| 8 | **Reduzir `scope_drift` e falhas de `edit`** (pyc/untracked; trecho exato no contexto da TASK) | ~45% das falhas do executor; ~US$ 0,3 e vários retrys |
| 9 | **Contexto do executor:** `Contexto` da TASK com faixas de linha (`gira read` / `sed -n`), sem `read` de arquivo >30 KB inteiro | 5–10% dos tokens do executor |

Riscos: o `paid-spend` atual não serve de fonte para teto (usar o DB). O custo do Pi acima é cota superior, porque o store mistura sessões do dono e de operadores.

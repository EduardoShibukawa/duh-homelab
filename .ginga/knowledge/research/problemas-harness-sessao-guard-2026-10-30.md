---
type: research
title: Problemas do harness achados na sessão do guard de segredos (PLAN-0033)
timestamp: 2026-10-30
status: draft
---

# Problemas do harness achados na sessão do guard de segredos

Legenda: **[verificado]** abri a fonte, o log ou o comando; **[inferência]** dedução minha, não verifiquei.
Escopo: análise somente leitura (nada editado fora deste arquivo; nenhum `pinga verify/prove-red`, lane, judge ou gate rodado). Janela medida: 2026-10-28 15:49 a 2026-10-30 10:11 (fim de `handoffs/lanes.events`). "Últimas 24 h" = 29/10 10:11 a 30/10 10:11.

## 0. Resumo (o que mudou em relação ao ponto de partida)

1. **O `scope_drift` do PLAN-0033 não é causado por `debug.js`/`debug2.py`.** É estrutural: o `pinga` mede o drift contra o commit `test(T145): RED`, e os RED das TASKs irmãs (T146..T150) foram commitados depois dele, então os arquivos delas entram no diff de T145 **em toda tentativa, com qualquer modelo**. Os arquivos de depuração são uma segunda camada (e ficariam como causa única só depois de corrigir a primeira). Detalhe e prova no P1.
2. **A main suja do `ginga/` veio de um operador que reimplementou o PLAN-0013 na main** entre 09:56 e 10:09 de hoje (rodada 4), e **não** do `prove-red` do PLAN-0033, ao contrário do que diz o backlog (`prompts/backlog-ginga.md:51`). Os `tasks/T145..T153` da main são TASKs ad hoc do PLAN-0013. Detalhe no P2.
3. **Todas as 13 tentativas de executor via Pi/NVIDIA de hoje (30/10) terminaram em `scope_drift`**, mas isso é efeito do P1, não evidência de que esses modelos são ruins. A escada de modelos está sendo julgada sobre um defeito do harness.
4. **A fila andou devagar por falta de slot de operador, não por ordem de prioridade**: desde 22:00 de ontem, 13 de 13 rodadas concluídas nas lanes ginga e manda citam só PLANs com achado do judge, mas o PLAN-0033 foi pego mesmo assim (dentro de uma rodada que o evento rotula como PLAN-0013), após 3 h 45 min de fila, dos quais ~2 h 10 min perdidos em timeout de lock e `infra_stuck`.

## 1. Tabelas por problema

### P1. `scope_drift` em TASK que já passa o `done_when`

| Campo | Conteúdo |
|---|---|
| Sintoma | T145 (PLAN-0033 TASK-01): 62/62 testes passam, `pinga verify` volta `blocked scope_drift`. 10 linhas de tentativa no `log.md` (iceman ×4, mistral-large ×4, muse-glimmer ×2) em dois despachos; contador do pinga chega a `attempts:13`. |
| Evidência (a causa estrutural) | [verificado] `p-inga/src/guards.ts:167-186` (`findRedBase` devolve o commit `test(<T>): RED`) e `guards.ts:189+` (`changedFiles` = `git diff --name-only <base>` + não rastreados). `verify.ts:~214` só usa `claimBaseline.head` se existir `.baseline.json` (vem de `pinga queue --claim`); `rg "claim\|--base" .ginga/bin/*.sh` não acha nada, então `dispatch-task.sh` **nunca** passa baseline nem `--base`. `git -C ginga-plan-0033 log`: `1564685 test(T145): RED` e depois `6820487 T146`, `cf0f0f9 T147`, `509c368 T148`, `92b41c7 T149`, `fb320a8 T150`, todos às 03:23:14. O resumo do receipt lista exatamente os arquivos dessas TASKs: `plans/PLAN-0033-guard-de-segredos/runs/TASK-01-core-e-lista-2.log` e `-6.log` (sem nenhum arquivo de depuração) trazem só `contrib/guard/hermes/test_guard.py, tasks/T146..T150/PLAN.md, tests/guard_{opencode,pi,run,sweep}.test.ts`. |
| Evidência (a camada de lixo) | [verificado] `debug.js` (mtime 04:04:36) e `debug2.py` (04:04:50) seguem não rastreados em `ginga-plan-0033`; `runs/TASK-01-core-e-lista-4.log` o executor diz "debug.js/debug2.py são sobras da tentativa anterior, não foram tocados por mim". O mtime 04:04 é preservado pelo `tar xf` do `restore`. `dispatch-task.sh:5` documenta "Rollback = snapshot da árvore INTEIRA ... preserva o trabalho de TASKs anteriores, não commitado": o snapshot **guarda o lixo** que já existia, e cada `restore` o devolve. `rg "trap " dispatch-task.sh` = vazio (sem restauração se o script morrer). [inferência] Os arquivos entraram no snapshot de um despacho posterior; a origem exata (tentativa de executor ou o próprio operador depurando entre despachos) não é recuperável porque `runs/TASK-01-...-N.log` é sobrescrito a cada despacho (`n` zera, `LOG=$PD/runs/$TN-$n.log`; 7 arquivos para 10+ tentativas, mtimes misturados 04:03 a 04:51). |
| Causa-raiz | **Defeito do harness** (base do diff em `dispatch-task.sh` + snapshot que preserva lixo). Secundária: **planejamento** (TASK com `touch` incompleto, ver B). |
| Frequência medida | [verificado] `plans/*/log.md`: 154 tentativas falhas, **50 `scope_drift` (32 %)**, em 5 PLANs: 0013 = 24, 0006 = 12, 0033 = 10, 0011 = 2, 0015 = 2. Dos **43 receipts `scope_drift` retidos em `runs/`** (os outros foram sobrescritos): A) arquivos de TASK irmã (`tasks/T<n>/PLAN.md` ou RED irmão) = **17** (PLAN-0013: 11 em T140/T146 etc.; PLAN-0033: 5; PLAN-0032: 1); B) `touch` incompleto = **18** (PLAN-0006: 8 em `bin/ginga.ts` e adapters; PLAN-0013: 8, todos `src/verbs/registry.ts` na TASK-06/T147; PLAN-0011: 1; PLAN-0032: 1); C) `__pycache__` = **8** (PLAN-0013: 5, PLAN-0015: 3; mitigado por `PYTHONDONTWRITEBYTECODE` e `.gitignore`); D) arquivo de depuração como causa única = **0** (em 3 dos 5 receipts do PLAN-0033 os arquivos de depuração aparecem, sempre junto com A). A causa A afeta toda TASK cuja RED não é a última commitada do PLAN. O mesmo defeito aparece no manda: `handoffs/REPORT-2026-10-28.d/operador-plan-0028.md` ("scope_drift para T156/T159 devido a alterações fora do touch em commits anteriores") e o `log.md` do PLAN-0028 ("T159 relacrado pass, `verify --base 397389c`"). |
| Custo | PLAN-0033 TASK-01: ~1 h 30 min de executor (runs 03:23 a 04:51) e 10 tentativas sem chance de passar. PLAN-0013 TASK-05+06: 13 tentativas, 06:49 a 08:47 (~2 h; 2 a 16 min por tentativa pelos mtimes de `runs/`). Todas as 13 tentativas Pi/NVIDIA de hoje (mistral-large 7, muse 4, nemotron-lightning 2) falharam por isso. Cota de provider queimada e, principalmente, hora do slot único de operador. Contorno manual já existe e é repetido: `pinga verify --base <sha>` (PLAN-0009 log: "sem --base, base RED antiga acusava scope_drift"; PLAN-0028 T157/T159). |
| Gravidade | **Crítica**: bloqueia o merge do guard (TASK-01 é a raiz da cadeia 01→02→03/04/05/08) e do PLAN-0013. |

Resposta à pergunta "o harness deveria limpar/ignorar untracked fora do `touch`?": **ignorar não** (esconderia edição fora de escopo real, que é o propósito do guard). O correto é (a) medir o drift contra o **estado no início do despacho**, não contra o commit RED antigo; (b) fazer um **pré-voo** antes de chamar o modelo: se já há drift no snapshot, **mover** (não apagar) os arquivos para quarentena e registrar, em vez de gastar tentativas e devolver ao executor uma lista que ele não consegue consertar; (c) dar `trap` de restauração no `dispatch-task.sh`.

### P2. Main suja do `ginga/` bloqueia todo merge

| Campo | Conteúdo |
|---|---|
| Sintoma | `merge-gate.sh:28` (`git status --porcelain --untracked-files=no` não vazio) saiu com exit 2 no PLAN-0013 r4 às 10:11 (`plans/PLAN-0013-handoff-e-learnings/log.md` última linha). |
| Cronologia [verificado, mtimes de `ginga/` e `lanes.events`] | 09:33:13 prompt da rodada 4 gerado (`prompts/lane-ginga-20261030-0933-r4.md`, 23.880 B) com 11 "achados" do judge do PLAN-0013 (TASK-05..15 "sem código") · 09:32 a rodada 3 tinha reportado "Main repo: Limpo" · **09:56:10** `tasks/T145` · 10:01:16 `src/lessons.ts` · 10:01:29 `src/verbs/learning.ts` · 10:01:37 T146 · 10:02:17 T147 · 10:02:36 T148 · 10:03:19 `src/handoff/policy.ts` · 10:03:49 `src/handoff.ts` · 10:04:13 T149 · 10:04:29 T150 · 10:04:45 T151 · 10:04:58 T152 · 10:05:18 T153 · **10:08:28** `src/verbs/registry.ts` e `tests/cli_verbs.test.ts` (mesmo nanossegundo: um único comando, tipo `cp`/`patch`) · 10:09:18 `decisoes.md` · 10:10:22 fim do log · 10:11 gate exit 2. |
| Quem | O operador LLM da lane ginga, rodada 4 (09:33 a 10:10). [inferência] modelo `pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b`: o `infra_stuck` das 09:02 avançou `mi` e o índice vive no processo da lane (`lane.sh:8`, `mi` fora do `for`), sem relançamento entre r3 e r4. **Nenhum log registra o modelo da rodada** (ver N1). |
| Por quê | [verificado] (i) o prompt lista as TASKs 05..15 como achados do judge; o operador ignorou o despacho (`dispatch-task.sh`) e escreveu o código direto: `decisoes.md` diz "Implementou TASK-05 a TASK-15 no repo ginga"; (ii) `lane.sh` roda o operador com `cd $DUH`, onde `ginga/` (main) e `ginga-plan-0013/` são irmãos: o caminho relativo certo e o errado diferem por 5 caracteres; (iii) a regra "Nunca edite no diretório principal" existe só em prompt (`prompts/op-base.md:17`); (iv) a única trava determinística, `lane.sh` `main0=$(rev-parse main)`, compara o **SHA do ref**, não a árvore de trabalho; arquivos soltos passam. [inferência] os hooks git da main bloquearam o commit, por isso o trabalho ficou solto. |
| Correção de fato do backlog | [verificado] `prompts/backlog-ginga.md:51` diz que `tasks/T145..T148` são "pastas do PLAN-0033 que o `prove-red` criou na main". **Não são**: `ginga/tasks/T145..T153` (nove pastas) têm goals do PLAN-0013 ("Fix learning promote regression", "Implement lessons find", "...lessons import", "...handoff policy/session/hook/--open", "...skill handoff", "...adapter Claude"). São uma recriação paralela das TASKs que já existem na `plan/0013` (T145..T154, commits de 06:41). `diff ginga/src/lessons.ts ginga-plan-0013/src/lessons.ts` difere: há **duas implementações divergentes** de `lessons.ts`. |
| Causa-raiz | **Defeito do harness** (ausência de trava determinística) + **modelo fraco** (ignorou regra de prompt). |
| Frequência | 1 vez com este sintoma (gate 2). Reincidência do tipo "main mudou durante o operador" (`CRÍTICO`, exit 20): 3 em `lanes.events` (manda 28/10 22:50, manda 29/10 08:59, p-inga 29/10 09:11). Total: 4 incidentes de main alterada fora do gate em 3 dias. |
| Custo | Todos os merges do ginga parados (PLAN-0013, 0033, 0012, 0016, 0014) até alguém arquivar e restaurar; o item "PRIORIDADE ZERO" do backlog já foi aberto às ~10:20. |
| Gravidade | **Crítica** (bloqueia o repo inteiro), mas o reparo é mecânico. |

Sim, falta uma trava determinística. Proposta no E2.

### P3. `pinga prove-red` devolve "not run" quando o módulo ainda não existe

| Campo | Conteúdo |
|---|---|
| Sintoma | PLAN-0033: T145..T148 e T150 saem `not run` (inconclusivo); só T149 (asserção) prova RED. `plans/PLAN-0033-guard-de-segredos/log.md` linha "06:2x operador ...". |
| Evidência | [verificado] `p-inga/src/prove.ts:132-166`: `RESOLUTION_FAILURE` (`Cannot find module`, `Module not found`, `TS2307`...) sem `ASSERTION_FAILURE` ⇒ `classifyBaseRun` devolve `"inconclusive"`; `prove.ts:~526-531` converte em `status:"not run"`, `reason_code:"infra"`, texto "prova inconclusiva ... (RED por erro de import/compilação, não por asserção)". |
| Causa-raiz | **Defeito de desenho** do pinga: a regra "import quebrado não é RED" protege contra RED preguiçoso, mas quase toda TASK do tipo "criar `src/x.ts`" tem exatamente esse RED legítimo. O `touch` da TASK já declara o módulo que será criado. |
| Frequência | [verificado] "prova inconclusiva / not run / inconclusive" aparece em ≥ 10 arquivos: `PLAN-0006`, `0015`, `0018` (2×), `0033` e 5 relatórios de operador/lane (`lane-p-inga-...0819-r2.md:34` registra "RED fraco aceito"). Em PLAN-0033: 5 de 6 TASKs. |
| Custo | Sem tentativa gasta, mas a RED "não provada" fica sem receipt de prova no ledger e depende de um operador LLM aceitar à mão ("RED esperado segundo o backlog"). Isso é uma decisão sem regra do harness registrada só em texto livre. Risco: erro de digitação no caminho do import vira "RED" aceito. |
| Gravidade | **Média** (não bloqueia merge; enfraquece a auditoria e gera decisão manual recorrente). |

### P4. Colisão de ids de TASK do pinga entre branches

| Campo | Conteúdo |
|---|---|
| Sintoma | Hoje o mesmo intervalo foi alocado **três vezes**: `plan/0033` T145..T150 (commits 03:23:14), `plan/0013` T145..T154 (commits 06:41:36-37) e a main suja T145..T153 (criada à mão 09:56 a 10:05). O backlog diz T146/T153/T154 do 0013; na verdade o 0013 usa T145..T154 inteiro. |
| Evidência | [verificado] `git log` das duas worktrees; `plans/PLAN-0033-guard-de-segredos/TASK-01-core-e-lista.md:8` `pinga_task: T145` (o Planner fixou o id ao escrever o PLAN, a partir da fila da main, e o operador do 0013 pegou os mesmos números depois, vendo só a própria branch). `manda-plan-0028/src/alloc.ts` (`allocTaskIds(taken, count)`) é puro: aloca `max(taken)+1` sobre a lista que o chamador entrega, e a lista vem do `pinga queue` local; o judge do PLAN-0028 já apontou "taken ... não tasks/T*/ do repo". Ou seja, mesmo mergeado, não resolve entre branches. |
| Causa-raiz | **Defeito do harness**: não existe alocador central; cada autor (Planner, operador, `manda red`) vê só a sua árvore. |
| Frequência | [verificado] 4 colisões em 4 dias: T58 (pi-harness 0007/0004, 27/10, "renumerado para T59, selado de novo"), T35 (`p-inga-governed-roles`, 28/10, `pi-operador2-2026-10-28.log`), T13..T18 (PLAN-0010 × 0006 no ginga, 28/10, `backlog-ginga.md:1`), T145..T150 (hoje). Cerca de 1 por dia. |
| Custo | Renumeração por operador LLM + re-selagem de receipts + conflito add/add em `tasks/T14x/` no segundo merge. Hoje já custa uma entrada de backlog e vai custar uma rodada no merge do segundo PLAN. |
| Gravidade | **Alta** (certa de ocorrer no próximo merge de 0013 ou 0033). |

### P5. Lane "sem progresso" e item novo do backlog que demora

| Campo | Conteúdo |
|---|---|
| Sintoma | `lanes.events` 10:11: "[ginga] rodada 4: PLAN-0013: gate 2; rodada 4 sem progresso (nada mudou). Lane parada." |
| O que é verdade | [verificado] Desde 29/10 22:00 (12 h), **ginga: 6 rodadas concluídas** (02:07, 04:49, 07:06, 09:03, 09:33, 10:11), todas com o resumo citando só `PLAN-0013` (gate 11 em 5, gate 2 em 1); **manda: 7** (01:09, 01:50, 02:49, 05:44, 07:35, 09:19, 09:54), todas com `PLAN-0028` (gate 11) e, até 05:44, `PLAN-0032` (gate 11, depois gate 0). Nessa janela: 0 merges no ginga, 1 no manda (PLAN-0032, 05:44). Antes disso, no dia 29, o ginga mergeou PLAN-0011 (13:58), PLAN-0015 (16:43) e a parte ginga do PLAN-0028 (20:47, `git -C ginga log`). |
| O que o dado **não** sustenta | A hipótese "achados do judge primeiro + máx. 2 itens deixam o backlog sem ser pego" **não se confirma**: o PLAN-0033 entrou no backlog às 23:33 (primeiro `prompts/lane-ginga-20261029-2333-r2.md` que o cita), a worktree `ginga-plan-0033` nasceu **03:18:27** e os RED foram commitados 03:23, dentro da rodada 02:40 a 04:49, cujo evento final diz só "PLAN-0013 gate 11". O operador trabalhou no item novo; o evento não mostra (o resumo só enumera PLANs com `ready/<repo>.json`, `lane.sh` linha `sum+=`). A "regra de ordem" é só prompt, o modelo escolhe. |
| Espera medida (PLAN-0033) | **3 h 45 min** (23:33 a 03:18) até existir worktree; **~4 h** até o primeiro despacho. Nesse intervalo o ginga teve 6 janelas de operador: 3 perdidas em timeout de lock (23:33 a 00:03, 00:10 a 00:40, 02:07 a 02:37), 1 em `infra_stuck` (00:50 a 01:30), 1 concluída com PLAN-0013 (01:30 a 02:07) e 1 que pegou o PLAN-0033 (02:40 a 04:49). 130 min (~2 h 10) de lock e stuck. |
| Problema real de progresso | [verificado] `lane.sh` `state()` só enxerga (1) `ready/<repo>.json`, (2) SHA das branches dos `ready`, (3) worktrees citadas em linhas que casam `^- worktree: *`, (4) md5 do backlog. A linha do PLAN-0033 diz "Worktree `ginga-plan-0033`" (sem o prefixo `- worktree:`), logo commits e arquivos nela **não contam como progresso**. No 10:11 o "sem progresso" foi correto por acaso: o trabalho do operador estava na main, fora do `state()`. |
| Causa-raiz | Mistura: **configuração** (formato do backlog que o `state()` entende) + **defeito do harness** (telemetria cega, ver N1/N2) + **modelo fraco** (ignora a ordem do prompt). |
| Gravidade | **Média**. |

### P6. Operador free instável (tabulação por modelo)

| Campo | Conteúdo |
|---|---|
| Sintoma | `infra_stuck` (900 s sem progresso, operador morto), "operador ocupado há 30 min por outra lane" (`flock -w 1800 .op.lock`), 429. |
| Operador [verificado, `lanes.events`, datas inferidas pela virada de hora] | **Hoje: `infra_stuck` ×6** (ginga 01:30, 07:03, 09:02; manda 01:50, 07:34, 09:19): `pi:nvidia/mistralai/mistral-large-4-1t` ×5 (próximo = muse) e `muse-glimmer-30b` ×1 (próximo = nemotron-lightning). Nunca passou de nemotron. **Timeout de lock ×13** (29/10 22:30 a 30/10 08:40: manda 9, ginga 4), 30 min cada = **390 min de lane parada**. 29/10: 19× "429/rate limit em pi:nvidia/minimax-m3.1-flash" (ginga 8, manda 7, p-inga 4), "sem cota" glm-free ×8, go-deepseek ×8, go-qwen ×4. Vigia relançou lanes **9× (28/10), 69× (29/10), 11× (30/10)**. |
| Taxa de pass do operador por modelo | **Não medível**: nenhum log registra o modelo por rodada, e os eventos de `infra_stuck` só dizem o "próximo". Só dá para dizer que a escada nunca ficou no `mistral-large` (5 stuck) e que todas as rodadas que fecharam hoje vieram depois de uma troca para `muse`/`nemotron` [inferência]. |
| Executor por modelo (todo o histórico, 262 tentativas parseáveis de `plans/*/log.md`) | `opencode/qwen3.8-flash` (Zen pago) n=49, pass 37 (76 %) · `opencode/glm-5.3-flash-free` n=54, 36 (67 %) · `opencode/deepseek-v4.1-flash-free` n=31, 17 (55 %) · `opencode-go/iceman-contributor-free` n=32, 14 (44 %; 10 scope_drift) · `opencode-go/beam-free` n=8, 3 · `opencode/deepseek-v4-pro` n=7, 2 · `opencode/nemotron-3-ultra-free` n=46, **0** (46 `command_failed`, já fora da escada) · `opencode-go/{deepseek-v4.1-flash,qwen3.8-flash}` n=8+8, 0 (`tests_frozen_changed`/`scope_drift`) · `pi:nvidia/mistral-large-4-1t` n=7, **0** · `pi:nvidia/muse-glimmer-30b` n=4, **0** · `pi:nvidia/nemotron-3.5-lightning` n=2, **0**. As 13 tentativas Pi/NVIDIA falharam **todas por `scope_drift` do P1**: não dizem nada sobre capacidade. |
| Executor, últimas ~30 h (29 e 30/10) | qwen3.8-flash n=47, **pass 35**; iceman n=28, pass 14 (scope_drift 8; hoje 8 de 19, todos TASK-16/17 do 0013 e correções de uma tentativa); pi/NVIDIA 13, pass 0. Gasto pago registrado no dia 29: 13 tentativas qwen, US$ 0,20 (`paid-spend-2026-10-29.tsv`); `ALLOW_PAID=0` em `lane.env` agora. |
| Tempo médio por tentativa | Não há hora no `log.md` (só data). Pelos mtimes de `runs/`, 2 a 16 min por tentativa Pi/NVIDIA (amostra: PLAN-0013 TASK-06, 8 tentativas). Rodada de operador com mistral: 05:20 a 07:03 (1 h 43). |
| Quem entrega | **Executor:** qwen3.8-flash (pago, centavos) e glm-5.3-flash-free quando há cota; iceman é o único free que passa hoje (14/28), mas metade das falhas dele é P1/B. **Operador:** nenhum modelo da escada Pi/NVIDIA entregou uma rodada limpa; as rodadas que fecharam vieram do muse/nemotron e uma delas gravou na main (P2). A conclusão firme exige corrigir P1 e registrar o modelo por rodada primeiro. |
| Causa-raiz | **Configuração** (um único slot `.op.lock` global para N lanes; ladder sem memória) + **modelo fraco/provedor** (RPM baixo da NVIDIA free) + **defeito do harness** (`mi=0` ao relançar). |
| Gravidade | **Alta** (é o gargalo de vazão de toda a fila). |

### P7. Desenho do guard (pesquisa §2)

| Campo | Conteúdo |
|---|---|
| Plugin Hermes não bloqueia | [verificado] `~/.hermes/plugins/pinga-harness/*.py:95-111` declara `pre_tool_guard(...) -> Optional[str]` e devolve `str` (`:106`). O núcleo (`hermes_cli/plugins.py:1963-1965`) faz `for result in hook_results: if not isinstance(result, dict): continue`: `str` é descartado, nada bloqueia; o diretório `~/.hermes/profiles/pinga/plugins/pinga-harness` é uma cópia que **não li**. Só um `dict` com `action:"block"` e `message` não vazia bloqueia (`:1969-1981`). |
| Sandbox só do `done_when` | [verificado] `rg sandbox-run .ginga` fora de `knowledge/handoffs`: **nenhum script chama `sandbox-run.sh`** (só ele mesmo); `dispatch-task.sh` exporta `PINGA_EXEC_WRAPPER=sandbox-done-when.sh` (isola o `done_when`). Executores (`opencode run`, `pi -p`) e o operador (`lane.sh`) rodam **sem** bwrap, com acesso ao `~`. |
| opencode 2.2.2 | [verificado] `opencode --version` = `v2.2.2`; a pesquisa (§2/§3) registra o nome de tool `shell` nos `runs/` reais. Não reabri o plugin. |
| Gravidade | **Alta para o objetivo do PLAN-0033** (o guard seria "ligado" mas inerte no Hermes), **baixa para o merge**: já documentado e mapeado para TASK-05/TASK-06. Corrigir o plugin é a TASK-05. |

### P8. Armadilhas de processo da sessão

| # | Armadilha | Estado | Evidência | Como fica |
|---|---|---|---|---|
| a | Teste de bloqueio passa por engano porque a falha fechada também "bloqueia" | [verificado só como relato] `PLAN.md:21` e pesquisa §8 definem falha fechada | Teste de bloqueio deve afirmar a **regra** (`rule`/`reason`), não só `block:true` | TASK-01 já tem 62 casos com `rule`; incluir no `executor.md` e no `planner-red.md` a regra "afirme o motivo" |
| b | Editar `lane.sh` com a lane rodando corrompe o bash (o bash lê o script incrementalmente) | [verificado] mecanismo conhecido; o PLAN-0033 manda "troca atômica com `mv`" | `plans/PLAN-0033-guard-de-segredos/log.md` linha final | Script `bin/atomic-replace.sh` que valida com `bash -n` e faz `mv`; recusar edição direta de `bin/lane.sh` quando há `ginga-lane-*` ativa |
| c | `done_when` roda com `--clearenv` e perde `PYTHONDONTWRITEBYTECODE` | [verificado] `sandbox-done-when.sh:25-28` só repassa `PINGA_LEDGER GINGA_EVENTS CI` | `dispatch-task.sh:15` exporta a variável, mas a sandbox a descarta | Passar `PYTHONDONTWRITEBYTECODE=1` em `sandbox-done-when.sh:28` (a lista de variáveis); remover o remendo `python3 -B` dos `done_when` |
| d | Guard ligado por padrão + arquivo ausente = lane não inicia (ordem da TASK-06) | [verificado] `TASK-06-fiacao-das-lanes.md:16` (`guard_require || exit 6`); `log.md` do PLAN: "antes do merge a lane recusaria iniciar" | Ordem fixa merge → 06 → Fase 2 → Hermes | `guard-env.sh` nasce com `GINGA_GUARD=shadow` por padrão e `guard_require` só falha se `GINGA_GUARD=enforce` |

## 2. Problemas novos

| # | Problema | Evidência | Causa-raiz | Frequência / custo | Gravidade |
|---|---|---|---|---|---|
| N1 | **Telemetria insuficiente.** `lanes.events` só tem `[HH:MM]` (sem data), não registra o modelo da rodada, e o resumo só lista PLANs com `ready/`. `log.md` tem só data nas linhas de tentativa. `runs/<TASK>-<n>.log` é **sobrescrito** a cada despacho. Linhas escritas por LLM trazem hora chutada ("06:2x" no `log.md` do PLAN-0033; a worktree nasceu 03:18). | `bin/notify.sh` → `lanes.events:1-10`; `dispatch-task.sh` `LOG=$PD/runs/$TN-$n.log`; birth time de `ginga-plan-0033` = 03:18:27 | Defeito do harness | Tive de reconstruir as datas pela virada de hora (3 dias em 606 linhas) e não consegui tabular operador por modelo nem latência. | **Alta** (bloqueia medir qualquer correção) |
| N2 | **`ladder` sem memória.** `mi` vive no processo; ao relançar (vigia, exit 3/5), volta ao 1º degrau (mistral), que acabou de travar. | `lane.sh:8`; 89 relançamentos em 3 dias | Defeito do harness | Mistral travou 5× hoje, cada vez 15 min de slot. | Alta |
| N3 | **Slot único de operador (`flock -w 1800 .op.lock`) mais lock de 30 min** serializa 3 a 4 lanes; quem espera morre com exit 5 e só volta no próximo tick de 10 min do vigia. | `lane.sh:31`; 13 timeouts / 390 min em ~10 h | Configuração | Vazão efetiva ≈ 1 rodada de operador por ~35 min para o workspace inteiro [inferência: duração das rodadas 30 a 37 min em `lanes.events`]. | Alta |
| N4 | **Judge parcial vira "achado" e pressiona o operador a fazer tudo de uma vez.** O judge avalia o PLAN inteiro; TASKs ainda não despachadas voltam como `ok:false` e `lane.sh` as injeta no prompt como "achados". A rodada 4 recebeu 11 itens e reimplementou 11 TASKs de uma vez, contra a regra "máx. 2 itens". | `prompts/lane-ginga-20261030-0933-r4.md` (seção PLAN-0013); `judge-run.sh` prompt ("um item por AC/TASK com repo") | Defeito do harness | 12 rodadas com gate 11 desde 29/10 22:00 (ginga 5, manda 7); cada `fail` tem texto genérico e o operador tenta cobrir tudo. | Alta |
| N5 | **Loop do vigia sem backoff.** No dia 29: p-inga 26 rodadas seguidas "PLAN-0009 judge falhou / sem progresso" de 09:17 a 13:11 e ginga ~20 rodadas "nenhum ready" de 10:21 a 13:12 (relançadas a cada 10 min, 69 relançamentos no dia), até o fallback do judge (`Codex sem cota, fallback opencode/gpt-6-luna`, 13:31). Causa do `judge falhou` não ficou no evento. | `lanes.events` (dia 29); `plans/PLAN-0009.../log.md` | Defeito do harness | ~4 h de lane girando, cada ciclo com operador (Claude, na época). Não medi o gasto. | Média |
| N6 | **`decisoes.md` não é append-only de fato.** Birth 29/10 22:15 mas os relatórios de 29/10 manhã citam linhas ali ("4 linhas novas"); hoje tem 3 linhas, com a coluna Operador vazia, e foi reescrito às 10:09. | `stat decisoes.md`; `lane-p-inga-20261029-0819-r2.md:34` | Processo (regra só em prompt) | Histórico de decisões perdido. [inferência] sem backup. | Média |
| N7 | **Relatório de LLM contradiz o fato.** O operador da r4 escreveu "T146-T153 verify passam"; o gate, a main e o judge dizem outra coisa; a r3 reportou "Main limpo" corretamente às 09:32, mas sem checagem determinística. | `decisoes.md`; `lane-ginga-20261030-0903-r3.log` | Processo (já coberto pela memória "merge só por gate") | O Claude/dono não deve usar relatório como fonte. | Baixa |
| N8 | **Executor devolve 4–8 tentativas curtas (600–2.100 B) ao mesmo erro que não consegue consertar.** Sem detecção de "mesma falha, mesmo arquivo": o `breaker_same_failure` do pinga só dispara em parte (1 ocorrência). | `PLAN-0013/runs/TASK-06-lessons-find-3..9.log`; contagem `breaker_same_failure=1` | Defeito do harness | 9 tentativas na T147, 13 na T145. | Média |
| N9 | **Executor zerou o `opencode.db` real (30/10 15:09:22).** O `iceman` da PLAN-0028 TASK-13 escreveu `debug_fix2.ts` com `process.env.HOME = "/tmp/testhome5"` e depois `join(homedir(), ".local/share/opencode/opencode.db")`; no Bun `homedir()` não acompanha a troca de `process.env.HOME` (testei: devolve o HOME do início), então `writeFileSync(dbPath, "")` truncou o banco real para 0 bytes. Desde então todo `opencode run` falha com `Standalone server exited before reporting readiness` / `SQLiteError: database is locked` (o `opencode serve --service`, pid 345865, segura o inode zerado). Histórico de sessões e custos do opencode perdido (sem backup achado). Os executores e o operador rodam sem bwrap e com o `~` real (confirma P7). | `~/.local/share/opencode/log/opencode.log` linhas 150098 a 150135; `ls -la ~/.local/share/opencode/opencode.db` = 0 B às 15:09; `plans/PLAN-0028.../runs/TASK-13-guarda-do-planner-na-cli-2.log` | Defeito do harness (executor sem sandbox, HOME real) | 1 vez; derrubou iceman, glm-free e todo opencode por 1 h 30+ (dispatch gastava tentativas no erro). | **Crítica** |

## 3. Propostas (esboços INTENT → SPEC → PLAN → TASK)

Todas passam por TASK + RED + `manda run` + `pinga verify` + judge, como a regra do dono. O root não é repositório git, então as TASKs que tocam `.ginga/bin/` rodam sem ledger do pinga (convenção de transição do `CLAUDE.md`), com `done_when` em shell e teste em dir temporário.

### E1 (P1, N8): o drift se mede a partir do início do despacho
- **INTENT:** `scope_drift` só acusa o que a **tentativa** mudou; lixo e RED irmão não contam, e lixo preexistente é posto em quarentena antes de gastar tentativa.
- **SPEC (ACs):** (1) com 2 RED commitados em sequência, a TASK do 1º RED passa quando a mudança está no `touch`; (2) arquivo não rastreado preexistente fora do `touch` vai para `.ginga/_quarantine/<plan>/<ts>/` com MANIFEST e o despacho segue; (3) após `kill -TERM` a árvore volta ao snapshot; (4) mesma lista de arquivos de drift em 2 tentativas seguidas ⇒ para com `reason: drift_nao_corrigivel` e chama o operador, sem queimar a escada.
- **PLAN:** 1 TASK no `dispatch-task.sh` (shell) e 1 TASK opcional em `p-inga` (`verify` usa o baseline do início do despacho por padrão).
- **TASK-01** `touch: .ginga/bin/dispatch-task.sh, .ginga/bin/tests/dispatch_scope.sh` · antes de snapshot: `pinga queue --claim` ou `HEAD0=$(git rev-parse HEAD)`; `pinga verify ... --base "$HEAD0"`; pré-voo: `git status --porcelain --untracked-files=all` menos o `touch` ⇒ quarentena; `trap restore EXIT TERM`; `runs/$TN-$(date +%s)-$n.log`. `done_when: bash .ginga/bin/tests/dispatch_scope.sh` (repo temporário com 2 commits `test(T1): RED`/`test(T2): RED`, executor falso).
- **TASK-02 (p-inga, opcional)** `touch: src/verify.ts, tests/verify_baseline_default.test.ts` · `done_when: bun test tests/verify_baseline_default.test.ts`.
- Ação imediata sem esperar o PLAN (já coberta pelo backlog): `git clean` só de `debug.js` e `debug2.py` na `ginga-plan-0033` **e** `pinga verify ... --base fb320a8` na T145. **Sem `--base` o drift volta.**

### E2 (P2, N7): trava determinística contra edição na main
- **INTENT:** operador não consegue deixar a main suja, e se deixar, o harness arquiva e restaura sozinho.
- **SPEC:** (1) `lane.sh` compara `git status --porcelain` da main antes/depois do operador, não só o SHA; (2) diferença ⇒ arquiva diff e não rastreados em `.ginga/_archive/<data>-main-suja-<repo>/` com MANIFEST, restaura a main, registra em `decisoes.md` e em `lanes.events` e **não roda o judge** (poupa o veredito pago); (3) o guarda de escopo do Pi/opencode (PLAN-0032/0033) nega `write|edit|apply_patch|bash >` com caminho dentro de `$DUH/<repo>/` quando `GINGA_GUARD_LANE` está setado e o caminho não está em `$DUH/<repo>-plan-*`; (4) o operador roda com cwd em `$DUH/.ginga/ws/` (só symlinks para as worktrees), então `ginga/` não aparece por caminho relativo.
- **TASK-01** `touch: .ginga/bin/lane.sh (troca atômica), .ginga/bin/guard-main.sh, .ginga/bin/tests/guard_main.sh` · `done_when: bash .ginga/bin/tests/guard_main.sh` (repo temporário; "operador" falso escreve na main; esperado: arquivado, main limpa, exit ≠ 0 registrado, judge não chamado).
- **TASK-02** (depende do PLAN-0033 TASK-01/02) adiciona `deny_write_main` em `src/guard/deny.json` do ginga e caso em `tests/guard_core.test.ts`.
- Reparo imediato: o item PRIORIDADE ZERO do backlog; ajustar o texto "pastas do PLAN-0033" (ver P2) para não apagar nada do PLAN-0033 por engano.

### E3 (P6, N2, N3, N5): operador com memória e sem fila de 30 min
- **INTENT:** o gargalo de vazão vira medido e o degrau que trava não é repetido.
- **SPEC:** (1) escada persistida em `handoffs/.op-ladder.tsv` (`modelo, ts_último_stuck, falhas_seguidas`); modelo com stuck nas últimas 3 h é pulado; (2) lock com `flock -w 120` e **prioridade**: lane com item `PRIORIDADE` leva o slot, as outras dormem por backoff exponencial no próprio `lane.sh` (sem exit 5 e sem esperar o vigia); (3) vigia com backoff quando o hash do estado não muda em 3 relançamentos; (4) o evento de rodada passa a registrar `modelo=` e `dur=`.
- **TASK-01** `touch: .ginga/bin/lane.sh, .ginga/bin/vigia.sh, .ginga/bin/notify.sh, .ginga/bin/tests/lane_ladder.sh` · `done_when: bash .ginga/bin/tests/lane_ladder.sh` (operador falso que trava; duas lanes disputando o lock).
- Decisão rápida sem o dono (dentro do ROUTING): tirar `pi:nvidia/mistral-large-4-1t` do 1º degrau do `OP_MODELS` (stuck 5/5).

### E4 (P4): alocador de ids que enxerga todas as branches
- **INTENT:** nenhuma colisão de `pinga_task` entre PLANs, Planner e operador.
- **SPEC:** `ginga alloc tasks --repo R --count K` devolve K ids maiores que o máximo de: `tasks/T*` de **todas** as branches locais (`git for-each-ref refs/heads` + `git ls-tree`), de todas as worktrees, de `pinga_task:` em `plans/*/TASK-*.md` com `repo: R`, e da fila do pinga; reserva com `flock` em `.ginga/state/alloc.lock` e linha em `state.db`. `manda red` e o `planner-red.md` passam a usá-lo.
- **TASK-01 (ginga)** `touch: src/alloc.ts, src/cli.ts, tests/alloc_cross_branch.test.ts` · `done_when: bun test tests/alloc_cross_branch.test.ts` (duas branches com T145..; o 3º pedido devolve T155+).
- **TASK-02 (manda)** `touch: src/red.ts, tests/red_alloc.test.ts`. Hoje, antes de mergear 0013 ou 0033, renumerar a segunda branch com esse alocador.

### E5 (P3): `prove-red` aceita módulo ausente que a TASK vai criar
- **INTENT:** RED legítimo de módulo novo vira `proved`, com a razão registrada.
- **SPEC:** se o `done_when` falha só com `Cannot find module <path>` e `<path>` resolvido casa com um item do `touch` que não existe no base, o veredito é `proved` com `detail: "RED por módulo novo do touch"`; qualquer outro import quebrado continua `inconclusive`.
- **TASK-01 (p-inga)** `touch: src/prove.ts, tests/prove_red_new_module.test.ts` · `done_when: bun test tests/prove_red_new_module.test.ts`.

### E6 (N1, N4, N6, P8-c): observabilidade e juiz parcial
- **SPEC:** `notify.sh` grava ISO com data; resumo da rodada lista **todos** os PLANs/worktrees tocados (por `git status`/HEAD, não por `ready/`); `state()` olha todas as `$R-plan-*`; `judge-run.sh` marca TASK sem receipt `done` como `pending` (não `ok:false`) e o prompt da lane lista só os `fail` de código existente; `decisoes.md` vira `decisoes.d/<ts>-<lane>.md` (um arquivo por decisão); `sandbox-done-when.sh` repassa `PYTHONDONTWRITEBYTECODE`.
- **TASK-01** `touch: .ginga/bin/{notify,lane,judge-run,sandbox-done-when}.sh, .ginga/bin/tests/telemetria.sh` · `done_when: bash .ginga/bin/tests/telemetria.sh`.

## 4. Ranking (o que mais atrasa o merge do guard e dos PLANs na fila)

1. **E1 (P1)** — sem isso TASK-01..05 e 08 do guard ficam presas (T145 é a raiz da cadeia) e o PLAN-0013/0028 continuam queimando 9 a 13 tentativas por TASK. Barato (um script) e libera tudo.
2. **E2 (P2)** — zera o bloqueio atual do ginga e impede a reincidência (4 incidentes em 2 dias).
3. **E3 (P6/N2/N3)** — a vazão do workspace é 1 rodada de operador por ~35 min; 390 min de lanes paradas em ~10 h. Sem isso, mesmo corrigido P1, a fila de ~35 TASKs demora dias.
4. **E4 (P4)** — vai travar o segundo merge entre 0013 e 0033 e ocorre ~1 vez por dia.
5. **E6 (N1/N4)** — telemetria e juiz parcial; sem dado de modelo por rodada não dá para provar que E3 funcionou, e o N4 empurra o operador a reimplementar o PLAN inteiro.

**Incidente N9 (opencode.db zerado)** entra antes de tudo enquanto não for reparado: parar o `opencode serve --service`, mover o `.db`/`-shm` zerados e deixar o opencode recriar; e o remédio estrutural é rodar o executor com `HOME` falso (bwrap, `sandbox-run.sh` já existe e não está ligado) e negar escrita em `~/.local/share/opencode` no guard do PLAN-0033.

Fora do top 5: E5 (P3, média, não bloqueia merge) e a ativação do plugin Hermes (P7, já no PLAN-0033 TASK-05/06).

## 5. O que depende do dono e o que o harness decide

**Dono (dinheiro, dados a terceiros, ações reservadas):**
- Liberar operador ou executor **pago** para furar o gargalo do P6 (`ALLOW_PAID=0`, `TOTAL_CAP=0`; o qwen3.8-flash passou 35 de 47 em ~US$ 0,20 no registro de 29/10). É dinheiro; não mudo.
- Nada nas propostas envia dado a terceiro além do que já foi aprovado ("Workspace vai ser open source", "OpenRouter privacidade ligada").
- A **Fase 2 com `.env` falso** e a **ativação do plugin Hermes** já têm o OK do dono ("faz tudo", 29/10); a ordem merge → 06 → Fase 2 → Hermes continua.

**O harness decide (coberto pela visão/regras):** E1, E2, E3 (reordenar escada free), E4, E5, E6 e o reparo imediato da main suja; renumerar ids de TASK; mover lixo para quarentena (nunca apagar); trocar o degrau inicial do `OP_MODELS` dentro da escada free já liberada.

## 6. Limites desta análise

- Datas de `lanes.events` foram inferidas pela queda de hora (dias 28, 29, 30); conferi com os nomes dos logs de lane e com a última linha (10:11 de hoje).
- Dos 50 `scope_drift` do `log.md` só 43 receipts sobraram em `runs/`; a divisão A/B/C é sobre esses 43.
- Modelo do operador por rodada não está em nenhum log; o que digo dele é inferência.
- Não rodei `pinga queue`/`ledger` para checar se os receipts T146 a T153 da main existem; o que afirmo sobre a main vem de arquivos e mtimes.
- Avisos de Discord e criação deste arquivo são as únicas escritas da sessão.

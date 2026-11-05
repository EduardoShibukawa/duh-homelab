---
type: research
title: Eficiência das conversas interativas dono–Claude (G-Ingá revamp, 26–29/10)
date: 2026-10-29
---

# Eficiência das conversas do dono com o Claude

Método: scripts Python sobre `~/.claude/projects/-home-shibuka-Projetos-duh-homelab/*.jsonl`, `usage` deduplicado por `message.id`. Fora do escopo: 61 operadores de lane (`claude -p`, "Você é o operador…") e 3 sessões Planner/corte `-p`. Preços do pedido: Opus 5.5 US$4/20/0,20/5 por M; Sonnet 5.5 US$2/10/0,20/2,5. O cache de todas as sessões é de 1 h (`ephemeral_1h`), cuja escrita custa mais que o US$5 assumido, então o custo real tende a ser um pouco maior. Horários em UTC.

## 1. Tokens e custo por sessão

| Sessão | Quando | Turnos dono | Chamadas (únicas) | Saída | Cache read | Cache write | Custo | + subagentes |
|---|---|---|---|---|---|---|---|---|
| 158f6ed9 (Opus) | 27/10 | 7 | 179 | 89k | 26,1M | 0,22M | **$8,1** | $5,8 (13 ag.) |
| 0bb025c1 (Opus, 3 compactações) | 27–28/10 | 106 | 645 | 656k | 122,7M | 1,94M | **$47,4** | $7,8 (6 ag.) |
| 43686018 (Sonnet, Planner colado) | 27/10 | 2 | 82 | 141k | 13,6M | 0,29M | **$4,8** | 0 |
| 2da4bc76 e ac674e92 (forks de 0bb025c1) | 27–28/10 | 13/14 | 5 + 42 novas | 31k | 9,4M | 0,23M | **$3,6** (bruto $11,9; 51 msgs replay) | $0,7 |
| c2b58acd (Opus, fork de 0bb025c1) | 28–29/10 | 26 | 329 (115 herdadas) | 156k | 70,1M | 0,95M | **$21,9** (bruto $27,2) | 0 |
| 61e730c1 (Opus, atual) | 29/10 | 23 | 191 | 115k | 33,8M | 0,95M | **$13,8** | $2,2 (3 ag.) |
| 15ad1f33, b5cf4d92 | 26–28/10 | 1 | 1 | ~0 | 0 | 24k | $0,1 | 0 |
| **Total** | | ~180 | ~1.470 | 1,2M | 276M | 4,6M | **~$99,6** | **~$16,5 → ~$116** |

- Divisão do custo: cache read ~55%, saída ~24%, cache write ~21%. O input não cacheado é desprezível.
- Custo médio por chamada: US$0,045 a 0,073. Contexto mediano por chamada: 150–185k tokens. Picos: 366k (0bb025c1), 365k (c2b58acd), 292k (61e730c1).
- O custo é **número de chamadas × tamanho do contexto**, não tamanho de saída de ferramenta. Todos os `tool_result` das 4 sessões grandes somam ~1,5 MB de texto (~0,4M tokens). O maior isolado tem 35k chars (publish de Artifact). Seguem `git add` com 25k, `ps|grep` com 16k, `pgrep` com 9k e `cat` de knowledge com 7–10k.
- Baseline de ~40k tokens em turno zero (system, tools, skills, MCPs, CLAUDE.md, memória). Em ~1.470 chamadas isso é ~US$12 só de cache read.
- Sessões grandes concentram o custo: 0bb025c1 + c2b58acd + 61e730c1 = 83% do total. Só 23 turnos do dono custaram >US$1 e somam US$51 (~52%): 0bb025c1 tem 9 (US$16,2), c2b58acd 7 (US$19,9 de 26,3), 61e730c1 4 (US$8,0), 158f6ed9 3 (US$7,2). Quase todos são "ok"/"bora"/"foi?" que liberam trabalho autônomo longo.
- Recarga de cache após ociosidade longa (>1 h): 10 eventos de 140–290k tokens de cache write, ~US$11 no total. Exemplos: c2b58acd 143, 81 e 248 min de pausa; 0bb025c1 194 e 364 min.

Onde foi o dinheiro (parcial, 4 sessões grandes, custo por tipo de chamada):

| Tipo de chamada | Chamadas | Custo | Observação |
|---|---|---|---|
| Polling/status (`pgrep`, `ps`, `tail`, `sleep`, `date`, `cat log`) | 481 | **~$34 (35%)** | 0bb025c1 198 / $15; c2b58acd 159 / $12; 61e730c1 73 / $5; 158f6ed9 51 / $2,2 |
| Bash de trabalho (testes, git, cat/sed de arquivos) | 562 | ~$32 | leitura via `cat`/`sed -n` = 214 chamadas |
| Texto sem ferramenta (conversa de design) | 288 | ~$19 | em sua maioria alto valor (0bb025c1 foi concepção do G-Ingá) |
| Write/Edit/Artifact/Agent | ~120 | ~$8 | |

## 2. Fomos eficientes? Onde não

- **Babá de processo (maior desperdício, ~US$34).** Claude fazia polling em loop enquanto lanes rodavam: 481 chamadas Bash de `pgrep`/`tail`/`sleep`, cada uma carregando ~180k de contexto (US$0,04–0,07). Exemplo, c2b58acd 12:22: `pgrep -f op-rodada3; ls -la …log; date; grep -oE 'TASK-…'` repetido dezenas de vezes. Só ~24 chamadas de `Monitor`, que bloqueia e custa uma única chamada, apesar de o dono pedir isso ("pq eu tenho que ficar te avisando? … sete um monitor").
- **Pings do dono ("foi?", "e agora??", "caiu de novo neh", "como ta?", "ta rodando mesmo?").** Em c2b58acd são 11 turnos a **US$10,7** (cada um dispara 5–80 chamadas de verificação); em 0bb025c1, 7 turnos a US$2,5. Causa-raiz: "não to recebendo nada no discord". A falta de push confiável transforma o dono em poller e o Claude em Opus-poller.
- **Contexto gordo nas sessões longas.** 0bb025c1 e c2b58acd viveram 18–24 h de relógio, com contexto mediano de 175–180k. O dono percebeu ("essa ta com muito contexto", "vou dar um clear para nao gastar muito com cache miss"), mas c2b58acd foi *fork* de 0bb025c1 e herdou 115 mensagens, e depois seguiu orquestrando 90 chamadas num turno (US$4,0) e 80 noutro (US$5,9).
- **Opus para tudo.** `settings.json` tem `model: sonnet`, mas as sessões interativas rodaram em Opus (exceto a 43686018). Subagentes `claude` herdam Opus: o Planner da SPEC-0001 custou $4,70 (53 chamadas), contra $0,5–0,7 dos de Sonnet.
- **Claude como operador apesar da regra "operar via Pi"/"tudo pelo harness".** 0bb025c1 e c2b58acd têm 68 e 95 chamadas `manda`/`pipeline`/`dispatch` feitas à mão. O dono reclamou ("pq vc ta fazendo tudo em vez de usar subagents, ta acabando a quota").
- **Releituras.** `bin/dispatch-task.sh` lido 7× (c2b58acd), `src/install.ts` 7× (158f6ed9), `index.md`, `ROUTING` e prompts 3× cada. Menor, mas soma, pois cada leitura vira contexto carregado nas chamadas seguintes.
- **Forks com replay.** Retomar com fork/`resume` de uma sessão de 300k+ (2da4bc76, ac674e92, c2b58acd) reescreve o cache (190–290k de cache write por retomada, ~US$1–1,5 cada).
- **Resultados pontuais evitáveis.** `ps -eo … | grep` com 16k chars em 158f6ed9; `Artifact publish type_url` com 35k chars de retorno; `read` de Artifact com 10k; `git add` imprimindo 25k.

## 3. O que foi muito bom (manter)

- **Subagentes baratos e em paralelo.** 13 auditorias/benchmarks em 158f6ed9 custaram $5,8 de trabalho que no contexto principal custaria muito mais; os 3 de pesquisa/validação em Sonnet custaram $0,4–0,6 cada. A memória do dono já manda isso.
- **Decisão dirigida por quota:** "quota do Claude já tá em 79%", mandar o prompt para rodar no Pi/OpenCode, desligar lane Go quando só o Zen gastou. O ROUTING.md e a regra "sem escalada automática" nasceram das contas reais.
- **Medir antes de agir:** análise de sessão (`pi-analise-sessao`), "quanto foi gasto até agora?", constatação de que o operador LLM era ~96% do custo Zen (tick determinístico vira melhoria nº 1).
- **Artefatos pequenos e estáveis:** `index.md` (4,4 KB) e `log.md` (5,5 KB) são baratos de ler e bastam para começar. `status.sh` e `vigia.sh` já existem e dão estado sem LLM.
- **Sessão Sonnet 43686018 (Planner colado):** 82 chamadas por $4,8 com prompt pronto e fechado. O padrão "prompt autossuficiente colado em sessão nova" evita carregar o histórico.
- **Perguntas ao dono apenas em decisões reais** (6× `AskUserQuestion` em 0bb025c1), e `ToolSearch` só 7× para carregar MCPs diferidos.
- **Imagens usadas com parcimônia** (28 em 18 MB de transcrição, ~4 MB).

## 4. Skills, prompts, tools e MCPs

| Item | Uso observado | Avaliação |
|---|---|---|
| `Agent` (Explore/general-purpose/claude) | 26 chamadas | Ajudou. Falta forçar `model: sonnet` nos de leitura/pesquisa. |
| `Monitor` | ~24 | Ajudou onde usado; subutilizado frente a 481 polls. |
| `Bash` (≈ 85% das chamadas) | ~1.100 | Principal veículo de polling e de leitura de arquivo (`cat`/`sed -n`). |
| `Read`/`Edit`/`Write` | 3 / 22 / 108 | Pouco `Read`: arquivos grandes lidos via `cat` sem limite. |
| Skills | 1 (`dataviz`) | `pinga`, `red-audit`, `gira-*`, `tuios` nunca invocadas nas conversas do dono (a governança roda nas lanes). Sem desperdício direto, mas ~25 skills + MCPs claude.ai (Docs, Drive) inflam o baseline de 40k. |
| MCP `pi-harness` (`harness_status`, `harness_next`) | 2 + 4 | Subutilizado: devolve exatamente o estado que 481 `pgrep`/`tail` reconstruíam à mão. |
| MCP `gira`, `tuios` | 0 | Sem uso nas conversas (tuios só via hook). |
| Prompts em `.ginga/prompts/` (PASSO-A-PASSO, pi-operador, corte-task06) | Bons | O dono pediu "passo a passo bonitinho" e modelo/effort por passo: funciona como ponte para sessões novas. |
| **Faltaram** | | (1) comando único de estado sem LLM com delta desde a última checagem; (2) push confiável (Discord/Telegram) em marcos; (3) statusline com quota (7d%, 5h%, custo da sessão); (4) hook que corta saídas >N linhas e avisa contexto >150k; (5) `Agent` com modelo padrão barato. |

## 5. Recomendações (por economia estimada, base ~US$116 nesta janela)

1. **Matar o polling com push + bloqueio (~US$20–25, 20%).** (a) `vigia.sh`/`notify.sh` mandam Discord/Telegram em cada transição (início, TASK pass/fail, judge, merge, travado, fim) e o Claude **não consulta**: encerra o turno com "aviso quando terminar". (b) Se precisar esperar, uma única chamada `until … ; do sleep 30; done` ou `Monitor` com condição, nunca `pgrep` em loop. (c) Regra em `index.md`: "proibido sondar processo; use `status.sh`/`harness_status` uma vez por turno do dono".
2. **Estado em uma chamada barata (~US$8–10).** `ginga status --since-last` (ou estender `.ginga/bin/status.sh` e expor via `harness_status`): ondas, TASKs pass/blocked, custo do dia por provedor, lanes vivas, último evento e "nada novo desde HH:MM". Resposta de 10–15 linhas. Quando o dono perguntar "foi?", Claude roda essa chamada em sessão Sonnet/curta, não Opus de 300k.
3. **Sessões curtas que começam no `index.md` (~US$15–25).** Teto de ~100–120k de contexto: ao passar disso (ou ao terminar uma onda), o Claude grava handoff em `handoffs/` (decisões + próximos passos) e o dono abre sessão nova. Custa ~US$0,2 para começar; retomar fork de 250k custa ~US$1,25 só de cache write. Evitar `fork` de sessão grande; preferir sessão nova com prompt PASSO-A-PASSO. Hook `UserPromptSubmit` que avise `contexto >150k, sugerir /clear + handoff`.
4. **Modelo certo por papel (~US$10–15).** Sonnet como padrão das conversas de operação/status; Opus só em concepção de SPEC/Planner (ex.: 0bb025c1 design). Subagentes de leitura/auditoria/pesquisa com `model: sonnet` (Planner $4,7 → ~$2,3). Isso só vale se o dono trocar o modelo da sessão (`/model`) ou se a statusline lembrar.
5. **Operador fora do Claude (já decidido, falta cumprir) (~US$10–15).** O tick determinístico (lacuna 1) assume `manda run/pipeline`; Claude só aprova, não despacha. Os 163 comandos `manda/pipeline/dispatch` à mão em 0bb025c1 e c2b58acd viram `autoloop.sh`/`systemd` + Discord.
6. **Hooks de higiene (~US$3–5).** `PreToolUse`/`PostToolUse` Bash: se a saída >200 linhas ou >8k chars, truncar com `… (+N linhas; ver arquivo)` e salvar o completo em scratchpad; bloquear `ps -eo|grep` sem `| head`. Lembrete para usar `Read` com offset/limit em vez de `cat` de arquivo grande. Ler uma vez e anotar em `log.md`.
7. **Enxugar baseline de 40k (~US$4–6).** Desligar MCPs claude.ai (Docs, Drive) e plugins não usados neste workspace; manter só `pi-harness`. `CLAUDE.md` e `MEMORY.md` já são curtos.
8. **Statusline com quota (barato, alto comportamental).** `statusLine` em `settings.json` (hoje ausente) mostrando semana%/5h%, custo da sessão, tamanho do contexto e idade do cache (1 h). O dono já tem a necessidade ("quota ta em 79%", "quanto foi gasto até agora?").
9. **Regra de pausa:** antes de ausência >1 h ("vou dormir", "vou buscar meu filho"), o Claude fecha a sessão com handoff e deixa o harness+Discord rodando, em vez de manter contexto de 250k que será recarregado a ~US$1,25.
10. **Perguntas do dono:** `harness_status` já responde "o que tem pendente?" (pedido 6× nas sessões). Colocar em `index.md` o bloco "Pendências agora" gerado pelo `status.sh`, para o Claude responder lendo 1 arquivo.

Resumo da meta: com 1–3 + 5, as conversas cairiam de ~US$99 para ~US$55–60 na mesma carga, mantendo as decisões de design (que são o valor real do Opus aqui).

## Notas e ressalvas
- 2da4bc76 e ac674e92 são continuações/forks de 0bb025c1; c2b58acd é fork com 115 mensagens herdadas. A tabela mostra o custo não duplicado.
- O pedido cita c2b58acd como "sessão atual", mas o parente deste trabalho é 61e730c1 (último arquivo). Ambas entram.
- Dentro de "polling" a regex inclui `cat …(status|log)` e `date +%H:%M`; o número real fica entre US$28 e 34.
- Script de apoio em `/home/shibuka/.claude/jobs/c2b58acd/tmp/` (`stats.py`, `poll.py`, `turns.py`, `detail.py`, `sub.py`).

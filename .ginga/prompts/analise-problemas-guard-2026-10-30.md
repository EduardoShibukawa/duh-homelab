# Prompt: análise dos problemas do harness achados na sessão do guard de segredos (2026-10-30)

Você é um analista **somente leitura** do workspace /home/shibuka/Projetos/duh-homelab (português do Brasil). Leia `CLAUDE.md` e `.ginga/index.md`. Contexto: a sessão `28f440af` desenhou o guard de segredos (PLAN-0033, `.ginga/plans/PLAN-0033-guard-de-segredos/`, pesquisa `.ginga/knowledge/research/guard-segredos-2026-10-29.md`) e o pôs na fila das lanes. Ao acompanhar, apareceram problemas **do nosso harness** (lanes, operador, executores, pinga, gate). O dono quer que você os analise com evidência.

## Problemas já vistos (ponto de partida; confirme, quantifique e procure mais)

1. **`scope_drift` por arquivo de depuração:** TASK-01 do PLAN-0033 falhou 7+ vezes, com 3 modelos (`pi:nvidia/meta/muse-glimmer-30b`, `opencode-go/iceman-contributor-free`, `pi:nvidia/mistralai/mistral-large-4-1t-a52b`). O código já passava 62/62; sobravam `debug.js` e `debug2.py` na raiz da worktree `ginga-plan-0033`. Veja `plans/PLAN-0033-guard-de-segredos/log.md` e `plans/PLAN-0033-guard-de-segredos/runs/`. Pergunte: o harness deveria limpar/ignorar untracked fora do `touch`? Quantos `scope_drift` do workspace têm essa causa (cruze `plans/*/log.md` e `runs/`)?
2. **Main do `ginga/` suja bloqueia todo merge:** o `merge-gate.sh:28` saiu com exit 2 ("main com mudancas nao commitadas") no PLAN-0013 r4. `git -C ginga status`: `src/verbs/registry.ts` e `tests/cli_verbs.test.ts` modificados, `src/handoff*`, `src/lessons.ts`, `src/verbs/learning.ts` e `tasks/T145..T148` não rastreados. As regras do `prompts/op-base.md` proíbem editar na main; o operador (modelo free) editou mesmo assim. Descubra **quem, quando e por quê** (cronologia pelos `handoffs/lane-ginga-20261030-*.log` e mtimes). Pergunte: falta uma trava determinística (hook/guarda de cwd) em vez de regra em prompt?
3. **`pinga prove-red` devolve "not run" (inconclusivo) quando o módulo não existe:** T145–T148 e T150 do PLAN-0033 (testes que importam arquivo ainda inexistente). A RED fica "não provada". Veja o log do PLAN-0033 e `p-inga/src/prove.ts`.
4. **Colisão de ids de TASK do pinga entre branches:** `plan/0013` usa T146/T153/T154 e `plan/0033` usa T145..T150; o `pinga queue` de cada worktree não vê a outra. O PLAN-0010 já tinha sofrido isso (backlog-ginga.md, primeiro item). Quantas vezes ocorreu? Qual desenho resolve (alocador central no `state.db`, prefixo por PLAN)?
5. **Lane para com "sem progresso" mesmo trabalhando:** `handoffs/lanes.events` (rodada 4 do ginga às 10:11: gate 2 e "sem progresso"). A ordem "achados do judge primeiro, backlog depois" + máximo de 2 itens por rodada faz um item PRIORIDADE do backlog ficar sem ser pego? Meça: nas últimas 24 h, quantas rodadas tocaram só o judge-finding do mesmo PLAN, e quanto tempo um item novo do backlog esperou.
6. **Operador free instável:** `infra_stuck` (900 s sem progresso, morto) em vários modelos NVIDIA; "operador ocupado há 30 min por outra lane" (flock `.op.lock`); rate limit. Tabule por modelo: tentativas, falhas por motivo, tempo médio, taxa de pass (`plans/*/log.md`, `handoffs/lanes.events`, `runs/*.log`). Qual modelo da escada realmente entrega?
7. **Achados de desenho do guard** (já documentados na pesquisa §2, confirme só se for barato): o `pre_tool_guard` do plugin `pinga-harness` do Hermes retorna `str` e o núcleo só aceita `dict` (`~/.hermes/hermes-agent/hermes_cli/plugins.py:1964-1983`), logo o G2 não bloqueia nada; o `sandbox-run.sh` isola só o `done_when`, não o runtime; o opencode 2.2.2 chama o shell de `shell`.
8. **Armadilhas de processo da própria sessão:** (a) testes de bloqueio passavam por engano porque a falha fechada também "bloqueia"; (b) editar `lane.sh` com a lane rodando corrompe o bash (use troca atômica com `mv`); (c) `done_when` roda com `--clearenv`, perdendo `PYTHONDONTWRITEBYTECODE`; (d) guard ligado por padrão + arquivo ausente = lane não inicia (ordem de aplicação da TASK-06).

## O que entregar

Um único arquivo: `.ginga/knowledge/research/problemas-harness-sessao-guard-2026-10-30.md` (frontmatter `type: research`, `status: draft`, rótulos **[verificado]**/**[inferência]** como em `skills-e-hooks.md`), com:

- Uma **tabela** por problema: sintoma, evidência (arquivo:linha ou comando), causa-raiz (defeito do harness | modelo fraco | configuração | processo), frequência medida, custo (tentativas/cota/horas paradas), gravidade.
- **Problemas novos** que você achar lendo `handoffs/lanes.events`, `handoffs/REPORT-2026-10-28.d/decisoes.md`, os últimos `plans/*/log.md` e `handoffs/lane-*-20261030-*.log`.
- Por causa-raiz, uma **proposta** de correção no formato da convenção (INTENT → SPEC → PLAN → TASK, só um esboço de 3–5 linhas cada, com `touch` e `done_when` prováveis). Priorize por "o que mais atrasa o merge do guard e dos PLANs na fila".
- Um **ranking** final (top 5) e o que depende de decisão do dono (dinheiro, dados a terceiros, ações reservadas); o resto o harness decide.

## Regras

- **Somente leitura.** Não edite código, scripts em `.ginga/bin/`, `handoffs/lane.env`, backlogs, PLANs ou TASKs de outros PLANs; não mexa em `ginga/`, `manda/`, `p-inga/` nem nas worktrees; não rode lanes, executores, `manda`, `pinga verify/prove-red`, judge ou gate; não commite. Só crie o arquivo de saída.
- Não imprima nem copie segredos. Se achar formato de chave em log, cite só `arquivo:linha` e a regra.
- Use `rg`, `sed -n`, `git log/show/status` (leitura) e `jq`. Seja econômico: não leia logs inteiros, filtre.
- Ao terminar, avise no Discord em 2 linhas: `HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<resumo: top 3 achados e o caminho do arquivo>"`.

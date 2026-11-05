---
type: intent
title: Sandbox no executor e code mode no orquestrador
source: cli
timestamp: 2026-10-27T23:30:00-03:00
status: open
---
## Pedido do dono

"quando eu vejo sandbox eu penso em imagem docker, ou algo do genero sem acesso a tudo e sim somente ao que precisa". Pesquisar o bwrap e sandboxes para agentes de IA, como entregar as tools ao agente dentro da sandbox, e como ele se comunica com o lado de fora para salvar as coisas nos lugares certos.

## Contexto

- Palestra "code mode" (Arize/Phoenix), https://www.youtube.com/watch?v=dAoOYFx7ZYw:
  - menos turnos e menos tokens (−43% medido por eles);
  - sandbox com rede desligada na avaliação (Harbor, pass@k).
- Hoje, o `opencode run --auto` roda na worktree **sem isolamento**:
  - lê o `~` inteiro, segredos incluídos;
  - tem rede livre;
  - escreve em outros repos;
  - altera os `tests_frozen`, que o gate só restaura depois.
- Os buracos que o judge achou no gate do manda (PLAN-0007) são sintoma disso.
- Ferramentas instaladas: `docker`, `bwrap`, `systemd-run`.

## Hipóteses a validar

1. Executor em `bwrap`:
   - worktree com leitura e escrita;
   - `tests_frozen` somente leitura;
   - sem `.git`, sem `~` e sem outros repos;
   - só a chave do provider da TASK;
   - rede só para o endpoint do provider.
2. Comunicação por **outbox**: o executor escreve em `outbox/` e o host (dispatch ou manda) valida e roteia para `LEARNINGS.md`, `$GINGA_EVENTS`, ledger e commit.
3. Code mode no orquestrador:
   - CLIs com `--json` curto, com o detalhe gravado em arquivo;
   - SQL sobre o ledger e o `state.db`.
4. Medir num A/B no bench: tokens do Claude, turnos e FTPR por PLAN.

## Saída esperada

- Pesquisa em `knowledge/research/sandbox-ai.md`.
- Depois, uma SPEC ou uma emenda aos PLANs 0007, 0008 e 0014.

## Slides da palestra (fotos enviadas pelo dono em 2026-10-28)

- **Medição real deles** (18 tasks, 2 rodadas):

  | Variante | Reward | Turnos | Prompt tokens |
  |---|---|---|---|
  | Code mode antigo | 16/18 | 142 | 3,67M |
  | Sem code mode | 15/18 | 86 | 2,80M |
  | Code mode **depois de ajustar as instruções** | 16/18 | 101 | 1,56M |

  O code mode antigo era **pior** que sem code mode. Só ganhou depois do ciclo eval → traces → ajuste. Resultado final: −43% de tokens, −31% de custo, reward igual e latência +0,6%.
- **Avaliação:**
  - **Task** = instrução + ambiente + testes.
  - Cada trial roda em **sandbox nova**, e o verifier roda os testes, com reward de 0 a 1 e k trials.
  - **Baselines:** Claude Code com MCP (uma tool por chamada), Claude Code com CLI + skill, e um **Oracle**, que é a solução de referência.
- **Problemas em aberto:**
  - durabilidade (snapshot);
  - determinismo (Starlark × JS);
  - binários e imagens;
  - **modelos pequenos falham no code mode**.
- **Complexidade operacional:**
  - custo de startup: isolate em ms, microVM em centenas de ms, VM cheia em segundos;
  - debug mais difícil;
  - tool discovery;
  - **duplicar o harness**: MCP com tool search e code exec por cima de um harness que já tem os dois.
- **Riscos do código gerado por LLM:**
  - limites de CPU, memória e tempo;
  - saída de rede, com README injetado exfiltrando dados;
  - segredos dentro da sandbox (`print(env)`);
  - permissões amplas demais.
- **PXI:**
  - `bash` + `execute` + `executeSql`, sobre GraphQL, REST e banco;
  - "code mode no browser": o agente escreve um script `ui.*` que roda num Web Worker e dirige a app real.
- **Phoenix** (https://github.com/arize-ai/phoenix): **descartado**, porque a licença é ELv2 e não é aprovada pela OSI (DECISION-0003). O que ele faz: mostra traces de projetos `claude-code` (spans, tokens, custo, turnos). É candidato a backend de observabilidade do harness. Não verificado.

## Sandbox agnóstica de runtime (dono, 2026-10-28)

"Não queremos somente opencode, né? Queremos qualquer um: pi, codex, opencode, agy, claude etc."

- **Porta `Sandbox` separada da porta de runtime** do manda: `sandbox.run(profile, cmd, worktree) → {exit, outbox}`. Ela vale para qualquer runtime.
- **Um perfil declarativo por runtime**, guardado junto do adaptador do runtime (PLAN-0007, TASKs 03 e 04):
  - `mounts`: toolchain somente leitura e config/credencial mínima;
  - `env`;
  - `domains` (allowlist);
  - `flags`.
- **Particularidade de cada runtime:**
  - opencode: precisa de `--standalone`, senão usa o serviço compartilhado na porta 49374;
  - claude: credencial em `~/.claude` e domínios da Anthropic; tem sandbox nativa;
  - codex: tem sandbox nativa;
  - agy: login Google, possível daemon;
  - pi: config própria.
- **Sandbox dupla:** claude e codex já têm sandbox própria. Bwrap dentro de bwrap pode falhar por causa de user namespace aninhado. Decidir por runtime: a nossa sandbox como fronteira externa e a nativa relaxada, ou o contrário.
- **Validação:** uma matriz runtime × {responde "ok"; escreve na worktree; não lê `~/.ssh` nem `~/.hermes`; não alcança a 49374 nem a LAN}. Esse é o critério de "runtime suportado em sandbox".

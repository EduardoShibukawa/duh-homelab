Você é o operador do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). O dono disse em 2026-10-28: "vamos executar tudo que está pendente".

Leia antes:
- `.ginga/prompts/operador.md` (regras);
- `.ginga/models/ROUTING.md` (seção "Vigente desde 2026-10-28");
- `.ginga/handoffs/HANDOFF-2026-10-28-onda-3.md`;
- `.ginga/plans/PLAN-0019-free-ilimitados/PLAN.md`.

Outro agente está mexendo **só** em `.ginga/knowledge/design/`, `.ginga/specs/` e `.ginga/knowledge/research/`. Não toque nesses caminhos.

## Regras duras

- **Tudo pelo harness:** TASK + teste RED congelado + despacho + `pinga verify` + judge + merge. Nenhuma edição de código fora de TASK.
- **Modelos** (ROUTING de 2026-10-28):
  - executor: free do Zen, ou o primeiro degrau do PLAN-0019 (`opencode-go/beam-free` nas TASKs ímpares, `opencode-go/iceman-contributor-free` nas pares; o iceman só recebe TASK.md e código);
  - depois do primeiro degrau: Go `qwen3.8-flash` → Go `deepseek-v4.1-flash`;
  - **nunca** o Zen pago (`opencode/deepseek-v4-pro`) e **nunca** escalar sozinho para strong;
  - judge: Codex `gpt-6-luna` read-only.
- Cada tentativa de executor vira uma linha em `.ginga/plans/PLAN-0019-free-ilimitados/results.jsonl`: `{"task","plan","model","attempt","pass","seconds","tokens"}`. Para os tokens, use `.ginga/bench/code-mode/tokens.sh <sessionID>` quando der.
- Nunca push. Nunca apagar (`_archive/` com MANIFEST). Commit com caminhos explícitos. Uma TASK por repo de cada vez. Antes de atribuir T<N>, confira no ledger que o id está livre no repo.
- **Discord** a cada etapa: `HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<msg>"`. Só marque como CRÍTICO o que precisar do dono.
- **Merge:** se o judge der pass, ou só trouxer achados **novos** (não regressões), mergeie e abra os novos como follow-up num PLAN draft. Só uma regressão bloqueia.

## Fila

1. **Judges finais já rodados:**
   - leia `/tmp/claude-1000/-home-shibuka-Projetos-duh-homelab/ea78a4d0-2b4b-452d-8c3e-ad31927edf6e/scratchpad/judge/0004.codex7` e `0018.codex4` (os dois só com achados novos/simples, sem regressão: merge + follow-up) (última linha `{"verdict"...}`);
   - aplique a regra de merge acima: **PLAN-0004** em ginga + pi-harness, **PLAN-0018** em p-inga;
   - em cada merge: `pinga ledger verify`, `runs/` para o repo principal, remover a worktree (a branch fica), `status: done`, linha no `log.md`.
2. **PLAN-0008:**
   - (a) **Replan da TASK-04:** a escada segue a ROUTING de 2026-10-28 (sem nemotron, sem escalada automática para strong, degraus do Go). Reescreva o teste RED congelado dela, porque o atual foi escrito antes da regra; quem o escreveu foi o Planner da passada RED, então a troca é sua como Planner. Registre o motivo.
   - (b) **TASK-02:** frontmatter da ROUTING legível por máquina (`ladder`, `pools`, `budget`), igual às tabelas de 2026-10-28.
   - (c) Crie `manda/.ginga/project.toml` com `[runtimes]` (o primeiro degrau alternado do PLAN-0019) e despache as TASKs 03 a 08 com **`manda run`**. Se o `manda run` falhar por defeito dele, registre no `LEARNINGS.md` do PLAN-0007 e use o `.ginga/bin/dispatch-task.sh` só como reserva.
   - Depois: judge e merge.
3. **PLAN-0010 TASK-06:** replan (o `done_when` não pode depender do `~/.hermes` real). Depois, **PLAN-0006 e PLAN-0010** com o ginga já mergeado: recrie as worktrees a partir da main nova, despache, judge e merge.
4. **PLAN-0018 TASK-03:** desacople `tests/discord.test.ts` (T26) e `tests/ux_t52_hardening.test.ts` (W12) do HOME real, com HOME falso (`tests/helpers/home.ts`). Depois, coloque o p-inga em `SANDBOX_REPOS`.
5. **Fim:**
   - atualize `.ginga/index.md` (o quadro de trabalho) e um handoff novo, `HANDOFF-2026-10-28-pendentes.md`;
   - mande um resumo no Discord: o que foi mergeado, o que ficou blocked e o que precisa do dono.

Se algo travar por motivo que não seja de código (cota, infra, decisão), avise e siga para o próximo item.

## Orçamento (dono, 2026-10-28, ao sair)

- **Saldo do Zen: só US$2.** Proibido qualquer modelo `opencode/*` que não termine em `-free`. Isso inclui o Pi com Zen pago, o `pi-run.sh` e o Jev pago.
- O `dispatch-task.sh` tem `PAID=opencode/deepseek-v4-pro` nas tiers medium e strong. **Não use essas tiers por ele**: só `light`, ou o `manda run` com `[runtimes]` free/Go.
- Free e Go (`opencode-go/*` dentro do `opencode run`) liberados. Seja econômico com contexto: leia trechos (`sed -n`, `rg`), não arquivos inteiros.
- Se acabar o free e o Go, pare o item, registre e siga.

## Report final (obrigatório)

Escreva `.ginga/handoffs/REPORT-2026-10-28.md` com **tudo** o que foi feito no dia:
- por PLAN/TASK: o que mudou, commits, merges e receipts;
- o que ficou blocked e por quê;
- os achados de judge que viraram follow-up;
- gasto por modelo (de `paid-spend.tsv` e `results.jsonl`);
- as decisões tomadas sem o dono, para ele revisar e gerar specs de correção.

Envie no Discord só o caminho do report e um resumo de 5 linhas.

## Nota (2026-10-28)

O Go deu "usage limit exceeded" no operador em `deepseek-v4.1-flash`, e este operador roda em `opencode-go/beam-free`. Isso é uma decisão sem o dono e entra no report. Se o Go der limite também no executor, use só os free (`glm-5.3-flash-free`, `deepseek-v4.1-flash-free`, `beam-free`, e o `iceman` só em TASK de código MIT).

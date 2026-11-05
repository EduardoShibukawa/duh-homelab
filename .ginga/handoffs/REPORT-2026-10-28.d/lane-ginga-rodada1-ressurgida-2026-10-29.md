# Lane ginga, rodada 1 — sessão ressuscitada 2026-10-29 ~21:30

Sessão iniciada em 2026-10-28 com o prompt "Lane ginga, rodada 1". O servidor reiniciou no meio do
trabalho; a sessão retomou em 2026-10-29 ~21:30, com o prompt desatualizado. Nenhum arquivo de
código foi tocado por mim nesta retomada. Só fatos medidos.

## Backlog do meu prompt — verificado, tudo já concluído por outras rodadas
Verdade: `pinga queue --json --root ginga-plan-0028` + `git -C ginga log main` + `bun test`.

- PLAN-0023 follow-up 10 (`stale_ready` + `ready_writer`): feito como **PLAN-0025** — T102 receipt
  `pass` (seq 575), T103 receipt `pass` (seq 574); mergeado na main (`PLAN-0025-hooks-llm-e-stale-ready`).
- PRIORIDADE hooks (`reference-transaction` recusa main com ancestral LLM mesmo com `MERGE_GATE=1`):
  feito como **PLAN-0025** — T101 receipt `pass` (seq 557); mergeado; `hooks check` exit 0 (r6 de
  2026-10-28, log do PLAN-0022).
- `ginga install` (link `~/.local/bin/ginga`): feito como **PLAN-0026** — T104 receipt `pass`
  (seq 597); mergeado (`PLAN-0026-install-bin-link`).
- Limpeza automática de worktrees: feito como **PLAN-0027** — T105 receipt `pass` (seq 591);
  mergeado (`PLAN-0027-limpeza-worktrees`).
- Fila: `open=0, blocked=0, leased=0` em ginga até T136. Nada pendente do meu prompt.

`bun test` na worktree `ginga-plan-0028` (árvore == main 4cb91f0), rodado por mim às 21:40:
**460 pass / 0 fail** (76 arquivos, 21,8 s).

Conclusão da rodada: nenhum item restou para resolver → não gravei `ready` (regra: só quando todas
as TASKs do item têm `pass`; os `ready` destes itens já foram gravados e consumidos pelos gates).

## Achados do judge NOVOS (fora do escopo deste prompt) — não executados por mim
- `judge/ginga.json` de PLAN-0028 (veredito **fail** no head `baac34d`, 20:44:42): TASK-04 parcial
  (`src/tick.ts:371` `cap_ok:true` fixo; judge nunca lido/passado a `nextAction`; ninguém cria a fase
  `approved`; sem saída/limite 2 no `replan`; sem "um run por repo por tick"), TASK-07 parcial
  (`childArgv` exportada e não usada; `parseSupervisorConfig` não lê `[supervisor] mode`;
  `ginga tick --loop` não existe), TASK-08 inexistente (`tests/e2e/autonomo.test.ts`,
  `tests/fixtures/autonomo/`), AC não atendida.
- O `merge-gate.sh` mergeou mesmo com veredito fail (exit 0 20:47:43 → `4cb91f0`); bug de gate
  corrigido pelo governador às 20:48 (decisoes.md). Decisão de manter ou reverter `4cb91f0`: **do dono**.
- Não corrijo estes achados: a lane tem operador VIVO agora (`lane-ginga-20261029-2044-r2`,
  `opencode-go/iceman-contributor-free`, pid 207535, timeout 7200, segurando
  `handoffs/.op.lock`), trabalhando em PLAN-0012. Dois operadores LLM simultâneos no mesmo lane não
  têm regra que cubra → registrado como decisão em decisoes.md.
- TASK-08 (e2e): pré-requisito do dono NÃO cumprido — `git -C manda log main | grep PLAN-0028` = 0;
  gate manda exit 11 (21:20:50). Não iniciada (regra "só quando").

## Fatos observados sobre o estado corrente da lane (para quem rodar depois de mim)
- `.ginga/plans/PLAN-0012-roda-web/ready/ginga.json` existe → judge/gate rodam após o r2.
- T159 (web shell do r2) está materializada como `tasks/T159/PLAN.md` na RAIZ do workspace
  (`/home/shibuka/Projetos/duh-homelab/tasks/T159/PLAN.md`), fora do repo; no ledger: `blocked`,
  `reason_code: test_passed_on_base` e `not run/infra` com attempts 15. `pinga queue` com `--root
  ginga-plan-0012` não lista T159.
- O `TASK-09-manda-red-cli.md` do PLAN-0028 já declara `pinga_task: T159` (lane manda) — mesma
  numeração em outro repo; a alocação determinística (TASK-02/T154) ainda não está sendo usada aqui.

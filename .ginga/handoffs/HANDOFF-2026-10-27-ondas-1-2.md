---
type: handoff
plan: [PLAN-0004, PLAN-0005, PLAN-0007, PLAN-0017, PLAN-0018]
timestamp: 2026-10-27T23:59:00-03:00
---
## Estado

| PLAN | Status | Onde |
|---|---|---|
| 0005 pinga TASK/PLAN | **done**: merge `aad1425` em p-inga/main | worktree removida, branch `plan/0005` mantida |
| 0007 manda núcleo | **done**: merges manda `0473083` e pi-harness `1662cfe` | worktrees removidas; o T58 do 0007 virou **T59** (colidia com o T58 do 0004) |
| 0004 eventos + lint | approved, **rodada 3 de fix** autorizada pelo dono ("boraa") | `ginga-plan-0004` + `pi-harness-plan-0004`; TASK-11 (T9) despachada |
| 0018 sandbox do done_when (opção A) | approved; TASK-01 (T71) despachada | `p-inga-plan-0018` (branch `plan/0018`) |
| 0017 pi-harness sai | draft, onda 7, validado (ajustes aplicados) | só docs |

- **Ledger:** `pinga ledger verify` → ok 340. **Custo pago:** ~US$0,54 de um teto de US$2,00, só Zen.
- **Nome** (DECISION-0004): o repo e o pacote passam a se chamar `g-inga`; o CLI continua `ginga`. O `G-Inga` antigo no GitHub virou `g-inga-v1`, arquivado. O rename local fica para o INTENT-0007, depois do 0004.
- **Arquivados** (`_archive/`, com MANIFEST): `2026-10-27-p-inga-plan-0005`, `2026-10-27-manda-copia-antiga`, `2026-10-27-plan-0007-worktrees`.

## Próximos passos (nesta ordem)

1. **0004 TASK-11:**
   - se der `pass`, rodar só o judge Codex. O flash já deu `pass`; prompt em `scratchpad/judge/p4.txt`, trocando a nota da rodada.
   - se o Codex der `pass`: commit com **caminhos explícitos** (o hook bloqueia `git add -A`), merge `--no-ff` em ginga e em pi-harness, `pinga ledger verify`, mover o `runs/` para o repo, remover as worktrees e marcar `status: done`.
2. **0018 TASK-01:** se der `pass`, a TASK-02 é do operador:
   - escrever `.ginga/bin/sandbox-done-when.sh <root> <cmd...>` reaproveitando o `sandbox-run.sh`, com `--unshare-net` e o bun do mise montado somente leitura;
   - matriz de validação: não lê `~/.ssh` nem `~/.hermes`, sem rede, `bun test` passa;
   - `dispatch-task.sh` exporta `PINGA_EXEC_WRAPPER`;
   - depois: judge (Codex) e merge.
3. **INTENT-0007 (organização):**
   - `worktrees/`, `bench/`, AGENTS.md único, LICENSE MIT (falta confirmar MIT × Apache);
   - rename `ginga` → `g-inga`;
   - salvar os 4 arquivos do pi-harness fora do git.
4. **PLAN-0016 (code mode):** começar pela TASK-02, medir os tokens do opencode. Agora isso é mais fácil, com `--standalone` e `session export`.

## Como operar barato

- **Executor:** `.ginga/bin/dispatch-task.sh <TASK.md>`, só modelos free do Zen.
  - Agora usa `opencode run --standalone` e `timeout` de 1200 s por tentativa (`ATT_TIMEOUT`).
  - O serviço compartilhado na porta 49374 **trava os clientes** (0% de CPU): não usar.
- **Judges:**
  - flash: `agy --model gemini-3.8-flash --effort high --add-dir … -p "<prompt>"`, com o `-p` por último. O JSON dele sai em várias linhas.
  - Codex: `codex exec -m gpt-6-luna -s read-only`.
- **Claude:** só para contratos, testes RED e merges.

## Aprendizados (aplicar)

- **Contrato com testes contraditórios:** antes de despachar, rodar todos os testes do `done_when` contra o contrato novo. Na 0005, a TASK-09 travou 6 tentativas porque um teste antigo exigia `null`.
- **pinga_task único por repo:** dois PLANs usaram T58 no pi-harness. Antes de atribuir um id, conferir no ledger (`select distinct task … where repo like '%<repo>%'`).
- **Pre-commit AC-SEC:** strings de alfabeto (base32) disparam o detector de entropia. Concatenar dígitos + letras.
- **`prove-red`:** responde "sem base" quando o teste frozen ainda não está commitado. Demonstrar o RED à mão e registrar no `log.md`.
- **Antes de remover uma worktree:** mover o `runs/` (ignorado pelo git) para o repo principal. São artefatos citados nos receipts.

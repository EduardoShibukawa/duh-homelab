Você é o operador 2 do duh-homelab (cwd `/home/shibuka/Projetos/duh-homelab`). Há **outro operador** mexendo em `ginga-plan-0004`, `pi-harness-plan-0004`, `p-inga-plan-0018` e em `p-inga/`, `ginga/`, `pi-harness/` (merges): **não toque nesses**.

Leia antes de agir: `.ginga/handoffs/HANDOFF-2026-10-27-ondas-1-2.md`.

## Regras

- Nunca dar push.
- Nunca apagar: copiar ou mover para `_archive/` com MANIFEST.
- Sem commits.
- `opencode-go` é proibido.
- Avise no Discord ao fim de cada item, com mensagem curta: `HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<msg>"`.

## Fila

1. **Resgatar os arquivos do pi-harness fora do git** (eles correm risco de perda):
   - **copie** (não mova) `pi-harness/HANDOFF-0043.md`, `pi-harness/intents/0054-*.md`, `pi-harness/intents/0055-*.md` e `pi-harness/specs/draft-0055-*.md` para `_archive/2026-10-28-pi-harness-fora-do-git/`, preservando os subcaminhos;
   - escreva um `MANIFEST.md` com a origem, o sha256 de cada arquivo e o motivo (PLAN-0017).
2. **PLAN-0003, triagem das worktrees antigas** (só leitura): `p-inga-governed-roles`, `p-inga-run-status`, `pi-harness-ux`, `pi-harness-bench-uxjudge` e `gira-g-ux`. Para cada uma, levante:
   - branch e commits à frente/atrás da main do repo;
   - `git diff --stat` do que não está commitado;
   - do que se trata (pelos commits, diffs e tasks);
   - se conflita com o que já foi mergeado (PLAN-0005 no p-inga, PLAN-0007 no pi-harness);
   - recomendação: **mergear**, **estacionar como branch WIP** (commit WIP + remover a worktree) ou **arquivar** (patch em `_archive/` + remover), com o motivo.

   Lembre: a `gira-g-ux` bloqueia a onda 4. Saída: `.ginga/plans/PLAN-0003-worktrees-triage/triagem.md`, com uma tabela e uma seção por worktree. **Não execute** nenhuma recomendação: o dono decide.
3. **PLAN-0016 TASK-02, provar a captura de tokens do opencode** (bloqueia o resto do PLAN-0016):
   - rode `opencode run --standalone --format json -m opencode/glm-5.3-flash-free "responda só: ok"` dentro de um diretório temporário vazio;
   - descubra como obter tokens de entrada/saída/cache, custo e turnos. Opções: as linhas JSON da saída e `opencode session export <sessionID>` (o sessionID está no JSON). Teste também com 2–3 turnos ("leia o arquivo X e resuma"), para ver se soma por turno;
   - escreva `.ginga/bench/code-mode/captura-tokens.md`, com os comandos exatos, um exemplo de saída (sem segredos) e um script `.ginga/bench/code-mode/tokens.sh <sessionID>` que imprime JSON `{in,out,cache,cost,turns}`;
   - se não for possível medir, diga claramente o que falta.
4. **PLAN-0008 + INTENT-0008:** acrescente ao `.ginga/plans/PLAN-0008-*/PLAN.md` uma seção "Emenda (INTENT-0008): desbloqueio automático", com as classes de `BLOCKED:`, as TASKs de desbloqueio e os limites, exatamente como no `.ginga/intents/INTENT-0008-resolver-dependencias.md` (resuma, não invente). Também uma linha no `log.md` do PLAN-0008.

Ao terminar, mande no Discord um resumo de 3 linhas com os caminhos das saídas.

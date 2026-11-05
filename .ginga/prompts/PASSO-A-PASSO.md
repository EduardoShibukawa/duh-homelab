# Passo a passo: ondas 1 e 2 da SPEC-0001

Raiz: `/home/shibuka/Projetos/duh-homelab` (abreviada como `~duh`). PLANs: `.ginga/plans/`.

## Modelos por passo

| Passo | Ferramenta | Modelo | Effort | Como abrir |
|---|---|---|---|---|
| 1. Passada RED | Claude Code | **Sonnet 5.5** | **high** | `claude --model sonnet --effort high` |
| 2. Executar TASK | opencode | conforme o `tier` (tabela do passo 2) | padrão do modelo | `opencode run -m <modelo>` |
| 3. Judge | AGY | **`gemini-4-argon`** (`gemini-3.8-flash` se acabar a quota) | **high** | `agy --model gemini-4-argon --effort high -p "<prompt>"` (o `-p` recebe o prompt e vem por último) |
| 3. Judge reserva / 2ª opinião | Codex | **`gpt-6-luna`** | **high** | `codex exec -m gpt-6-luna -c model_reasoning_effort=high -s read-only` |
| 5. Replan | Claude Code | **Opus 5.5** | **high** (xhigh se for o 2º replan da mesma TASK) | `claude --model opus --effort high` |
| strong, 3ª opção | Claude Code | **Opus 5.5**, só com seu OK | **medium** | `claude --model opus --effort medium` |

Por que esses níveis:
- **RED em high:** os testes são o contrato das 78 TASKs, e um teste errado se propaga. Uma sessão por onda, então o custo é baixo.
- **Judge em high:** precisa caçar testes enfraquecidos e casos que só passam no teste. Roda 1 vez por PLAN.
- **Executor no padrão:** o opencode escolhe o effort pela variante do modelo (`-m provider/modelo#variante`). As variantes dos modelos do Go não foram verificadas; só use `#high` (se existir) na 3ª tentativa.
- **Opus executando em medium:** a TASK já está especificada e testada; o Opus só precisa implementar.

O padrão do seu `~/.claude/settings.json` é `opus`: na passada RED, abra com `--model sonnet` explicitamente.

## 0. Antes de começar (1 vez)

- [ ] Ver a quota: Claude `/usage`, AGY na barra de status, Codex `/status`.
- [ ] Abrir 3 panes no tuios: **claude**, **exec** (opencode) e **judge** (agy).
- [ ] Opcional: decidir a worktree `gira-g-ux` (PLAN-0003); ela só bloqueia a onda 4.

## 1. Passada RED (Claude, 1 sessão)

Na pane **claude**, abra com `claude --model sonnet --effort high` (ou `/clear`, `/model sonnet` e `/effort high`) e cole:

```
Sessão de Planner (passada RED). O dono aprovou o PLAN-0004, o PLAN-0005 e o PLAN-0007 ao pedir esta passada.

1. Leia só: .ginga/index.md, .ginga/knowledge/design/ginga-revamp/08-execucao.md (§4) e .ginga/prompts/planner-red.md.
2. Marque status: approved no PLAN.md do 0004, 0005 e 0007, e registre isso no log.md de cada um.
3. Repos novos: crie ginga/ e manda/ como irmãos (git init, 1º commit vazio "chore: init"), deixe os dois prontos para o pinga (pinga doctor / init do ledger, o que o pinga exigir) e não crie código de produção.
4. Execute o bloco do planner-red.md com {{PLANS}} = PLAN-0004 PLAN-0005 PLAN-0007, nessa ordem.
5. Regras: não implemente código de produção, não commite além do init, não leia o design 01–07 inteiro (só o que a TASK citar em "Contexto") e seja breve.
6. No fim, atualize .ginga/index.md ("Pronto para pegar" = as TASKs com prove-red RED) e responda só com a tabela PLAN / TASK / T<N> / prove-red, mais os problemas encontrados.
```

- [ ] Guarde a tabela `TASK → T<N>` que a sessão devolver.
- [ ] Se ela disser "replan necessário" em alguma TASK, resolva isso antes de executar a TASK (ver o passo 5).
- [ ] Feche a sessão. O Claude só volta no passo 5 ou na onda 3.

## 2. Executar as TASKs (opencode, pane exec)

Ordem: PLAN-0004 primeiro, seguindo o `depends_on`. Depois o 0005 (p-inga) e o 0007 (manda), que podem rodar em panes separadas.

Para cada TASK:

```bash
cd ~duh/<repo>-plan-NNNN            # worktree criada pela passada RED (ex.: ginga-plan-0004)
T=~duh/.ginga/plans/PLAN-NNNN-slug/TASK-NN-slug.md
opencode run --auto -m <MODELO> --title "PLAN-NNNN TASK-NN" -f "$T" \
  "$(sed -n '/^---8<---$/,$p' ~duh/.ginga/prompts/executor.md | tail -n +2)"
pinga verify tasks/T<N>/PLAN.md
```

**Modelo pelo `tier` da TASK** (passe para o seguinte depois de 2 falhas):

| tier | 1ª | 2ª | 3ª |
|---|---|---|---|
| free | `opencode/glm-5.3-flash-free` | `opencode-go/qwen3.8-flash` | `opencode-go/kimi-k3` |
| medium | `opencode-go/kimi-k3` | `opencode-go/glm-5.3` | `opencode-go/qwen3.8-max` |
| strong | `opencode-go/kimi-k3.1-pro` | `opencode-go/deepseek-v4-pro` | Claude (só com o seu OK) |

Nunca use `gemini-*`, `gpt-*` ou `claude-*` via opencode-go: isso preserva o judge cego.

**Depois do `pinga verify`:**
- [ ] `pass`: escreva no `log.md` do PLAN: `TASK-NN, modelo, tentativa N, pass`. Se o executor deu um learning, copie para o `LEARNINGS.md`. Siga para a próxima TASK.
- [ ] `fail`: escreva `fail + motivo` no log e rode de novo com o modelo indicado, colando o fim do `verify` depois de "Falha anterior:".
- [ ] Se aparecer `BLOCKED:`, ou houver 3 falhas pelo mesmo motivo, vá para o passo 5.

## 3. Judge do PLAN (AGY, pane judge)

Quando todas as TASKs do PLAN derem `pass`, rode o bloco de `~duh/.ginga/prompts/judge.md` com `agy --model gemini-4-argon --effort high -p "<prompt>"` (o `-p` recebe o prompt e vem por último), trocando `NNNN`, `slug` e `<repo>`.

- [ ] **`pass`**: anote o veredito no `log.md` e vá para o passo 4.
- [ ] **`fail` com severidade `simples`**: crie uma TASK de fix no mesmo PLAN e volte ao passo 2.
- [ ] **`fail` com severidade `inesperado`**: crie um novo INTENT e pare o PLAN.
- [ ] Se o AGY estiver sem quota, use a reserva: `codex exec -m gpt-6-luna -c model_reasoning_effort=high -s read-only -C . "<mesmo texto>"`.
- [ ] Nos PLANs 0005 e 0008, rode também o Codex para ter uma segunda opinião.

## 4. Fechar o PLAN

```bash
cd ~duh/<repo>-plan-NNNN && git add -A && git commit -m "PLAN-NNNN: <título>"
cd ~duh/<repo> && git merge --no-ff plan/NNNN && pinga ledger verify
```

- [ ] Mude o status do `PLAN.md` para `done`, mova o PLAN para "Concluído" no `index.md` e registre no `.ginga/log.md`.
- [ ] Remova a worktree. A branch fica: `git -C ~duh/<repo> worktree remove ../<repo>-plan-NNNN`.

## 5. Quando travar (Claude)

Abra com `claude --model opus --effort high` (ou `/clear`, `/model opus` e `/effort high`), depois cole o bloco de `~duh/.ginga/prompts/replan.md` trocando `{{PLAN}}` e `{{TASK}}`. Ele escolhe uma saída: reescrever, quebrar, investigar ou te perguntar.

## 6. Próxima onda

Quando o 0004, o 0005 e o 0007 estiverem `done`, comece a onda 3 (0006 → 0008 ‖ 0010):
- Passada RED nova, igual ao passo 1, com {{PLANS}} = PLAN-0006 PLAN-0008 PLAN-0010.
- Execução com `manda run`, que já vai existir. Se ainda não funcionar, continue manualmente com o passo 2.

## Regras de bolso

- **Uma sessão nova por TASK:** o contexto é o arquivo, não a conversa.
- **Claude só para RED e replan:** no máximo uma sessão por janela de 5h, sempre começando com `/clear`.
- **No p-inga, uma TASK de cada vez:** o `src/cli.ts` é compartilhado entre PLANs.
- **Tudo vai para o `log.md`:** é de lá que sai o FTPR por modelo, que vai calibrar a tabela de modelos.

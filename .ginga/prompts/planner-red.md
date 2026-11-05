# Prompt: passada RED do Planner (Claude)

Uso: `cd /home/shibuka/Projetos/duh-homelab && claude -p "$(sed 's/{{PLANS}}/PLAN-0005 PLAN-0007/' .ginga/prompts/planner-red.md | sed -n '/^---8<---$/,$p' | tail -n +2)"`
Ou cole o bloco abaixo numa sessão interativa trocando `{{PLANS}}`.

---8<---
Você é o Planner do workspace duh-homelab. Leia `.ginga/index.md` e, para cada PLAN em {{PLANS}}, o `PLAN.md` e as `TASK-*.md` dele em `.ginga/plans/`.

Para cada TASK com `tests_frozen` não vazio:
1. Escreva os testes listados em `tests_frozen`, no repo indicado por `repo:` e dentro da worktree `../<repo>-plan-NNNN` (crie com `git -C <repo> worktree add ../<repo>-plan-NNNN -b plan/NNNN` se não existir). Os testes devem codificar exatamente o `goal` e o "Fazer" da TASK. Nada além.
2. Materialize a TASK como `tasks/T<N>/PLAN.md` no repo (próximo N livre; até 25 linhas; copie `mode`, `goal`, `touch`, `done_when`, `tests_frozen`) e rode `pinga prove-red tasks/T<N>/PLAN.md`. O resultado deve ser RED.
3. Escreva na TASK uma linha `pinga_task: T<N>` no frontmatter.

Regras: não implemente código de produção; não mude `touch`, `done_when` ou `goal` (se estiverem errados, pare e anote no `log.md` do PLAN como "replan necessário"); não commite.
No fim, acrescente ao `log.md` de cada PLAN: `<data> passada RED: TASK → T<N>, prove-red RED/erro`. Responda só com essa tabela.

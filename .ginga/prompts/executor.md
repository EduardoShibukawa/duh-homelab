# Prompt: executor de uma TASK (OpenCode)

Uso, dentro da worktree do repo-alvo:

```bash
cd /home/shibuka/Projetos/duh-homelab/<repo>-plan-NNNN
opencode run --auto -m opencode-go/kimi-k3 --title "PLAN-NNNN TASK-NN" \
  -f /home/shibuka/Projetos/duh-homelab/.ginga/plans/PLAN-NNNN-slug/TASK-NN-slug.md \
  "$(sed -n '/^---8<---$/,$p' /home/shibuka/Projetos/duh-homelab/.ginga/prompts/executor.md | tail -n +2)"
pinga verify tasks/T<N>/PLAN.md
```

O modelo sai do tier (tabela em `08-execucao.md` §2). Retry: a mesma linha, com o modelo seguinte e o final de `pinga verify` colado após "Falha anterior:".

---8<---
Implemente a TASK do arquivo anexado, no repositório atual.

- Mexa **só** nos caminhos do `touch`. Não altere nada em `tests_frozen`: os testes estão certos, o código é que precisa passar.
- Siga "Fazer", respeite "Não fazer" e use "Contexto" como ponto de partida para ler o código.
- Pronto = o comando de `done_when` sai com 0. Rode-o antes de terminar.
- Não commite, não crie arquivos fora do `touch` e não instale dependências que não estejam no "Fazer".
- Se for impossível sem sair do `touch` ou sem mexer nos testes, pare e responda `BLOCKED: <motivo em 1 linha>`.

Termine com 3 linhas: `done_when: exit <código>`, `arquivos: <lista>`, `learning: <1 linha sobre o que surpreendeu, ou "nenhum">`.
Falha anterior (vazio na 1ª tentativa):

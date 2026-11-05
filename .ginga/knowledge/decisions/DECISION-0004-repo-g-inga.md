---
type: decision
title: O repo e o pacote do ginga se chamam g-inga; o CLI continua ginga
status: accepted
timestamp: 2026-10-27
---
## Decisão

O dono disse: "mas quero que chame g-inga".

- **Repo, pasta e pacote npm:** `g-inga`. O nome `g-inga` está livre no npm; o `ginga` é de um terceiro (middleware, v3.0.4).
- **CLI e variáveis continuam como estão:** `ginga`, `$GINGA_EVENTS` e `GINGA_*`. É o mesmo padrão da [DECISION-0001](DECISION-0001-nomes.md): repo com hífen, binário com o nome curto (`p-inga` → `pinga`, `gira-g` → `gira`).

## Repo antigo no GitHub

O GitHub não diferencia maiúsculas, então `g-inga` era o mesmo nome do `EduardoShibukawa/G-Inga` (a v1: harness `/work` para Claude Code, último push em 2026-10-18). Ele **não estava arquivado**.

Em 2026-10-27, por escolha do dono ("renomear e arquivar o antigo"):

- **Descrição:** "Arquivado: v1 do G-Ingá… sucedido por g-inga + manda + p-inga".
- **Renomeado:** para `g-inga-v1`.
- **Arquivado:** é reversível, e todas as branches foram preservadas.
- **Cópia local:** `Projetos/_preservacao/G-Inga-archived`, sincronizada com a main. O remote foi atualizado para `g-inga-v1`.
- **Redirecionamento:** até o repo novo ser criado, `github.com/EduardoShibukawa/g-inga` redireciona para o `g-inga-v1`. Quando o novo for criado, o redirect some.

## Consequências

- **Renomeação local** (`ginga/` → `g-inga/`, `name` no `package.json`, docs que citam o repo): entra no INTENT-0007, **depois** de o PLAN-0004 fechar, porque a worktree `ginga-plan-0004` está ativa. Os textos sobre o CLI `ginga` não mudam.
- **Criar o repo `g-inga` no GitHub e dar push:** só quando o dono pedir para publicar.

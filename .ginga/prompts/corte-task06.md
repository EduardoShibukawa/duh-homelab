Você é a sessão de corte do PLAN-0023 TASK-06 (cwd `/home/shibuka/Projetos/duh-homelab`). Objetivo: trocar a infra `.sh` da `.ginga/bin` pelo `ginga serve` (supervisor) + `manda lane`, sem perder nada e sem quebrar a autonomia. Leia antes: `.ginga/plans/PLAN-0023-vigia-e-supervisor/PLAN.md`, `TASK-06-*.md` e o checklist no `log.md` (linha "checklist do corte").

## Regras (do dono, inegociáveis)
- Nunca `git push`. Nunca apagar: arquive em `.ginga/_archive/<data>-<nome>/` com `MANIFEST.md`. Commits com caminhos explícitos (`git add -A`/`.` é bloqueado).
- Não mexa no `pi-harness/` nem em `~/.pi`. Não altere `tests_frozen` alheio.
- Nunca rode `merge-gate.sh`, `judge-run.sh`, `manda merge`/`judge` (você é um agente LLM; eles recusam com exit 30 — é o esperado). Mudança de código em repo = TASK + RED + `dispatch-task.sh` + `pinga verify` + `ready/<repo>.json`; o judge e o gate rodam depois, fora de você.
- Nunca `pkill -f` com padrão; mate por PID.
- Avisos: `.ginga/bin/notify.sh "<texto>"` só em etapa ou crítico.
- O dono autorizou explicitamente: "ginga e manda poderia fazer isso sozinho, por um ginga install e manda install" — instalar os links em `~/.local/bin` e habilitar o `ginga-supervisor.service` pelo `ginga install` está coberto.

## Passos (cada um verificado antes do próximo; registre cada um no `log.md` do PLAN-0023)
1. Pré-condição: nenhum `- [ ]` em `.ginga/prompts/backlog-*.md`, `ls .ginga/plans/*/ready/*.json` vazio e `systemctl --user list-units 'ginga-lane-*' --state=active` vazio. Se não, pare e registre.
2. `ginga install` e `manda install` (links em `~/.local/bin`); confirme `command -v ginga manda` e `ginga --version`. Se `~/.local/bin` não estiver no PATH do systemd do usuário, use o caminho absoluto na unit.
3. `.ginga/project.toml` com `[supervisor]`: lanes ginga, p-inga, manda → `manda lane <repo>`; models do operador e do executor iguais aos de `.ginga/handoffs/lane.env` (operador `claude/claude-sonnet-5-5`, executor `opencode/qwen3.8-flash` com `ALLOW_PAID=1`, `SPEND_FILE`, `TOTAL_CAP`) e, quando a cota free voltar, glm-free primeiro. Se o `manda lane` não suportar operador `claude/*` ou essas variáveis, NÃO corte: crie a TASK no backlog-manda (`.ginga/prompts/backlog-manda.md`) e pare no passo 3.
4. Sombra: rode `ginga serve` em primeiro plano por 2 ticks (ou `ginga watch` em modo dry-run) ao lado do timer `ginga-vigia`; compare os alertas para o mesmo estado. Divergência → registre, crie TASK, pare.
5. Troca: `ginga install` habilita o `ginga-supervisor.service`; confirme `systemctl --user is-active ginga-supervisor`. Só então pare e desabilite o timer `ginga-vigia` (guarde a unit em `_archive`). Se o supervisor não ficar ativo em 2 min, reverta: reabilite o timer e pare.
6. Arquive `.ginga/bin/{lane,vigia,pipeline,autoloop,judge-run,merge-gate}.sh` em `.ginga/_archive/<data>-corte-task06/` com MANIFEST (o `notify.sh`, `dispatch-task.sh` e `sandbox-*` ficam, a menos que o ginga já os substitua com teste). Atualize `.ginga/index.md`.
7. Marque a TASK-06 no `log.md` como pronta para o judge e grave `.ginga/plans/PLAN-0023-vigia-e-supervisor/ready/ginga.json` `{"branch":"main","by":"corte","at":"<iso>"}` SOMENTE se houver mudança de código em branch; senão, só o log.
8. `notify.sh` com o resumo do corte (o que mudou, como reverter).

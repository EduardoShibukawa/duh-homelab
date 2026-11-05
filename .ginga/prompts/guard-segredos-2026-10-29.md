Você é o autor da TASK do **guard de segredos** das lanes do workspace /home/shibuka/Projetos/duh-homelab (sessão nova, 2026-10-29). Português do Brasil. O dono conversa com você por `claude attach`: trabalhe, mas pare e pergunte quando a decisão for dele.

## Objetivo

Hoje nada impede um executor/operador de ler `.env`, `auth.json` ou chaves e mandar o conteúdo ao provider no prompt (no OpenRouter free isso pode virar dataset público). O dono quer um **hook que bloqueia isso antes da tool rodar**, nos runtimes das lanes. Escreva o PLAN/TASK (INTENT → SPEC → PLAN → TASK da convenção do workspace, ver `.ginga/index.md` e `.ginga/knowledge/design/ginga-revamp/04-artefatos.md`) e o desenho; **não instale nem edite nada em `~/.pi`, `~/.config/opencode`, `~/.hermes` diretamente**: toda mudança passa pelo harness (TASK + RED + executor + verificação + judge), regra do dono.

## Leia antes

`.ginga/knowledge/research/skills-e-hooks.md` (tabela de hooks por runtime: Pi `pi.on("tool_call")` bloqueia com throw, opencode plugin `tool.execute.before`, Hermes plugin `pre_tool_call` retornando `{"action":"block"}`; o `bashRefusal` antigo do pi-harness em `claude-plugin/hooks/policy.ts` bloqueava `git add -A`, `--no-verify`, push force, `.git`/`.env`, mas morreu com o pi-harness), `.ginga/bin/lane.sh` (o Pi recebe `--append-system-prompt "lane:$name"`), `.ginga/prompts/executor.md`, `~/.pi/agent/extensions/tuios-agent-state.ts` e `~/.config/opencode/plugins/` (exemplos reais de extensão/plugin instalados), `.ginga/models/ROUTING.md`, `.ginga/handoffs/lane.env`. Memória do dono: [Tudo pelo harness] e [Harness decide o coberto].

## O que fazer

1. **Lista de bloqueio única** (arquivo de dados compartilhado pelos 3 runtimes, para não divergir): caminhos (`.env*`, `auth.json`, `~/.pi/`, `~/.hermes/`, `~/.config/`, `~/.ssh/`, `~/.local/share/opencode/`, `~/.aws`, `*.pem`, `*.key`), comandos (`env`, `printenv`, `set`, `cat`/`head`/`rg` etc. sobre esses caminhos, `curl` com `--data @` desses arquivos) e padrões de conteúdo (formatos de chave: `sk-`, `nvapi-`, `ghp_`, JWT, `AKIA`). Diga o que **não** dá para bloquear por regra (ex.: o modelo montar o caminho dinamicamente em shell) e o que isso exige (HOME restrito, ambiente sem chaves).
2. **Escopo:** ativo só em sessões de lane, não nas sessões interativas do dono. Descubra o marcador por runtime (Pi: `lane:` no system prompt; opencode e Hermes: variável de ambiente que o `lane.sh`/`dispatch-task.sh` já possa exportar, ou um marcador novo). Se exigir mudar `lane.sh`, isso é parte da TASK, **não** faça agora.
3. **Um hook por runtime** (Pi, opencode, Hermes), escrito como parte da TASK, com **teste RED**: `cat .env` e `cat ~/.pi/agent/auth.json` devem ser barrados; `cat README.md` não. Para cada runtime diga onde o arquivo ficaria no repo (fonte) e como é projetado/instalado (symlink ou cópia) sem edição manual do `HOME`.
4. **Varredor de saída** (opcional na TASK): rodar sobre os logs de lane antes de qualquer publicação e avisar no Discord se achar padrão de chave.
5. Entregue `.ginga/knowledge/research/guard-segredos-2026-10-29.md` (desenho, lista, riscos, o que o guard não cobre) e os arquivos PLAN/TASK nos locais da convenção do workspace, sem executá-los. Liste o que precisa do OK do dono antes de rodar.

## Regras

- Não crie conta, não gere chave, não ponha cartão, não ligue crédito pago.
- Não altere `handoffs/lane.env`, scripts das lanes, `~/.pi`, `~/.config`, `~/.hermes`; só proponha. Não monitore as lanes, não rode executores reais, não commite nos repos.
- Teste só com arquivos sintéticos (um `.env` falso num `mktemp -d`), nunca com as chaves reais do dono.

Ao terminar a 1ª rodada (antes de esperar o dono), avise no Discord em 2 linhas:
`HERMES_HOME=/home/shibuka/.hermes/profiles/pinga hermes send -t discord "<resumo: desenho do guard, TASK criada, o que precisa do dono>"`

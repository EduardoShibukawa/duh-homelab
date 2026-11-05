# LESSONS — duh-homelab (camada orquestrador)

> Memória DREAMS do workspace (SPEC 0010, D6). Sessões de orquestração multi-repo
> iniciadas nesta raiz consolidam aqui lições de **ambiente e processo** — lições de
> produto pertencem ao `LESSONS.md`/specs de cada repo. Âncora por presença: este
> arquivo torna a raiz host legítimo de `dreams/logs/`. Manter ≤ 200 linhas.

## Ambiente / shell

- **L-1 (2026-10-20, sessão 0008):** `pkill -f "llama-server -m ..."` casa com a
  própria linha de comando do shell que o dispara (o wrapper bash contém o padrão)
  e mata a si mesmo (exit 143). Usar `pkill -x llama-server` ou padrão que não
  apareça no próprio comando; em scripts, separar o padrão de um arquivo.
  **Reforço (2026-10-21, INTENT 0021):** o `exit 143` também aparece quando o
  `pkill -f <padrão>` casa com o **próprio `bash -c`** que executa o comando —
  e aí o comando inteiro morre *no meio*, deixando o driver em estado parcial
  (a worktree do worker ficou criada e o `git worktree remove` nunca rodou).
  Regra prática: **matar por PID** (`kill $(pgrep -f 'padrão' | grep -v $$)`),
  nunca por padrão; e o driver que cria worktree deve limpá-la no `finally`.
- **L-2 (2026-10-20):** `python3` do sistema NÃO tem pytest. Rodar testes via
  `mise exec -- pytest ...` ou `~/.local/bin/pytest` (pytest 9.1.1). Um
  `python3 -m pytest` falho no meio de pipeline de diagnóstico é falso-positivo
  clássico de gravação DREAMS (ver SPEC 0010 C2).
- **L-3 (2026-10-20, llm-bench):** Ornith-1.5-9B-Q4 (~5,8 GB) não cabe nos 4 GB da
  GTX 1650 com KV em fp — servir híbrido com `--n-gpu-layers 20` (-fa on,
  -ctk/-ctv q8_0). 24 deu OOM no cudaMalloc; 20 healthy. Qwen3.5-4B cabe inteiro.

## Processo / git / SDLC

- **L-4 (2026-10-20, gira-g):** o validator (`tools/validate/validate.js`) audita a
  HISTÓRIA: spec é criada como draft no nome FINAL e aprovada em commit SEPARADO
  (rename de spec = "spec deletada" = fail §4.3/§7.1); task nos estados
  completed/verified/accepted exige linha de verificação com o ID de CADA AC e ao
  menos uma linha de baseline `B`; o Ref das linhas deve bater com `verified_at`.
  Racha-se: commit draft → commit approve(+hash do corpo) → commits por task.
- **L-5 (2026-10-20, pi-harness):** workers paralelos compartilham a árvore da
  main — staging com caminhos explícitos sempre; um `git add -A` alheio pode
  absorver trabalho em andamento (acontecido de fato: bridge 0010-absorvido em
  commit de worker com mensagem própria).
- **L-6 (2026-10-20, gira-g):** main protegida no GitHub recusa push direto E
  `gh pr merge` sem CI verde — fluxo canônico: branch `sync/*` → PR →
  `gh pr checks --watch` → merge → tag lightweight `vX.Y.Z` (dispara goreleaser).

## Bench (pi-harness)

- **L-7 (2026-10-20):** rebase de `bench/base-stats` na main injeta as extensões
  (.pi) em TODAS as camadas do bench; o baseline deixa de ser cego e as
  referências disparam (+44k tokens). O isolamento por camada via `--exclude-tools`
  no runner é obrigatório ao mudar a base do bench.
- **L-8 (2026-10-21, INTENT 0021):** dois **drivers** do mesmo repo com o mesmo
  nome de sessão tmux (`pi-autoflow-<spec>`) se matam: o `newsess` de um faz
  `kill-session` do nome **compartilhado**, derrubando a run do outro — o sintoma
  é um pipeline que morre em 30s sem task executada. Driver precisa de **nome de
  sessão único por instância** (suffix de PID) **e** arquivo de PID/lock, para
  que duas instâncias do mesmo driver convivam sem se sabotar.
- **L-9 (2026-10-21, INTENT 0021):** rodar o pipeline de uma spec **enquanto
  outra spec está em voo** é possível (worktrees isoladas por task), mas o
  **UX Gate/repair loop é global**: ele julga todas as superfícies e o repair
  pode editar arquivos de outra spec — colidindo com a sessão dona. Regra
  operacional: antes de disparar um pipeline, conferir `specs/.active` e as
  sessões tmux irmãs; e o gate precisa de escopo por spec antes de o repair
  rodar em modo automático.

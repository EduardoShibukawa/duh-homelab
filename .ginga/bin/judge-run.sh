#!/usr/bin/env bash
# uso: judge-run.sh <PLAN-dir> <repo> <branch>  -> grava <PLAN-dir>/judge/<repo>.json (último JSON do judge)
# Processo próprio: o judge é Claude (sonnet-5-5) read-only, e o operador LLM não chama nem lê o merge.
# 2026-10-29 (dono: ".use claude como judge"): primário = claude -p; Codex segue sem cota até 25/11/2026.
# Cada item traz "regression": true quando algo que funcionava na main deixa de funcionar.
set -u
# separação de processos: recusa se chamado de dentro de um operador LLM (ancestral opencode/pi/claude/codex run)
a=$PPID; while [ "${a:-1}" -gt 1 ]; do
  mapfile -d '' -t av < /proc/$a/cmdline 2>/dev/null; b0=$(basename "${av[0]:-}"); i=1; [ "$b0" = timeout ] && { while [[ "${av[$i]:-}" == -* || "${av[$i]:-}" =~ ^[0-9]+$ ]]; do i=$((i+1)); done; b0=$(basename "${av[$i]:-}"); i=$((i+1)); }
  case "$b0:${av[$i]:-}" in *opencode*:run|pi:*|claude:-p|codex:exec) echo "{\"error\":\"recusado: chamado de dentro de um agente LLM (pid $a: $b0); só o pipeline.sh pode\"}"; exit 30;; esac
  a=$(awk '{print $4}' /proc/$a/stat 2>/dev/null); done
DUH=/home/shibuka/Projetos/duh-homelab
P=$(readlink -f "$1"); repo=$2; br=${3:?branch}
wt=$(git -C "$DUH/$repo" worktree list --porcelain | awk -v b="refs/heads/$br" '/^worktree/{w=$2} $0=="branch "b{print w}')
[ -n "$wt" ] || { echo "{\"error\":\"sem worktree para $br em $repo\"}"; exit 2; }
cur=$(git -C "$wt" rev-parse HEAD)
# um veredito por HEAD (sem "judge shopping"): para refazer, só com FORCE_REJUDGE=1, e fica no log do PLAN
if [ -f "$P/judge/$repo.json" ] && [ "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["head"])' "$P/judge/$repo.json")" = "$cur" ]; then
  [ "${FORCE_REJUDGE:-0}" = 1 ] && echo "- $(date -Iseconds) judge-run $repo: FORCE_REJUDGE no HEAD $cur" >> "$P/log.md" || { echo "{\"judge\":\"$P/judge/$repo.json\",\"head\":\"$cur\",\"reused\":true}"; exit 0; }
fi
mkdir -p "$P/judge"; ts=$(date +%Y%m%dT%H%M%S); log="$P/judge/$repo-$ts.log"
prompt="Você é o judge cego do PLAN em $P/PLAN.md (leia também $P/TASK-*.md). Para decidir se cada AC/TASK está cumprido, avalie o ESTADO do código em HEAD (o repo inteiro): partes do PLAN podem ter sido mergeadas antes e não aparecer no diff, e isso NÃO é falha. Para decidir \"regression\", use o diff \`git diff main...HEAD\`.
Considere SÓ as TASKs cujo frontmatter tem \`repo: $repo\` (as de outros repos são julgadas no diff do repo delas; não as reprove aqui) e os ACs que dependem delas. Para cada um desses, um item. Marque \"regression\": true apenas se algo que funcionava na main (teste, AC, comportamento) passa a falhar com este diff; achado novo ou melhoria é regression false. Remover ou mudar um comportamento que a própria TASK/AC pede para remover ou mudar NÃO é regressão.
Última linha da resposta, exatamente um JSON numa linha só:
{\"verdict\":\"pass|fail\",\"items\":[{\"ref\":\"AC|TASK-NN\",\"ok\":true,\"regression\":false,\"evidence\":\"arquivo:linha ...\",\"severity\":\"simples|grave\"}],\"summary\":\"...\"}"
# judge primário: Claude Code read-only (dono: ".use claude como judge"). Prompt é o 1º argumento porque
# --disallowedTools é variádico e engoliria o prompt se viesse antes. Dois cadeados: plan mode + Edit/Write proibidos.
# A guarda compara só arquivos rastreados + HEAD: __pycache__/*.pyc nasce de import de python do próprio repo
# (ex.: contrib/hermes-plugin) e não é escrita do judge — em 29/10 20:40 isso descartou um veredito bom.
st0=$(git -C "$wt" status --porcelain --untracked-files=no; git -C "$wt" rev-parse HEAD)
(cd "$wt" && timeout 1200 claude -p "$prompt" --permission-mode plan --disallowedTools "Edit,Write,NotebookEdit" < /dev/null) > "$log" 2>&1
[ "$st0" = "$(git -C "$wt" status --porcelain --untracked-files=no; git -C "$wt" rev-parse HEAD)" ] || { echo "{\"error\":\"judge claude alterou a worktree; veredito descartado\",\"log\":\"$log\"}"; exit 3; }
# fallback (2026-10-29, Codex sem cota até 25/11): se o claude estourar cota/limite, o mesmo gpt-6-luna pelo Zen pago,
# agente plan (edit negado) + --auto (só leitura/bash); família OpenAI continua distinta do executor (qwen/glm/iceman).
if grep -qiE "usage limit|rate.?limit|quota" "$log" && ! grep -q '{"verdict":"\(pass\|fail\)"' "$log"; then
  st0=$(git -C "$wt" status --porcelain; git -C "$wt" rev-parse HEAD)
  echo "--- fallback opencode/gpt-6-luna (Codex sem cota) ---" >> "$log"
  (cd "$wt" && timeout 1200 opencode run --standalone --agent plan --auto -m opencode/gpt-6-luna --title "judge-$repo-$ts" "$prompt" < /dev/null) >> "$log" 2>&1
  [ "$st0" = "$(git -C "$wt" status --porcelain; git -C "$wt" rev-parse HEAD)" ] || { echo "{\"error\":\"judge fallback alterou a worktree; veredito descartado\",\"log\":\"$log\"}"; exit 3; }
  echo "- $(date -Iseconds) judge-run $repo: Codex sem cota, fallback opencode/gpt-6-luna (Zen)" >> "$P/log.md"
fi
json=$(grep -o '{"verdict".*' "$log" | tail -1)
echo "$json" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["verdict"] in("pass","fail") and all("regression" in i for i in d["items"])' 2>/dev/null \
  || { echo "{\"error\":\"judge sem JSON válido\",\"log\":\"$log\"}"; exit 3; }
head=$(git -C "$wt" rev-parse HEAD)
printf '{"head":"%s","log":"%s","judge":%s}\n' "$head" "$log" "$json" > "$P/judge/$repo.json"
echo "{\"judge\":\"$P/judge/$repo.json\",\"head\":\"$(git -C "$wt" rev-parse HEAD)\"}"

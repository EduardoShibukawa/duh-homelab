#!/usr/bin/env bash
# uso: merge-gate.sh <PLAN-dir> <repo> <branch>  -> 1 linha JSON; exit 0 = mergeado
# Gate determinístico, sem LLM. Mergeia só se todas as condições valerem:
#   10 sem veredito do judge, ou veredito de outro HEAD | 11 veredito fail, item ok=false ou regression=true
#   12 TASK do diff sem receipt done no pinga          | 13 a branch tem falha de teste que a main não tem
#   14 depois do merge, a main ganhou falha nova -> git revert -m 1 automático | 16 o revert falhou (CRÍTICO) | 17 veredito sem item (passe vazio)
set -u
# separação de processos: recusa se chamado de dentro de um operador LLM (ancestral opencode/pi/claude/codex run)
a=$PPID; while [ "${a:-1}" -gt 1 ]; do
  mapfile -d '' -t av < /proc/$a/cmdline 2>/dev/null; b0=$(basename "${av[0]:-}"); i=1; [ "$b0" = timeout ] && { while [[ "${av[$i]:-}" == -* || "${av[$i]:-}" =~ ^[0-9]+$ ]]; do i=$((i+1)); done; b0=$(basename "${av[$i]:-}"); i=$((i+1)); }
  case "$b0:${av[$i]:-}" in *opencode*:run|pi:*|claude:-p|codex:exec) echo "{\"error\":\"recusado: chamado de dentro de um agente LLM (pid $a: $b0); só o pipeline.sh pode\"}"; exit 30;; esac
  a=$(awk '{print $4}' /proc/$a/stat 2>/dev/null); done
DUH=/home/shibuka/Projetos/duh-homelab
P=$(readlink -f "$1"); repo=$2; br=$3; R=$DUH/$repo; V=$P/judge/$repo.json
rep(){ d=$DUH/.ginga/handoffs/REPORT-$(date +%F).d; mkdir -p "$d"; { echo; echo "### $(date +%H:%M) $(basename "$P") · $repo · $br · gate $1"; echo "- motivo: $2"
  [ -f "$V" ] && python3 -c '
import json,sys
d=json.load(open(sys.argv[1])); j=d["judge"]; print("- judge: %s no HEAD %s (log %s)" % (j["verdict"], d["head"][:8], d.get("log","?")))
for i in sorted(j["items"], key=lambda i: i["ok"]): print("  - %s [%s]%s %s" % ("ok" if i["ok"] else "FALHA", i["ref"], " REGRESSÃO" if i.get("regression") else "", i["evidence"][:300]))
print("- resumo do judge: " + j.get("summary","")[:400])' "$V"; } >> "$d/judge-e-gate.md"; }
out(){ rep "$1" "$2"; echo "{\"plan\":\"$(basename "$P")\",\"repo\":\"$repo\",\"branch\":\"$br\",\"gate\":$1,\"why\":\"$2\"}"; echo "- $(date -Iseconds) merge-gate $repo $br: exit $1 ($2)" >> "$P/log.md"; exit "$1"; }
# repo Go (gira-g): go test via mise; linhas "--- FAIL: X" e "FAIL pkg" (inclui build failed), sem o tempo
fails(){ if [ -f "$1/go.mod" ]; then (cd "$1" && mise exec -- go test ./... 2>&1) | grep -E '^(--- FAIL|FAIL)' | sed -E 's/ \([0-9.]+s\)$//; s/\t[0-9.]+s$//' | sort -u
  else (cd "$1" && bun test 2>&1) | grep '^(fail)' | sed -E 's/ \[[0-9.]+m?s\]$//' | sort -u; fi; }
wt=$(git -C "$R" worktree list --porcelain | awk -v b="refs/heads/$br" '/^worktree/{w=$2} $0=="branch "b{print w}')
[ -n "$wt" ] || out 2 "sem worktree para $br"
[ "$(git -C "$R" rev-parse --abbrev-ref HEAD)" = main ] || out 2 "$repo nao esta na main"
[ -z "$(git -C "$R" status --porcelain --untracked-files=no)" ] || out 2 "main com mudancas nao commitadas"
head=$(git -C "$wt" rev-parse HEAD)
[ -f "$V" ] || out 10 "sem veredito em $V"
[ "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["head"])' "$V")" = "$head" ] || out 10 "veredito de outro HEAD; rode judge-run.sh"
nit=$(python3 -c 'import json,sys;print(len(json.load(open(sys.argv[1]))["judge"]["items"]))' "$V")
[ "$nit" -gt 0 ] || out 17 "veredito sem nenhum item para $repo (passe vazio): falta TASK com repo: $repo no PLAN"
# 2026-10-29: o gate ignorava o veredito e mergeava `fail` com 0 regressões. Agora exige verdict=pass E todo item ok.
bad=$(python3 -c 'import json,sys
j=json.load(open(sys.argv[1]))["judge"]
print(j["verdict"] if j["verdict"]!="pass" else " ".join(i["ref"] for i in j["items"] if not i.get("ok")))' "$V")
[ -z "$bad" ] || out 11 "judge reprovou ($bad)"
reg=$(python3 -c 'import json,sys;print(sum(1 for i in json.load(open(sys.argv[1]))["judge"]["items"] if i.get("regression")))' "$V")
[ "$reg" = 0 ] || out 11 "$reg item(ns) com regression=true"
tasks=$(git -C "$wt" diff --name-only main...HEAD | sed -nE 's#^tasks/(T[0-9]+)/.*#\1#p' | sort -u)
pending=$(pinga queue --json --root "$wt" | python3 -c 'import json,sys; want=set(sys.argv[1].split()); print(" ".join(t["task"] for t in json.load(sys.stdin)["tasks"] if t["task"] in want and t["state"]!="done"))' "$tasks")
[ -z "$pending" ] || out 12 "sem receipt done: $pending"
base=$(mktemp); new=$(mktemp); fails "$R" > "$base"; fails "$wt" > "$new"
extra=$(comm -13 "$base" "$new" | head -3 | tr '\n"' ' _')
[ -z "$extra" ] || out 13 "falha nova na branch: $extra"
MERGE_GATE=1 git -C "$R" merge --no-ff -q -m "Merge $(basename "$P") ($br): merge-gate (judge sem regressao, receipts done, suite sem falha nova)" "$br" || { git -C "$R" merge --abort; out 2 "conflito no merge"; }
fails "$R" > "$new"; extra=$(comm -13 "$base" "$new" | head -3 | tr '\n"' ' _')
if [ -n "$extra" ]; then MERGE_GATE=1 git -C "$R" revert -m 1 --no-edit HEAD >/dev/null 2>&1 || out 16 "main ganhou falha apos merge e o REVERT FALHOU (CRÍTICO): $extra"; out 14 "main ganhou falha apos merge, revertido: $extra"; fi
pinga ledger verify >/dev/null 2>&1 || out 15 "merge feito, mas pinga ledger verify falhou"
out 0 "mergeado $(git -C "$R" rev-parse --short HEAD)"

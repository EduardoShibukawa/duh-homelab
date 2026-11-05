#!/usr/bin/env bash
# Status compacto das ondas em andamento (sem LLM). Uso: .ginga/bin/status.sh
cd "$(dirname "$0")/.." || exit 1
L=OPERATOR.lock
if [ -f $L ] && kill -0 "$(head -1 $L)" 2>/dev/null; then echo "🔒 operador ativo: $(sed -n 2p $L)"; else echo "🔓 sem operador ativo"; fi
for d in plans/PLAN-*/; do
  st=$(grep -m1 '^status:' $d/PLAN.md | cut -d' ' -f2)
  case "$st" in approved|done|blocked) ;; *) continue;; esac
  n=$(ls $d/TASK-*.md 2>/dev/null | wc -l)
  ok=0; bad=""
  for t in $d/TASK-*.md; do
    id=$(basename $t .md | cut -c1-7)
    last=$(grep -E "^[0-9-]+ $id " $d/log.md 2>/dev/null | tail -1)
    case "$last" in *" pass"*) ok=$((ok+1));; *blocked*|*fail*) bad="$bad $id";; esac
  done
  j=$(grep -i 'judge' $d/log.md | tail -1 | cut -c1-90)
  printf '%s [%s] %s/%s pass%s\n   judge: %s\n' "$(basename $d)" "$st" $ok $n "${bad:+ | pendentes:$bad}" "${j:-—}"
done
p=$(pgrep -fc 'dispatch-task.sh|run-plan.sh|agy |codex exec|opencode run' 2>/dev/null); echo "processos de execução vivos: ${p:-0}"

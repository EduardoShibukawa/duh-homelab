#!/usr/bin/env bash
# Vigia independente do Claude (timer systemd do usuário, a cada 10 min). Regras determinísticas (SPEC-0003):
#   lane morta com backlog/ready pendente -> relança a lane e avisa
#   lane viva, mas sem evento há mais de 60 min -> avisa (provável travamento que o vigia da lane não pegou)
#   fila do Discord com avisos presos -> tenta reenviar (o notify.sh descarrega a fila no próximo sucesso)
set -u
G=/home/shibuka/Projetos/duh-homelab/.ginga; EV=$G/handoffs/lanes.events
cnt(){ local n; n=$(grep -c '^- \[ \]' "$1" 2>/dev/null); echo "${n:-0}"; }
say(){ "$G/bin/notify.sh" "[vigia] $1" >> "$EV" 2>&1; }
for r in ginga p-inga manda gira-g; do
  pend=$(( $(cnt "$G/prompts/backlog-$r.md") + $(ls "$G"/plans/*/ready/$r.json 2>/dev/null | wc -l) ))
  if ! systemctl --user is-active -q "ginga-lane-$r"; then
    [ "$pend" -gt 0 ] || continue
    [ -n "$(find "$G/handoffs/.free-esgotado" -mmin -60 2>/dev/null)" ] && continue  # free esgotado: espera 1 h
    systemctl --user reset-failed "ginga-lane-$r" 2>/dev/null
    systemd-run --user --unit="ginga-lane-$r" --collect --working-directory="$G" --setenv=PATH="$PATH" --setenv=HOME="$HOME" $(sed "s/^/--setenv=/" "$G/handoffs/lane.env" 2>/dev/null) \
      -p StandardOutput=append:"$G/handoffs/lane-$r.out" -p StandardError=append:"$G/handoffs/lane-$r.out" "$G/bin/lane.sh" "$r" 6 >/dev/null 2>&1 \
      && say "lane $r estava parada com $pend pendência(s): relançada" || say "CRÍTICO: lane $r parada e falhou ao relançar"
  fi
done
# atividade = o arquivo mais recente entre eventos e logs das lanes (rodada longa escreve só no log; 2026-10-29)
last=$(ls -t "$EV" "$G"/handoffs/lane-*.log 2>/dev/null | head -1); age=$(( $(date +%s) - $(stat -c %Y "$last" 2>/dev/null || echo 0) ))
if [ $age -gt 3600 ] && systemctl --user list-units 'ginga-lane-*' --state=active --no-legend | grep -q .; then
  say "ATENÇÃO: lanes ativas, mas sem evento há $((age/60)) min"
fi
[ -s "$G/handoffs/discord-spool.txt" ] && "$G/bin/notify.sh" "[vigia] reenviando avisos presos" >/dev/null 2>&1
# goal_reached: sem pendência em nenhum backlog, sem ready e sem lane ativa -> UM aviso ao dono (flag por dia)
tot=0; for r in ginga p-inga manda gira-g; do tot=$(( tot + $(cnt "$G/prompts/backlog-$r.md") )); done
tot=$(( tot + $(ls "$G"/plans/*/ready/*.json 2>/dev/null | wc -l) ))
FL=$G/handoffs/.tudo-pronto-$(date +%F)
if [ $tot -eq 0 ] && ! systemctl --user list-units 'ginga-lane-*' --state=active --no-legend | grep -q . && [ ! -f "$FL" ]; then
  mains=$(for r in manda p-inga ginga; do printf '%s %s; ' "$r" "$(git -C "$G/../$r" log -1 --format=%h main)"; done)
  "$G/bin/notify.sh" "✅ TUDO PRONTO: backlogs vazios, nada aguardando gate, lanes paradas. mains: $mains Report: .ginga/handoffs/REPORT-$(date +%F).md + REPORT-$(date +%F).d/ (judge-e-gate.md, decisoes.md)" >> "$EV" 2>&1 && touch "$FL"
fi
exit 0

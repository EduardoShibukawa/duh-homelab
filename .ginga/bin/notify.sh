#!/usr/bin/env bash
# uso: notify.sh "<msg>"  -> Discord via hermes, com 3 tentativas; se falhar, guarda na fila e reenvia no próximo sucesso
SP=/home/shibuka/Projetos/duh-homelab/.ginga/handoffs/discord-spool.txt
send(){ HERMES_HOME=/home/shibuka/.hermes/profiles/pinga timeout 30 hermes send -t discord "$1" 2>&1 | grep -q '^Sent'; }
msg="[$(date +%H:%M)] $1"; echo "$msg"
for k in 1 2 3; do
  if send "$msg"; then
    if [ -s "$SP" ]; then send "(fila de avisos não entregues) $(tail -c 1800 "$SP")" && : > "$SP"; fi
    exit 0
  fi
  sleep $((k*10))
done
echo "$msg" >> "$SP"; exit 1

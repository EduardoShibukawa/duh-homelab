#!/usr/bin/env bash
# sandbox-run.sh — fase 1 do sandbox do executor (INTENT-0006 / PLAN-0007)
# uso: sandbox-run.sh <WORKTREE> <RUNDIR> <FROZEN_CSV> <cmd...>
#   FROZEN_CSV = paths (relativos à worktree, separados por ":") que entram READ-ONLY
# Roda <cmd...> dentro de bubblewrap:
#   - /usr, /etc/{resolv.conf,ssl,ca-certificates,passwd,hosts,nsswitch.conf} read-only
#   - HOME falso e gravável ($RUNDIR/home) — ~/.hermes, ~/.ssh, ~/.codex, ~/Projetos NÃO existem
#   - worktree gravável; tests_frozen do TASK em ro-bind por cima; .git mascarado com /dev/null
#   - rede COMPARTILHADA (--share-net): a sandbox alcança 127.0.0.1 do host, inclusive o
#     serviço do opencode na 49374. Isto é fase 1; fase 2 troca por --unshare-net + proxy.
# Fail-closed: sem bwrap, ou se o preflight da sandbox falhar, sai 97 (o chamador deve
# tratar como tentativa falha com reason sandbox_unavailable — NUNCA cair para execução nua).
set -u
WT=$(readlink -f "$1"); RUNDIR=$(readlink -f "$2"); FROZEN=${3:-}; shift 3
[ -d "$WT" ] || { echo "sandbox-run: worktree inexistente: $WT" >&2; exit 97; }
command -v bwrap >/dev/null || { echo "sandbox-run: bwrap ausente (fail-closed)" >&2; exit 97; }
mkdir -p "$RUNDIR/home" "$RUNDIR/home/.local/share" "$RUNDIR/home/.config" "$RUNDIR/home/.cache"
M=$HOME/.local/share/mise/installs
ver(){ # $1=produto -> diretório de instalação com o binário utilizável
  local d; for d in $(ls -d "$M/$1"/*/ 2>/dev/null | sort -V -r); do
    case "$(basename "$d")" in global|latest|2|2.0|2.1|26|26.8|latest/) continue;; esac
    [ -x "$d/node_modules/.bin/opencode" ] || [ -x "$d/bin/node" ] && { echo "${d%/}"; return; }
  done; }
OC=$(ver opencode); ND=$(ver node)
[ -n "$OC" ] && [ -n "$ND" ] || { echo "sandbox-run: runtimes mise do opencode/node não encontrados" >&2; exit 97; }
A=(--unshare-all --share-net --die-with-parent --new-session
   --ro-bind /usr /usr --symlink usr/bin /bin --symlink usr/lib /lib --symlink usr/lib /lib64
   --ro-bind /etc/resolv.conf /etc/resolv.conf --ro-bind /etc/ssl /etc/ssl
   --ro-bind /etc/ca-certificates /etc/ca-certificates --ro-bind /etc/passwd /etc/passwd
   --ro-bind /etc/hosts /etc/hosts --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf
   --proc /proc --dev /dev --tmpfs /tmp)
# HOME primeiro: o bind da worktree vem depois, senão o HOME cobre ~/Projetos
A+=(--bind "$RUNDIR/home" /home/shibuka --bind "$WT" "$WT")
IFS=':' read -r -a FZ <<<"$FROZEN"
for f in "${FZ[@]:-}"; do [ -n "$f" ] && [ -e "$WT/$f" ] && A+=(--ro-bind "$WT/$f" "$WT/$f"); done
[ -e "$WT/.git" ] && A+=(--ro-bind /dev/null "$WT/.git")
# credencial de serviço: só service.json (senha do serviço de background do opencode).
# Sem ele o CLI tenta subir o próprio serviço na 49374 e colide com o do host.
SVC=$HOME/.config/opencode/service.json
if [ -e "$SVC" ]; then mkdir -p "$RUNDIR/home/.config/opencode"
  A+=(--ro-bind "$SVC" /home/shibuka/.config/opencode/service.json); fi
A+=(--ro-bind "$OC" "$OC" --ro-bind "$ND" "$ND" --chdir "$WT" --clearenv
    --setenv HOME /home/shibuka --setenv TERM dumb --setenv TMPDIR /tmp
    --setenv XDG_DATA_HOME /home/shibuka/.local/share --setenv XDG_CONFIG_HOME /home/shibuka/.config
    --setenv XDG_CACHE_HOME /home/shibuka/.cache
    --setenv PATH "$OC/node_modules/.bin:$ND/bin:/usr/bin:/bin")
# preflight: se a sandbox não sobe, não roda nada
if ! bwrap "${A[@]}" /usr/bin/true >/dev/null 2>&1; then
  echo "sandbox-run: preflight do bwrap falhou (fail-closed)" >&2; exit 97; fi
printf '{"sandbox":"bwrap","net":"share-net(parcial)","worktree":"%s","home":"%s","frozen":"%s","opencode":"%s","node":"%s"}\n' \
  "$WT" "$RUNDIR/home" "$FROZEN" "$OC" "$ND" >"$RUNDIR/sandbox.json"
exec bwrap "${A[@]}" "$@"

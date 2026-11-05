#!/usr/bin/env bash
# sandbox-done-when.sh — wrapper do done_when do pinga (PLAN-0018, INTENT-0006 opção A)
# uso: PINGA_EXEC_WRAPPER=.ginga/bin/sandbox-done-when.sh pinga verify ...
#      o pinga chama: sandbox-done-when.sh <ROOT> sh -c <done_when>
# Dentro do bwrap:
#   - /usr e o mínimo de /etc em modo somente leitura; bun do mise em modo somente leitura
#   - ROOT gravável; o .git comum do repo em modo somente leitura (testes usam git ls-files/log)
#   - HOME falso e vazio: ~/.ssh, ~/.hermes, ~/.codex e ~/Projetos NÃO existem
#   - SEM rede (--unshare-net): o done_when não tem por que sair para a rede
# Fail-closed: sem bwrap, sem bun ou se o preflight falhar → exit 97 (o pinga grava blocked/infra).
set -u
ROOT=$(readlink -f "${1:-}") || exit 97; shift
[ -d "$ROOT" ] && [ $# -gt 0 ] || { echo "sandbox-done-when: uso: <ROOT> <cmd...>" >&2; exit 97; }
command -v bwrap >/dev/null || { echo "sandbox-done-when: bwrap ausente (fail-closed)" >&2; exit 97; }
BUN=$(readlink -f "$(command -v bun 2>/dev/null)" 2>/dev/null); BUND=$(dirname "$(dirname "$BUN")")
[ -x "$BUN" ] || { echo "sandbox-done-when: bun não encontrado" >&2; exit 97; }
GITC=$(git -C "$ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
A=(--unshare-all --die-with-parent --new-session
   --ro-bind /usr /usr --symlink usr/bin /bin --symlink usr/lib /lib --symlink usr/lib /lib64
   --ro-bind /etc/passwd /etc/passwd --ro-bind /etc/hosts /etc/hosts --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf
   --ro-bind-try /etc/ssl /etc/ssl --ro-bind-try /etc/ca-certificates /etc/ca-certificates
   --proc /proc --dev /dev --tmpfs /tmp
   --tmpfs /home/shibuka --ro-bind "$BUND" "$BUND" --bind "$ROOT" "$ROOT")
[ -n "$GITC" ] && [ -d "$GITC" ] && A+=(--ro-bind "$GITC" "$GITC")   # depois do bind do ROOT: .git somente leitura mesmo dentro dele
A+=(--chdir "$ROOT" --clearenv --setenv HOME /home/shibuka --setenv TERM dumb --setenv TMPDIR /tmp
    --setenv PATH "$(dirname "$BUN"):/usr/bin:/bin" --setenv PINGA_SANDBOX bwrap)
# repassa só variáveis de contrato do pinga/ginga (nunca chaves de provider)
for v in PINGA_LEDGER GINGA_EVENTS CI; do [ -n "${!v:-}" ] && A+=(--setenv "$v" "${!v}"); done
# identidade do git (testes fazem commit em repos temporários); só nome/e-mail, nunca o ~/.gitconfig
GN=$(git config --get user.name || echo pinga-sandbox); GE=$(git config --get user.email || echo sandbox@localhost)
A+=(--setenv GIT_AUTHOR_NAME "$GN" --setenv GIT_AUTHOR_EMAIL "$GE" --setenv GIT_COMMITTER_NAME "$GN" --setenv GIT_COMMITTER_EMAIL "$GE")
bwrap "${A[@]}" /usr/bin/true >/dev/null 2>&1 || { echo "sandbox-done-when: preflight do bwrap falhou (fail-closed)" >&2; exit 97; }
exec bwrap "${A[@]}" "$@"

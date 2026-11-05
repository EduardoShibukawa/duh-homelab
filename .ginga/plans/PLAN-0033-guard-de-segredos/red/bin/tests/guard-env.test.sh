#!/usr/bin/env bash
# teste de bin/guard-env.sh e da fiação em lane.sh/dispatch-task.sh. Saída: "ok" por caso; exit 1 no primeiro erro.
set -u
B=$(cd "$(dirname "$0")/.." && pwd); T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fail(){ echo "FALHA: $1" >&2; exit 1; }
mkdir -p "$T/g/contrib/guard" "$T/g/src/guard"; : > "$T/g/contrib/guard/pi.ts"; : > "$T/g/contrib/guard/opencode.ts"; : > "$T/g/src/guard/cli.ts"
run(){ ( unset GINGA_GUARD GINGA_GUARD_LANE GINGA_GUARD_LOG; export GUARD_DIR="$T/g" G="$T/ginga"; source "$B/guard-env.sh"; eval "$1" ); }

[ "$(run 'guard_pi_args' | tr '\n' ' ')" = "-e $T/g/contrib/guard/pi.ts " ] || fail "guard_pi_args liga a extensão com -e"
[ "$(run 'guard_opencode_env')" = "OPENCODE_CONFIG_DIR=$T/g/contrib/guard/opencode-config" ] || fail "guard_opencode_env aponta o config dir"
[ -z "$(run 'GINGA_GUARD=off; guard_pi_args')" ] || fail "off desliga o Pi"
[ -z "$(run 'GINGA_GUARD=off; guard_opencode_env')" ] || fail "off desliga o opencode"
run 'guard_require' || fail "guard_require ok com os arquivos"
run 'GUARD_DIR=/nao/existe; guard_require' && fail "guard ausente com guard ligado tem que recusar"
run 'GUARD_DIR=/nao/existe; GINGA_GUARD=off; guard_require' || fail "off dispensa o guard"
[ "$(run 'guard_export lane-x; echo $GINGA_GUARD_LANE:$GINGA_GUARD:$GINGA_GUARD_LOG')" = "lane-x:enforce:$T/ginga/handoffs/guard.events.jsonl" ] || fail "guard_export marca a sessão"
[ -z "$(run 'GINGA_GUARD=off; guard_export lane-x; echo ${GINGA_GUARD_LANE:-}')" ] || fail "off não exporta a marca"
for f in lane.sh dispatch-task.sh; do
  [ -f "$B/$f" ] || continue
  bash -n "$B/$f" || fail "$f com erro de sintaxe"
  grep -q 'guard-env.sh' "$B/$f" || fail "$f não carrega guard-env.sh"
  grep -q 'guard_require' "$B/$f" || fail "$f não checa guard_require antes de rodar o runtime"
  grep -q 'guard_pi_args' "$B/$f" || fail "$f não passa guard_pi_args ao Pi"
  grep -q 'guard_opencode_env' "$B/$f" || fail "$f não passa guard_opencode_env ao opencode"
  grep -q 'guard_export' "$B/$f" || fail "$f não exporta a marca de sessão"
done
echo ok

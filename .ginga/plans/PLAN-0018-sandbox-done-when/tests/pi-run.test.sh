#!/usr/bin/env bash
# pi-run.test.sh — teste RED do pi-run.sh (PLAN-0018, repo duh-homelab)
# Usa um `pi` mock (via PATH) para não gastar dinheiro real.
set -u
DUH=/home/shibuka/Projetos/duh-homelab
PIRUN="$DUH/.ginga/bin/pi-run.sh"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
export PI_SPEND="$TMP/spend.tsv"
fail=0
note(){ printf '  %s\n' "$*"; }

# 1. existe e é executável
if [ ! -x "$PIRUN" ]; then echo "FAIL: pi-run.sh não existe/executável"; exit 1; fi
note "ok: pi-run.sh executável"

# mock pi: custo acima do teto (0.02 > 0.01)
cat >"$TMP/pi" <<'EOF'
#!/usr/bin/env bash
echo '{"type":"session","version":3,"id":"x","timestamp":"2026-10-28T00:00:00Z","cwd":"/"}'
echo '{"type":"message_end","message":{"role":"assistant","responseId":"r1","usage":{"input":10,"output":5,"totalTokens":15,"cost":{"total":0.02}}}}'
echo '{"type":"agent_settled","aborted":false}'
EOF
chmod +x "$TMP/pi"

# 2. acima do teto → mata (exit 124) e grava o custo
PATH="$TMP:$PATH" PI_PLAN=PLAN-0018 PI_TASK=TASK-06 "$PIRUN" 0.01 --provider opencode --model deepseek-v4-pro -p "ok" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 124 ]; then echo "FAIL: acima do teto deveria sair 124, saiu $rc"; fail=1; else note "ok: acima do teto → exit 124"; fi

# mock pi: custo abaixo do teto (0.005 < 0.01)
cat >"$TMP/pi" <<'EOF'
#!/usr/bin/env bash
echo '{"type":"session","version":3,"id":"x","timestamp":"2026-10-28T00:00:00Z","cwd":"/"}'
echo '{"type":"message_end","message":{"role":"assistant","responseId":"r1","usage":{"input":10,"output":5,"totalTokens":15,"cost":{"total":0.005}}}}'
echo '{"type":"agent_settled","aborted":false}'
EOF

# 3. abaixo do teto → exit 0
PATH="$TMP:$PATH" PI_PLAN=PLAN-0018 PI_TASK=TASK-06 "$PIRUN" 0.01 --provider opencode --model deepseek-v4-pro -p "ok" >/dev/null 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then echo "FAIL: abaixo do teto deveria sair 0, saiu $rc"; fail=1; else note "ok: abaixo do teto → exit 0"; fi

# 4. tsv gravado com formato data\tPLAN\tTASK\tmodelo\tcusto
if [ -s "$TMP/spend.tsv" ]; then
  n=$(wc -l <"$TMP/spend.tsv")
  note "ok: spend.tsv com $n linha(s)"
  sed 's/^/    /' "$TMP/spend.tsv"
else
  echo "FAIL: spend.tsv vazio"; fail=1
fi

exit $fail

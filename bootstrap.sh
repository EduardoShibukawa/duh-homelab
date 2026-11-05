#!/usr/bin/env bash
# Clona (ou atualiza) os repos do workspace dentro desta pasta e instala as dependências.
# Funciona em Linux e macOS. Idempotente: pode rodar de novo.
#   ./bootstrap.sh              repos principais
#   ./bootstrap.sh --all        inclui docs-benchmark e spring-petclinic-modern
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
OWNER="${OWNER:-EduardoShibukawa}"

# repo no GitHub -> pasta local (o ginga mora em g-inga no GitHub, mas as lanes usam ginga/)
CORE=("g-inga:ginga" "manda:manda" "p-inga:p-inga" "gira-g:gira-g")
EXTRA=("docs-benchmark:docs-benchmark" "spring-petclinic-modern:spring-petclinic-modern")
REPOS=("${CORE[@]}")
[[ "${1:-}" == "--all" ]] && REPOS+=("${EXTRA[@]}")

have() { command -v "$1" >/dev/null 2>&1; }

if ! have git; then echo "git não encontrado" >&2; exit 1; fi

if ! have mise; then
  echo "==> instalando mise"
  curl -fsSL https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

for pair in "${REPOS[@]}"; do
  repo="${pair%%:*}"; dir="${pair##*:}"
  if [[ -d "$dir/.git" ]]; then
    echo "==> atualizando $dir"
    git -C "$dir" pull --ff-only || echo "    (pull falhou em $dir; resolva à mão)"
  else
    echo "==> clonando $repo em $dir"
    git clone "https://github.com/$OWNER/$repo.git" "$dir"
  fi
done

for pair in "${REPOS[@]}"; do
  dir="${pair##*:}"
  echo "==> dependências de $dir"
  (
    cd "$dir"
    [[ -f mise.toml ]] && mise trust -q . && mise install
    if [[ -f package.json ]]; then mise exec -- bun install; fi
    if [[ -f go.mod ]]; then mise exec -- go mod download; fi
  )
done

echo
echo "Pronto. Teste cada repo:"
echo "  (cd ginga && mise exec -- bun test)"
echo "  (cd manda && mise exec -- bun test)"
echo "  (cd p-inga && mise exec -- bun test)"
echo "  (cd gira-g && mise exec -- go test ./...)"
echo "Nota: o ledger.db do pinga é local; no Mac ele começa vazio. Use o Mac para testar."

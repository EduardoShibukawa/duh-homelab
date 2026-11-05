#!/usr/bin/env bash
# ==============================================================================
# TUIOS CONTROL CENTER — CENTRAL INTERATIVA DE ALTA PRODUTIVIDADE
# Inspirada em LazyGit, K9s e Charm Gum para o ecossistema duh-homelab
# ==============================================================================
set -euo pipefail

DUH_ROOT="/home/shibuka/Projetos/duh-homelab"
BUN="/home/shibuka/.local/share/mise/installs/bun/latest/bin/bun"
PINGA_CLI="$DUH_ROOT/p-inga/bin/pinga.ts"
LEDGER_DB="/home/shibuka/.local/state/pinga/ledger.db"
GIRA_BIN="/home/shibuka/.local/bin/gira"
HERMES_BIN="/home/shibuka/.local/bin/hermes"
TUIOS_BIN="/usr/bin/tuios"
GUM_BIN="/usr/bin/gum"
FZF_BIN="/usr/bin/fzf"
PID_FILE="/tmp/pinga-dashboard.pid"

# Cores e Estilos
COLOR_PRIMARY="212"    # Magenta / Rosa neon
COLOR_SECONDARY="141"  # Roxo suave
COLOR_SUCCESS="50"     # Verde neon
COLOR_WARNING="220"    # Amarelo alerta
COLOR_DANGER="196"     # Vermelho
COLOR_INFO="39"        # Azul ciano
COLOR_MUTED="245"      # Cinza discreto

# Envia status HUD para o TUIOS (OSC 7501)
send_hud() {
    local kind="${1:-working}"
    local app="${2:-p-inga}"
    local msg="${3:-Notificação}"

    if command -v "$TUIOS_BIN" >/dev/null 2>&1; then
        if [ "$kind" = "blocked" ]; then
            "$TUIOS_BIN" status blocked --kind permission --app "$app" --msg "$msg" 2>/dev/null || true
        elif [ "$kind" = "clear" ]; then
            "$TUIOS_BIN" status --clear 2>/dev/null || true
        else
            "$TUIOS_BIN" status "$kind" --app "$app" --msg "$msg" 2>/dev/null || true
        fi
    fi
}

# Obtém a sessão ativa do TUIOS
get_active_session() {
    if [ -n "${TUIOS_SESSION:-}" ]; then
        echo "$TUIOS_SESSION"
        return
    fi
    if command -v "$TUIOS_BIN" >/dev/null 2>&1; then
        local sess
        sess=$("$TUIOS_BIN" list-sessions --json 2>/dev/null | jq -r '.[0].name // empty' 2>/dev/null || true)
        if [ -n "$sess" ]; then
            echo "$sess"
            return
        fi
    fi
    echo "homelab"
}

# Renderiza o cabeçalho dinâmico Mission Control
render_header() {
    clear 2>/dev/null || true
    local title=" 🛡️  HOMELAB TUIOS CONTROL CENTER • MISSION CONTROL "
    "$GUM_BIN" style \
        --border double \
        --border-foreground "$COLOR_PRIMARY" \
        --foreground "$COLOR_PRIMARY" \
        --bold \
        --align center \
        --width 80 \
        "$title"

    # 1. Telemetria Rápida: Disjuntores, Tokens, Dashboard e Maestro
    local breakers_status="🛡️ G1:OK | G2:OK | I3:CLEAR"
    if [ -f "$LEDGER_DB" ]; then
        local last_status
        last_status=$(sqlite3 -list -separator "|" "$LEDGER_DB" "SELECT status, COALESCE(json_extract(body, '$.breaker.failure_signature'), '') FROM receipts ORDER BY seq DESC LIMIT 1;" 2>/dev/null || echo "pass|")
        local st sig
        st=$(echo "$last_status" | cut -d'|' -f1)
        sig=$(echo "$last_status" | cut -d'|' -f2)
        if [ "$st" = "blocked" ] && [ -n "$sig" ]; then
            breakers_status="🚨 I3:TRIPPED (${sig:0:10}...)"
        fi
    fi

    local tokens_status="0 tok ($0.00)"
    if [ -f "$LEDGER_DB" ]; then
        local totals
        totals=$(sqlite3 -list -separator "|" "$LEDGER_DB" "SELECT COALESCE(SUM(json_extract(body, '$.tokens.in') + json_extract(body, '$.tokens.out')), 0), COALESCE(ROUND(SUM(json_extract(body, '$.cost_usd')), 4), 0.0) FROM receipts;" 2>/dev/null || echo "0|0.00")
        local tok cost
        tok=$(echo "$totals" | cut -d'|' -f1)
        cost=$(echo "$totals" | cut -d'|' -f2)
        tokens_status="${tok:-0} tok (\$${cost:-0.00})"
    fi

    local web_status="🔴 Inativo"
    if curl -s -m 1 http://localhost:4242/api/receipts >/dev/null 2>&1; then
        web_status="🟢 :4242 Ativo"
    fi

    local session_info="Sessão: $(get_active_session)"
    if [ -n "${TUIOS_PANE_ID:-}" ]; then
        session_info="$session_info (Pane: ${TUIOS_PANE_ID:0:8})"
    fi

    local hud_line
    hud_line=$(printf "  ⚡ Disjuntores: %s   │   📊 Ledger: %s\n  🌐 Web: %s   │   🖥️  TUIOS: %s" \
        "$breakers_status" "$tokens_status" "$web_status" "$session_info")
    "$GUM_BIN" style \
        --border rounded \
        --border-foreground "$COLOR_SECONDARY" \
        --foreground "$COLOR_INFO" \
        --padding "0 1" \
        --width 80 \
        "$hud_line"
    echo ""
}

# ------------------------------------------------------------------------------
# 1. 🚀 DESPACHAR TAREFA / PROMPT
# ------------------------------------------------------------------------------
action_dispatch_task() {
    "$GUM_BIN" style --foreground "$COLOR_PRIMARY" --bold "🚀 DESPACHAR TAREFA / OPERAÇÃO"
    echo ""

    local task_prompt
    task_prompt=$("$GUM_BIN" input --placeholder "Digite a tarefa, micro-contrato ou instrução para o operário..." --width 76)
    if [ -z "$task_prompt" ]; then
        echo "Operação cancelada."
        sleep 1
        return
    fi

    echo ""
    "$GUM_BIN" style --foreground "$COLOR_INFO" "Selecione o Modelo de Execução:"
    local model_choice
    model_choice=$("$GUM_BIN" choose \
        "Qwen 2.5 3B (Local Fast - Maestro Base)" \
        "DeepSeek-V3 / R1 (deepseek-chat)" \
        "Claude 3.5 Sonnet (claude-3-5-sonnet)" \
        "Claude 3.7 Sonnet (claude-3-7-sonnet)" \
        "Qwen 2.5 Coder 32B" \
        "Cancelar")

    if [ "$model_choice" = "Cancelar" ] || [ -z "$model_choice" ]; then
        return
    fi

    local model_arg=""
    case "$model_choice" in
        "Qwen 2.5 3B"*) model_arg="qwen2.5-3b" ;;
        "DeepSeek"*)    model_arg="deepseek-chat" ;;
        "Claude 3.5"*)  model_arg="claude-3-5-sonnet" ;;
        "Claude 3.7"*)  model_arg="claude-3-7-sonnet" ;;
        "Qwen 2.5 Coder"*) model_arg="qwen2.5-coder-32b" ;;
    esac

    echo ""
    "$GUM_BIN" style --foreground "$COLOR_INFO" "Modo de Despacho:"
    local exec_target
    exec_target=$("$GUM_BIN" choose \
        "1. Executar no Terminal Atual com Live Logs e HUD" \
        "2. Abrir em Novo Painel TUIOS (Janela 'worker')" \
        "3. Cancelar")

    if [ "$exec_target" = "3. Cancelar" ] || [ -z "$exec_target" ]; then
        return
    fi

    local trunc_msg="${task_prompt:0:40}..."
    send_hud "working" "dispatcher" "Despachando: $trunc_msg ($model_arg)"

    if [ "$exec_target" = "1. Executar no Terminal Atual com Live Logs e HUD" ]; then
        echo ""
        "$GUM_BIN" style --border rounded --padding "0 1" --foreground "$COLOR_WARNING" "Executando Hermes Agent com perfil formal 'pinga'..."
        echo "Comando: hermes -p pinga -m $model_arg -z \"$task_prompt\""
        echo "------------------------------------------------------------------"

        set +e
        "$HERMES_BIN" -p pinga -m "$model_arg" -z "$task_prompt"
        local rc=$?
        set -e

        echo "------------------------------------------------------------------"
        if [ $rc -eq 0 ]; then
            send_hud "done" "dispatcher" "Tarefa concluída com sucesso: $trunc_msg"
            "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "✅ Tarefa finalizada com sucesso (Exit 0)."
        else
            send_hud "blocked" "dispatcher" "Falha na tarefa: $trunc_msg (Exit $rc)"
            "$GUM_BIN" style --foreground "$COLOR_DANGER" --bold "❌ Tarefa encerrou com erro (Exit $rc)."
        fi
        echo ""
        read -rp "Pressione Enter para voltar ao menu..."
    else
        local sess
        sess=$(get_active_session)
        if command -v "$TUIOS_BIN" >/dev/null 2>&1 && "$TUIOS_BIN" has-session -s "$sess" 2>/dev/null; then
            local cmd_run="cd $DUH_ROOT && $HERMES_BIN -p pinga -m $model_arg -z $(printf '%q' "$task_prompt"); echo ''; echo 'Pressione Enter para fechar...'; read"
            local win_id
            win_id=$("$TUIOS_BIN" new-window -s "$sess" -n "worker" --json 2>/dev/null | jq -r '.window_id // empty' || echo "")
            if [ -n "$win_id" ]; then
                "$TUIOS_BIN" send-text -s "$sess" -w "$win_id" "$cmd_run\n"
                "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "✅ Novo painel TUIOS 'worker' criado e tarefa despachada!"
            else
                "$GUM_BIN" style --foreground "$COLOR_DANGER" "Não foi possível abrir o novo painel TUIOS."
            fi
        else
            "$GUM_BIN" style --foreground "$COLOR_WARNING" "Nenhuma sessão TUIOS ativa detectada. Despacho desacoplado indisponível."
        fi
        sleep 2
    fi
}

# ------------------------------------------------------------------------------
# 2. 🛡️ EXECUTAR VERIFICAÇÃO FORMAL P-INGÁ
# ------------------------------------------------------------------------------
action_verify_plan() {
    "$GUM_BIN" style --foreground "$COLOR_INFO" --bold "🛡️ VERIFICAÇÃO FORMAL DETERMINÍSTICA P-INGÁ"
    echo ""

    local plan_list
    plan_list=$(find "$DUH_ROOT/p-inga/tasks" -name "PLAN.md" 2>/dev/null | sort || true)
    if [ -z "$plan_list" ]; then
        "$GUM_BIN" style --foreground "$COLOR_DANGER" "Nenhum arquivo PLAN.md encontrado em p-inga/tasks."
        sleep 2
        return
    fi

    echo "Selecione o PLAN.md para inspecionar e verificar formalmente:"
    local selected_plan
    selected_plan=$(echo "$plan_list" | "$FZF_BIN" \
        --height 60% \
        --reverse \
        --header="[ENTER]: Selecionar PLAN | [ESC]: Cancelar" \
        --preview="cat {} | head -n 45" \
        --preview-window=right:60%:wrap)

    if [ -z "$selected_plan" ]; then
        return
    fi

    local task_id
    task_id=$(basename "$(dirname "$selected_plan")")

    echo ""
    "$GUM_BIN" style --foreground "$COLOR_PRIMARY" "Plano Selecionado: $task_id ($selected_plan)"
    local verify_mode
    verify_mode=$("$GUM_BIN" choose \
        "1. Executar Verificação Padrão" \
        "2. Executar com Override de Modo (Operador)" \
        "3. Cancelar")

    if [ "$verify_mode" = "3. Cancelar" ] || [ -z "$verify_mode" ]; then
        return
    fi

    local override_args=()
    if [ "$verify_mode" = "2. Executar com Override de Modo (Operador)" ]; then
        echo ""
        "$GUM_BIN" style --foreground "$COLOR_WARNING" "Selecione o Modo Forçado:"
        local chosen_mode
        chosen_mode=$("$GUM_BIN" choose "padrao" "revisao" "congelado")
        local override_reason
        override_reason=$("$GUM_BIN" input --placeholder "Motivo formal do override (obrigatório)..." --width 70)
        if [ -z "$override_reason" ]; then
            echo "Override cancelado (motivo vazio)."
            sleep 1
            return
        fi
        override_args=("--override-mode" "$chosen_mode" "--reason" "$override_reason")
    fi

    echo ""
    send_hud "working" "p-inga" "Verificando contratos: $task_id"

    local raw_output
    raw_output=$("$GUM_BIN" spin --spinner dot --title "Executando motor criptográfico P-Ingá..." -- \
        bash -c "cd '$DUH_ROOT/p-inga' && '$BUN' '$PINGA_CLI' verify '$selected_plan' ${override_args[*]} 2>&1") || true

    echo "Resultado da Avaliação Formal:"
    echo "------------------------------------------------------------------"

    local status="fail"
    local sha_hash="N/A"
    local reason=""
    local summary=""

    if echo "$raw_output" | jq -e . >/dev/null 2>&1; then
        status=$(echo "$raw_output" | jq -r '.status // "fail"')
        reason=$(echo "$raw_output" | jq -r '.reason_code // ""')
        summary=$(echo "$raw_output" | jq -r '.summary // ""')
    else
        summary="$raw_output"
    fi

    # Checa o hash do recibo gravado no SQLite
    if [ -f "$LEDGER_DB" ]; then
        sha_hash=$(sqlite3 -list "$LEDGER_DB" "SELECT hash FROM receipts WHERE task = '$task_id' ORDER BY seq DESC LIMIT 1;" 2>/dev/null || echo "N/A")
    fi

    local sha_short="${sha_hash:0:16}..."

    if [ "$status" = "pass" ]; then
        send_hud "done" "p-inga" "Task $task_id VERIFICADA | SHA: $sha_short"
        "$GUM_BIN" style \
            --border double \
            --border-foreground "$COLOR_SUCCESS" \
            --foreground "$COLOR_SUCCESS" \
            --bold \
            --padding "0 1" \
            "✅ VERIFICAÇÃO BEM-SUCEDIDA: $task_id (PASS)\nRecibo Criptográfico: $sha_hash\nResumo: $summary"
    elif [ "$status" = "blocked" ]; then
        send_hud "blocked" "p-inga" "Task $task_id BLOQUEADA: $reason"
        "$GUM_BIN" style \
            --border double \
            --border-foreground "$COLOR_WARNING" \
            --foreground "$COLOR_WARNING" \
            --bold \
            --padding "0 1" \
            "🚨 DISJUNTOR / GUARDA BLOQUEOU: $task_id (BLOCKED)\nMotivo: $reason\nResumo: $summary"
    else
        send_hud "error" "p-inga" "Task $task_id FALHOU"
        "$GUM_BIN" style \
            --border double \
            --border-foreground "$COLOR_DANGER" \
            --foreground "$COLOR_DANGER" \
            --bold \
            --padding "0 1" \
            "❌ TAREFA REJEITADA: $task_id (FAIL)\nMotivo: $reason\nSaída: $summary"
    fi

    echo ""
    echo "Detalhes do Recibo JSON:"
    if echo "$raw_output" | jq -e . >/dev/null 2>&1; then
        echo "$raw_output" | jq .
    else
        echo "$raw_output"
    fi

    echo ""
    read -rp "Pressione Enter para voltar ao menu..."
}

# ------------------------------------------------------------------------------
# 3. ⚡ DISJUNTORES & OVERRIDES
# ------------------------------------------------------------------------------
action_breakers_and_overrides() {
    "$GUM_BIN" style --foreground "$COLOR_WARNING" --bold "⚡ ESTADO DOS DISJUNTORES & OVERRIDES FORMAL"
    echo ""

    local last_receipt_info="Nenhum recibo no ledger."
    local i3_tripped="CLEAR"
    local i3_sig=""
    if [ -f "$LEDGER_DB" ]; then
        local last_row
        last_row=$(sqlite3 -list -separator "|" "$LEDGER_DB" "SELECT seq, task, status, COALESCE(json_extract(body, '$.breaker.tripped'), 0), COALESCE(json_extract(body, '$.breaker.failure_signature'), '') FROM receipts ORDER BY seq DESC LIMIT 1;" 2>/dev/null || echo "")
        if [ -n "$last_row" ]; then
            local seq task st tripped sig
            seq=$(echo "$last_row" | cut -d'|' -f1)
            task=$(echo "$last_row" | cut -d'|' -f2)
            st=$(echo "$last_row" | cut -d'|' -f3)
            tripped=$(echo "$last_row" | cut -d'|' -f4)
            sig=$(echo "$last_row" | cut -d'|' -f5)

            if [ "$tripped" = "1" ] || ([ "$st" = "blocked" ] && [ -n "$sig" ]); then
                i3_tripped="TRIPPED"
                i3_sig="$sig"
            fi
            last_receipt_info="Seq #$seq | Task $task | Status: $st"
        fi
    fi

    echo "Estado dos Circuit Breakers Operacionais:"
    echo "  1. [G1 Inércia]:        Ativo (Max 3 leituras consecutivas sem mutação)"
    echo "  2. [G2 Payload Guard]:  Ativo (Max 100 linhas / 1500 caracteres por arquivo existente)"
    if [ "$i3_tripped" = "TRIPPED" ]; then
        "$GUM_BIN" style --foreground "$COLOR_DANGER" --bold "  3. [I3 Anti-Thrashing]: 🚨 DISPARADO! Assinatura: $i3_sig"
    else
        "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "  3. [I3 Anti-Thrashing]: 🟢 CLEAR (Nenhum loop de falha idêntica)"
    fi
    echo "  Último recibo verificado: $last_receipt_info"
    echo ""

    local choice
    choice=$("$GUM_BIN" choose \
        "1. Resetar Alertas e Limpar HUD do TUIOS" \
        "2. Simular/Testar Disparo de Alerta no HUD" \
        "3. Aplicar Override Manual de Modo (p-inga mode)" \
        "4. Verificar Integridade Criptográfica da Cadeia (ledger verify)" \
        "5. Voltar ao Menu Principal")

    case "$choice" in
        "1. Resetar Alertas"*)
            if "$GUM_BIN" confirm "Confirma o destravamento e reset de todos os alertas no HUD?"; then
                send_hud "clear" "p-inga" ""
                send_hud "done" "p-inga" "Disjuntores Destravados pelo Operador"
                "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "✅ HUD resetado e sinal de destravamento emitido!"
                sleep 1.5
            fi
            ;;
        "2. Simular/Testar"*)
            send_hud "blocked" "p-inga" "G1 Inércia Simulado: 3 leituras sem mutação"
            "$GUM_BIN" style --foreground "$COLOR_WARNING" --bold "🚨 Alerta simulado enviado ao TUIOS HUD!"
            sleep 1.5
            ;;
        "3. Aplicar Override"*)
            local plan_list
            plan_list=$(find "$DUH_ROOT/p-inga/tasks" -name "PLAN.md" 2>/dev/null | sort || true)
            local plan
            plan=$(echo "$plan_list" | "$FZF_BIN" --header="Selecione o plano para override de modo")
            if [ -n "$plan" ]; then
                local mode
                mode=$("$GUM_BIN" choose "padrao" "revisao" "congelado")
                local reason
                reason=$("$GUM_BIN" input --placeholder "Motivo do override de modo..." --width 60)
                if [ -n "$reason" ]; then
                    echo ""
                    "$BUN" "$PINGA_CLI" mode "$plan" --override-mode "$mode" --reason "$reason" || true
                    read -rp "Pressione Enter para continuar..."
                fi
            fi
            ;;
        "4. Verificar Integridade"*)
            echo ""
            "$GUM_BIN" style --foreground "$COLOR_INFO" "Executando pinga ledger verify..."
            "$BUN" "$PINGA_CLI" ledger verify --ledger "$LEDGER_DB"
            read -rp "Pressione Enter para continuar..."
            ;;
        *)
            return
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 4. 📐 NAVEGADOR AST GIRA-G
# ------------------------------------------------------------------------------
action_gira_ast_browser() {
    "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "📐 NAVEGADOR AST GIRA-G (SÍMBOLOS, CLASSES & SLICES)"
    echo ""

    local op
    op=$("$GUM_BIN" choose \
        "1. Explorar Símbolos / Métodos em Arquivo (gira outline & read)" \
        "2. Visualizar Definição AST Direta de um Símbolo (gira read)" \
        "3. Bounded Context Slice (gira slice)" \
        "4. Buscar no Grafo Arquitetural (gira locate)" \
        "5. Voltar")

    if [ "$op" = "5. Voltar" ] || [ -z "$op" ]; then
        return
    fi

    case "$op" in
        "1. Explorar Símbolos"*)
            echo "Selecione o arquivo de código fonte para inspecionar a AST:"
            local source_file
            source_file=$(find "$DUH_ROOT/p-inga/src" "$DUH_ROOT/gira-g/src" "$DUH_ROOT/p-inga/web" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.rs" \) 2>/dev/null | "$FZF_BIN" \
                --height 60% \
                --reverse \
                --header="Selecione o arquivo fonte" \
                --preview="head -n 50 {}" \
                --preview-window=right:60%:wrap)

            if [ -z "$source_file" ]; then
                return
            fi

            echo "Carregando símbolos AST com gira outline..."
            local outline_lines
            outline_lines=$("$GIRA_BIN" outline "$source_file" --format text 2>/dev/null | grep '^- ' || true)

            if [ -z "$outline_lines" ]; then
                "$GUM_BIN" style --foreground "$COLOR_WARNING" "Nenhum símbolo estruturado encontrado neste arquivo."
                sleep 2
                return
            fi

            echo "Selecione o símbolo/método para ler o nó sintático exato:"
            local selected_line
            selected_line=$(echo "$outline_lines" | "$FZF_BIN" \
                --height 60% \
                --reverse \
                --header="[ENTER]: Ler Nó AST | [ESC]: Cancelar")

            if [ -z "$selected_line" ]; then
                return
            fi

            local sym_name
            sym_name=$(echo "$selected_line" | sed -E 's/^- L[0-9]+(-L[0-9]+)?: (function|type|class|interface|const|let|var) ([a-zA-Z0-9_]+).*/\3/')

            if [ -n "$sym_name" ]; then
                echo ""
                "$GUM_BIN" style --foreground "$COLOR_PRIMARY" --bold "Nó AST: $sym_name ($source_file)"
                local code_node
                code_node=$("$GIRA_BIN" read "$source_file" "$sym_name" 2>/dev/null || echo "Falha ao extrair nó")
                echo "$code_node" | "$GUM_BIN" pager
            fi
            ;;

        "2. Visualizar Definição AST Direta"*)
            local file_path
            file_path=$("$GUM_BIN" input --placeholder "Caminho do arquivo (ex: /path/to/src/breaker.ts)..." --width 70)
            if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
                echo "Arquivo inexistente ou inválido."
                sleep 1.5
                return
            fi
            local symbol_name
            symbol_name=$("$GUM_BIN" input --placeholder "Nome do símbolo ou função..." --width 50)
            if [ -z "$symbol_name" ]; then
                return
            fi
            local res
            res=$("$GIRA_BIN" read "$file_path" "$symbol_name" 2>&1 || true)
            echo "$res" | "$GUM_BIN" pager
            ;;

        "3. Bounded Context Slice"*)
            local target_node
            target_node=$("$GUM_BIN" input --placeholder "ID do nó / componente para o slice..." --width 50)
            if [ -n "$target_node" ]; then
                local slice_res
                slice_res=$("$GIRA_BIN" slice "$target_node" 2>&1 || true)
                echo "$slice_res" | "$GUM_BIN" pager
            fi
            ;;

        "4. Buscar no Grafo"*)
            local query
            query=$("$GUM_BIN" input --placeholder "Termo de busca arquitetural (ex: breaker, verify)..." --width 50)
            if [ -n "$query" ]; then
                local loc_res
                loc_res=$("$GIRA_BIN" locate "$query" 2>&1 || true)
                echo "$loc_res" | "$GUM_BIN" pager
            fi
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 5. 📜 HISTÓRICO DE RECIBOS (LEDGER EXPLORER)
# ------------------------------------------------------------------------------
action_receipts_history() {
    "$GUM_BIN" style --foreground "$COLOR_SECONDARY" --bold "📜 HISTÓRICO DE RECIBOS DO LEDGER CRIPTOGRÁFICO"
    echo ""

    if [ ! -f "$LEDGER_DB" ]; then
        "$GUM_BIN" style --foreground "$COLOR_DANGER" "Ledger DB não encontrado em: $LEDGER_DB"
        sleep 2
        return
    fi

    # Formata lista de recibos para navegação tipo LazyGit
    local receipts_list
    receipts_list=$(sqlite3 -list -separator "|" "$LEDGER_DB" "SELECT seq, task, status, substr(hash, 1, 16), created_at FROM receipts ORDER BY seq DESC;" 2>/dev/null || true)

    if [ -z "$receipts_list" ]; then
        "$GUM_BIN" style --foreground "$COLOR_WARNING" "Nenhum recibo registrado no ledger."
        sleep 2
        return
    fi

    echo "Navegue pelos recibos com as setas. O painel direito exibe o JSON criptográfico completo:"
    local selected_row
    selected_row=$(echo "$receipts_list" | awk -F'|' '{ printf "%-4s | %-6s | %-8s | %-16s | %s\n", $1, $2, $3, $4, $5 }' | "$FZF_BIN" \
        --height 70% \
        --reverse \
        --header="SEQ  | TASK   | STATUS   | SHA256 (PREFIX)  | DATA CRIAÇÃO" \
        --preview="seq=\$(echo {} | awk '{print \$1}'); sqlite3 -list '$LEDGER_DB' \"SELECT body FROM receipts WHERE seq = \$seq;\" | jq -C ." \
        --preview-window=right:60%:wrap)

    if [ -z "$selected_row" ]; then
        return
    fi

    local selected_seq
    selected_seq=$(echo "$selected_row" | awk '{print $1}')

    local full_body full_hash
    full_body=$(sqlite3 -list "$LEDGER_DB" "SELECT body FROM receipts WHERE seq = $selected_seq;" 2>/dev/null || true)
    full_hash=$(sqlite3 -list "$LEDGER_DB" "SELECT hash FROM receipts WHERE seq = $selected_seq;" 2>/dev/null || true)

    echo ""
    "$GUM_BIN" style --foreground "$COLOR_PRIMARY" --bold "Recibo Seq #$selected_seq Selecionado"
    echo "Hash SHA256: $full_hash"

    local sub_action
    sub_action=$("$GUM_BIN" choose \
        "1. Abrir JSON Completo no Pager" \
        "2. Copiar SHA256 para Área de Transferência" \
        "3. Validar Integridade da Cadeia até este Recibo" \
        "4. Voltar")

    case "$sub_action" in
        "1. Abrir JSON"*)
            echo "$full_body" | jq . | "$GUM_BIN" pager
            ;;
        "2. Copiar SHA256"*)
            if command -v wl-copy >/dev/null 2>&1; then
                echo -n "$full_hash" | wl-copy
                echo "SHA256 copiado via wl-copy!"
            elif command -v xclip >/dev/null 2>&1; then
                echo -n "$full_hash" | xclip -selection clipboard
                echo "SHA256 copiado via xclip!"
            else
                echo "Hash: $full_hash"
            fi
            sleep 1.5
            ;;
        "3. Validar Integridade"*)
            "$BUN" "$PINGA_CLI" ledger verify --ledger "$LEDGER_DB"
            read -rp "Pressione Enter para continuar..."
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 6. 💬 HERMES CHAT INTERATIVO
# ------------------------------------------------------------------------------
action_hermes_chat() {
    "$GUM_BIN" style --foreground "$COLOR_INFO" --bold "💬 SESSÃO CONVERSACIONAL HERMES AGENT (PERFIL P-INGÁ)"
    echo ""

    local mode
    mode=$("$GUM_BIN" choose \
        "1. Iniciar Chat no Terminal Atual" \
        "2. Abrir Chat em Novo Painel TUIOS" \
        "3. Abrir Chat em Popup Flutuante TUIOS" \
        "4. Cancelar")

    if [ "$mode" = "4. Cancelar" ] || [ -z "$mode" ]; then
        return
    fi

    local sess
    sess=$(get_active_session)

    case "$mode" in
        "1. Iniciar Chat no Terminal Atual"*)
            "$HERMES_BIN" -p pinga
            ;;
        "2. Abrir Chat em Novo Painel TUIOS"*)
            if command -v "$TUIOS_BIN" >/dev/null 2>&1 && "$TUIOS_BIN" has-session -s "$sess" 2>/dev/null; then
                local win_id
                win_id=$("$TUIOS_BIN" new-window -s "$sess" -n "hermes-chat" --json 2>/dev/null | jq -r '.window_id // empty' || echo "")
                if [ -n "$win_id" ]; then
                    "$TUIOS_BIN" send-text -s "$sess" -w "$win_id" "cd $DUH_ROOT && $HERMES_BIN -p pinga\n"
                    "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "✅ Novo painel 'hermes-chat' criado na sessão '$sess'!"
                fi
            else
                "$GUM_BIN" style --foreground "$COLOR_WARNING" "Nenhuma sessão TUIOS ativa. Iniciando localmente..."
                sleep 1
                "$HERMES_BIN" -p pinga
            fi
            sleep 1.5
            ;;
        "3. Abrir Chat em Popup Flutuante TUIOS"*)
            if command -v "$TUIOS_BIN" >/dev/null 2>&1 && "$TUIOS_BIN" has-session -s "$sess" 2>/dev/null; then
                "$TUIOS_BIN" popup -s "$sess" --width 85% --height 80% -- "$HERMES_BIN" -p pinga
            else
                "$GUM_BIN" style --foreground "$COLOR_WARNING" "Popup requer cliente TUIOS conectado. Iniciando localmente..."
                sleep 1
                "$HERMES_BIN" -p pinga
            fi
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 7. 🌐 GERENCIADOR DO WEB DASHBOARD
# ------------------------------------------------------------------------------
action_web_dashboard() {
    "$GUM_BIN" style --foreground "$COLOR_PRIMARY" --bold "🌐 WEB DASHBOARD P-INGÁ (:4242)"
    echo ""

    local is_active=false
    if curl -s -m 1 http://localhost:4242/api/receipts >/dev/null 2>&1; then
        is_active=true
        "$GUM_BIN" style --foreground "$COLOR_SUCCESS" --bold "🟢 Web Dashboard está ativo em http://localhost:4242"
    else
        "$GUM_BIN" style --foreground "$COLOR_DANGER" --bold "🔴 Web Dashboard está parado."
    fi
    echo ""

    local action
    action=$("$GUM_BIN" choose \
        "1. Abrir no Navegador (xdg-open)" \
        "2. Iniciar Servidor Web" \
        "3. Reiniciar Servidor Web" \
        "4. Parar Servidor Web" \
        "5. Inspecionar Estatísticas da API" \
        "6. Voltar")

    case "$action" in
        "1. Abrir no Navegador"*)
            if [ "$is_active" = false ]; then
                "$DUH_ROOT/bin/start-dashboard.sh"
                sleep 1
            fi
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "http://localhost:4242" >/dev/null 2>&1 &
            fi
            "$GUM_BIN" style --foreground "$COLOR_SUCCESS" "Aberto: http://localhost:4242"
            sleep 1.5
            ;;
        "2. Iniciar Servidor Web"*)
            "$DUH_ROOT/bin/start-dashboard.sh"
            sleep 1.5
            ;;
        "3. Reiniciar Servidor Web"*)
            "$DUH_ROOT/bin/stop-dashboard.sh" || true
            sleep 1
            "$DUH_ROOT/bin/start-dashboard.sh"
            sleep 1.5
            ;;
        "4. Parar Servidor Web"*)
            "$DUH_ROOT/bin/stop-dashboard.sh"
            sleep 1.5
            ;;
        "5. Inspecionar Estatísticas"*)
            if [ "$is_active" = true ]; then
                curl -s http://localhost:4242/api/receipts | jq . | "$GUM_BIN" pager
            else
                echo "Servidor inativo."
                sleep 1
            fi
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 8. 📊 TELEMETRIA MAESTRO
# ------------------------------------------------------------------------------
action_maestro_telemetry() {
    "$GUM_BIN" style --foreground "$COLOR_INFO" --bold "📊 SCOREBOARD E RECOMENDAÇÕES DO MAESTRO"
    echo ""

    local scoreboard_json
    scoreboard_json=$("$BUN" "$PINGA_CLI" maestro scoreboard --ledger "$LEDGER_DB" --json 2>/dev/null || echo "{}")

    echo "Classificação de Operários por FTPR (First-Time Pass Rate):"
    echo "$scoreboard_json" | jq -r '.workers[] | "• \(.model) | Família: \(.family) | Status: \(.status) | Tarefas: \(.total_tasks) | FTPR: \((.ftpr * 100 | round))% | Disjuntores: \(.breaker_trips)"' 2>/dev/null || echo "Nenhum operário registrado."

    echo ""
    read -rp "Pressione Enter para voltar ao menu..."
}

# ------------------------------------------------------------------------------
# LOOP PRINCIPAL DO MENU
# ------------------------------------------------------------------------------
main() {
    while true; do
        render_header

        local selected_option
        selected_option=$("$GUM_BIN" choose \
            "🚀 1. Despachar Tarefa (Hermes / Worker)" \
            "🛡️ 2. Executar Verificação Formal P-Ingá (PLAN.md)" \
            "⚡ 3. Disjuntores & Overrides (G1, G2, I3)" \
            "📐 4. Navegador AST Gira-G (Symbols & Code)" \
            "📜 5. Histórico de Recibos (Ledger Explorer)" \
            "💬 6. Abrir Hermes Chat (Conversacional)" \
            "🌐 7. Gerenciar Web Dashboard (:4242)" \
            "📊 8. Telemetria do Maestro (Scoreboard)" \
            "🚪 9. Sair")

        case "$selected_option" in
            "🚀 1. Despachar Tarefa"*)
                action_dispatch_task
                ;;
            "🛡️ 2. Executar Verificação"*)
                action_verify_plan
                ;;
            "⚡ 3. Disjuntores & Overrides"*)
                action_breakers_and_overrides
                ;;
            "📐 4. Navegador AST Gira-G"*)
                action_gira_ast_browser
                ;;
            "📜 5. Histórico de Recibos"*)
                action_receipts_history
                ;;
            "💬 6. Abrir Hermes Chat"*)
                action_hermes_chat
                ;;
            "🌐 7. Gerenciar Web Dashboard"*)
                action_web_dashboard
                ;;
            "📊 8. Telemetria do Maestro"*)
                action_maestro_telemetry
                ;;
            "🚪 9. Sair"|*)
                clear 2>/dev/null || true
                echo "Até logo!"
                break
                ;;
        esac
    done
}

usage() {
    cat << 'EOF'
🕹️  TUIOS CONTROL CENTER — Central Interativa de Alta Produtividade

USO:
    tuios-control-center.sh [comando]

COMANDOS:
    (sem argumentos)   Inicia o menu TUI interativo completo (Gum / FZF)
    dispatch           Abre o fluxo de despacho de tarefa para operários
    verify             Abre o verificador formal de contratos PLAN.md
    breakers           Abre o painel de inspeção de disjuntores e destravamento
    ast                Abre o navegador de nós sintáticos Gira-G
    receipts           Abre o explorador interativo do ledger criptográfico
    hermes             Inicia sessão Hermes com perfil formal
    web                Gerencia o Web Dashboard (:4242)
    help, -h, --help   Exibe esta mensagem de ajuda

ATALHOS NO TUIOS:
    Alt + M            Abre esta central em um Popup flutuante sobre qualquer workspace
    Ctrl + P           Acessa "Centro de Controle Homelab" na paleta de comandos
EOF
    exit 0
}

# Suporte a argumentos diretos:
# Ex: tuios-control-center.sh verify | dispatch | breakers | ast | receipts
case "${1:-}" in
    -h|--help|help)
        usage
        ;;
    header)
        render_header
        ;;
    verify)
        render_header
        action_verify_plan
        ;;
    dispatch)
        render_header
        action_dispatch_task
        ;;
    breakers)
        render_header
        action_breakers_and_overrides
        ;;
    ast)
        render_header
        action_gira_ast_browser
        ;;
    receipts)
        render_header
        action_receipts_history
        ;;
    hermes)
        action_hermes_chat
        ;;
    web)
        action_web_dashboard
        ;;
    *)
        main
        ;;
esac

#!/bin/bash

# Menu Local - Gestion des tunnels SSH vers un serveur ShipGlows
# Accès rapide aux projets distants via tunnels SSH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
LIGHT_BLUE='\033[38;5;117m'
LIGHT_PURPLE='\033[38;5;141m'
NC='\033[0m' # No Color

# Configuration file for saved connections
shipglows_migrate_local_config || true
CONFIG_DIR="$(shipglows_local_config_dir)"
CONNECTIONS_FILE="$CONFIG_DIR/connections.conf"
CURRENT_CONNECTION_FILE="$CONFIG_DIR/current_connection"
CURRENT_IDENTITY_FILE="$CONFIG_DIR/current_identity_file"
CURRENT_AUTH_METHOD_FILE="$CONFIG_DIR/current_auth_method"

# Initialize config directory
mkdir -p "$CONFIG_DIR" 2>/dev/null

# Load or set default connection
load_current_connection() {
    if REMOTE_HOST="$(shipglows_read_config_value current_connection 2>/dev/null)"; then
        :
    elif [ -n "${SHIPGLOWS_SSH_REMOTE_HOST:-${SHIPGLOWS_SSH_REMOTE_HOST:-}}" ]; then
        REMOTE_HOST="${SHIPGLOWS_SSH_REMOTE_HOST:-${SHIPGLOWS_SSH_REMOTE_HOST:-}}"
    elif grep -qE '^[[:space:]]*Host[[:space:]]+hetzner([[:space:]]|$)' "$HOME/.ssh/config" 2>/dev/null; then
        REMOTE_HOST="hetzner"
    else
        REMOTE_HOST=""
    fi

    if SSH_IDENTITY_FILE="$(shipglows_read_config_value current_identity_file 2>/dev/null)"; then
        :
    else
        SSH_IDENTITY_FILE=""
    fi

    if SSH_AUTH_METHOD="$(shipglows_read_config_value current_auth_method 2>/dev/null)"; then
        :
    else
        SSH_AUTH_METHOD="key"
    fi
}

# Save current connection
save_current_connection() {
    shipglows_write_config_value current_connection "$REMOTE_HOST"
}

save_identity_file() {
    local identity_file="$1"
    if [ -n "$identity_file" ]; then
        echo "$identity_file" > "$CURRENT_IDENTITY_FILE"
        chmod 600 "$CURRENT_IDENTITY_FILE" 2>/dev/null || true
    else
        rm -f "$CURRENT_IDENTITY_FILE"
    fi
}

save_auth_method() {
    local auth_method="$1"
    if [ -n "$auth_method" ]; then
        echo "$auth_method" > "$CURRENT_AUTH_METHOD_FILE"
        chmod 600 "$CURRENT_AUTH_METHOD_FILE" 2>/dev/null || true
    else
        rm -f "$CURRENT_AUTH_METHOD_FILE"
    fi
}

# Add connection to saved list
add_saved_connection() {
    local connection="$1"
    local auth_method="${2:-key}"
    local identity_file="${3:-}"

    # Create file if not exists
    touch "$CONNECTIONS_FILE"

    auth_method="$(normalize_menu_choice "$auth_method")"
    case "$auth_method" in
        password|key) ;;
        *)
            auth_method="key"
            ;;
    esac

    if [ "$auth_method" = "password" ]; then
        identity_file=""
    fi

    local record="${connection}|${auth_method}|${identity_file}"

    awk -F'|' -v target="$connection" 'BEGIN { OFS="|" } $1 != target { print $0 }' "$CONNECTIONS_FILE" > "$CONNECTIONS_FILE.tmp" 2>/dev/null || true
    mv "$CONNECTIONS_FILE.tmp" "$CONNECTIONS_FILE" 2>/dev/null || true
    echo "$record" >> "$CONNECTIONS_FILE"
}

promote_connection_state_to_key() {
    local target="$1"
    local identity_file="$2"
    local resolved_identity state_backup state_stage
    resolved_identity="$(resolve_identity_path "$identity_file")" || return 1
    mkdir -p "$CONFIG_DIR" || return 1
    chmod 700 "$CONFIG_DIR" 2>/dev/null || true
    state_backup="$(mktemp -d "$CONFIG_DIR/.state-backup.XXXXXX")" || return 1
    state_stage="$(mktemp -d "$CONFIG_DIR/.state-stage.XXXXXX")" || {
        rm -rf "$state_backup"
        return 1
    }

    local file name
    for file in "$CURRENT_AUTH_METHOD_FILE" "$CURRENT_IDENTITY_FILE" "$CONNECTIONS_FILE"; do
        name="${file##*/}"
        if [ -e "$file" ]; then
            cp -p "$file" "$state_backup/$name" || {
                rm -rf "$state_backup" "$state_stage"
                return 1
            }
        else
            touch "$state_backup/$name.absent"
        fi
    done

    if ! printf '%s\n' key > "$state_stage/current_auth_method" ||
        ! printf '%s\n' "$resolved_identity" > "$state_stage/current_identity_file"; then
        rm -rf "$state_backup" "$state_stage"
        return 1
    fi
    if [ -f "$CONNECTIONS_FILE" ]; then
        if ! awk -F'|' -v connection="$target" '$1 != connection { print $0 }' "$CONNECTIONS_FILE" > "$state_stage/connections.conf"; then
            rm -rf "$state_backup" "$state_stage"
            return 1
        fi
    else
        : > "$state_stage/connections.conf"
    fi
    if ! printf '%s|key|%s\n' "$target" "$resolved_identity" >> "$state_stage/connections.conf"; then
        rm -rf "$state_backup" "$state_stage"
        return 1
    fi
    chmod 600 "$state_stage/current_auth_method" "$state_stage/current_identity_file" "$state_stage/connections.conf" 2>/dev/null || true

    local failed=0
    mv "$state_stage/current_auth_method" "$CURRENT_AUTH_METHOD_FILE" || failed=1
    [ "$failed" -eq 0 ] && mv "$state_stage/current_identity_file" "$CURRENT_IDENTITY_FILE" || failed=1
    [ "$failed" -eq 0 ] && mv "$state_stage/connections.conf" "$CONNECTIONS_FILE" || failed=1

    if [ "$failed" -ne 0 ]; then
        for file in "$CURRENT_AUTH_METHOD_FILE" "$CURRENT_IDENTITY_FILE" "$CONNECTIONS_FILE"; do
            name="${file##*/}"
            if [ -f "$state_backup/$name" ]; then
                cp -p "$state_backup/$name" "$file" 2>/dev/null || true
            else
                rm -f "$file"
            fi
        done
        rm -rf "$state_backup" "$state_stage"
        return 1
    fi

    rm -rf "$state_backup" "$state_stage"
    return 0
}

# Get saved connections
get_saved_connections() {
    if [ -f "$CONNECTIONS_FILE" ]; then
        cat "$CONNECTIONS_FILE" | sort -u
    fi
}

prompt_inline() {
    printf "%b" "$1"
}

local_center_fixed_width() {
    local text="$1"
    local width="${2:-46}"
    local text_len=${#text}

    if [ "$text_len" -ge "$width" ]; then
        printf "%s" "${text:0:$width}"
        return
    fi

    local left_pad=$(( (width - text_len) / 2 ))
    local right_pad=$(( width - text_len - left_pad ))
    printf "%*s%s%*s" "$left_pad" "" "$text" "$right_pad" ""
}

local_screen_header() {
    local title="$1"
    local variant="${2:-default}"
    local border_color="$CYAN"
    local title_color="$YELLOW"
    local brand="ShipGlows DevServer"
    local content_width=50
    local inner_width=46

    case "$variant" in
        danger)
            border_color="$RED"
            title_color="$YELLOW"
            ;;
        success)
            border_color="$GREEN"
            title_color="$GREEN"
            ;;
    esac

    if [ ${#title} -gt "$inner_width" ]; then
        title="${title:0:$inner_width}"
    fi

    local rule=""
    local i
    for ((i=0; i<content_width; i++)); do
        rule+="═"
    done

    printf "%b╔%s╗%b\n" "$border_color" "$rule" "$NC"
    printf "%b║%50s║%b\n" "$border_color" "" "$NC"
    printf "%b║  %b%s%b  ║%b\n" "$border_color" "$YELLOW" "$(local_center_fixed_width "$brand" "$inner_width")" "$border_color" "$NC"
    printf "%b║  %b%s%b  ║%b\n" "$border_color" "$title_color" "$(local_center_fixed_width "$title" "$inner_width")" "$border_color" "$NC"
    printf "%b║%50s║%b\n" "$border_color" "" "$NC"
    printf "%b╚%s╝%b\n" "$border_color" "$rule" "$NC"
    echo ""
}

local_menu_line() {
    local key="$1"
    local label="$2"
    echo -e "  ${CYAN}${key})${NC} ${LIGHT_BLUE}${label}${NC}"
}

local_clear_screen() {
    clear
}

trim_input() {
    local value="${1:-}"

    value="${value//$'\r'/}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    printf '%s' "$value"
}

normalize_identity_input() {
    local value
    value="$(trim_input "${1:-}")"

    # The interactive menu reads single-letter shortcuts in other places. If a
    # stray keypress lands after the path, keep the path token the user typed.
    if [[ "$value" == *[[:space:]]* ]]; then
        value="${value%%[[:space:]]*}"
    fi

    printf '%s' "$value"
}

normalize_menu_choice() {
    local choice="${1:-}"

    choice="${choice//$'\r'/}"
    choice="${choice#"${choice%%[![:space:]]*}"}"
    choice="${choice%"${choice##*[![:space:]]}"}"
    choice=$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')

    printf '%s' "$choice"
}

install_ssh_key_for_current_server() {
    local_screen_header "Installer une clé SSH"
    if [ -z "${REMOTE_HOST:-}" ]; then
        echo -e "${RED}✗ Aucun serveur n'est configuré.${NC}"
        echo -e "${YELLOW}  Configure d'abord une connexion avec l'option c.${NC}"
        return 1
    fi

    echo -e "${BLUE}Serveur actuel:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo -e "${YELLOW}La clé privée restera sur cet appareil. Seule la clé publique sera envoyée.${NC}"
    echo -e "${YELLOW}Utilise une clé différente sur chaque appareil.${NC}"
    echo ""
    local_menu_line "e" "Utiliser une clé locale existante"
    local_menu_line "g" "Générer une clé Ed25519 dédiée"
    local_menu_line "x" "Retour"
    echo ""
    prompt_inline "${YELLOW}Choix ?${NC} "
    local key_choice=""
    read_menu_choice key_choice

    local identity_file=""
    case "$key_choice" in
        e)
            prompt_inline "${YELLOW}Chemin de la clé privée locale:${NC} "
            read -r identity_file
            identity_file="$(normalize_identity_input "$identity_file")"
            identity_file="$(resolve_identity_path "$identity_file")" || {
                echo -e "${RED}✗ Clé privée introuvable.${NC}"
                return 1
            }
            ;;
        g)
            echo ""
            echo -e "${YELLOW}La clé dédiée sera créée sans passphrase pour fonctionner avec les tunnels non interactifs.${NC}"
            echo -e "${YELLOW}Son fichier privé sera protégé en lecture pour ton compte uniquement.${NC}"
            prompt_inline "${YELLOW}Continuer ? [o/N]${NC} "
            local generate_confirm=""
            read -r generate_confirm
            generate_confirm="$(normalize_menu_choice "$generate_confirm")"
            case "$generate_confirm" in o|oui|y|yes) ;; *) echo -e "${YELLOW}Génération annulée.${NC}"; return 0 ;; esac
            identity_file="$(generate_shipglows_identity "$REMOTE_HOST")" || {
                echo -e "${RED}✗ Impossible de générer la clé dédiée.${NC}"
                return 1
            }
            echo -e "${GREEN}✓ Clé créée: $identity_file${NC}"
            ;;
        x|q)
            return 0
            ;;
        *)
            echo -e "${RED}✗ Choix invalide.${NC}"
            return 1
            ;;
    esac

    local public_key_file
    public_key_file="$(mktemp "${TMPDIR:-/tmp}/shipglows-public-key.XXXXXX")" || return 1
    chmod 600 "$public_key_file" 2>/dev/null || true
    if ! prepare_identity_public_key "$identity_file" "$public_key_file"; then
        rm -f "$public_key_file"
        echo -e "${RED}✗ La clé publique est invalide ou ne correspond pas à la clé privée.${NC}"
        return 1
    fi

    local fingerprint
    fingerprint="$(ssh_public_key_fingerprint "$public_key_file")" || {
        rm -f "$public_key_file"
        echo -e "${RED}✗ Impossible de calculer l'empreinte de la clé.${NC}"
        return 1
    }
    echo -e "${BLUE}Empreinte:${NC} ${GREEN}$fingerprint${NC}"
    prompt_inline "${YELLOW}Installer cette clé publique sur $REMOTE_HOST ? [o/N]${NC} "
    local install_confirm=""
    read -r install_confirm
    install_confirm="$(normalize_menu_choice "$install_confirm")"
    case "$install_confirm" in
        o|oui|y|yes) ;;
        *) rm -f "$public_key_file"; echo -e "${YELLOW}Installation annulée.${NC}"; return 0 ;;
    esac

    echo -e "${BLUE}Installation de la clé publique...${NC}"
    local install_result
    if ! install_result="$(install_remote_ssh_public_key "$public_key_file" 2>&1)"; then
        rm -f "$public_key_file"
        echo -e "${RED}✗ Installation distante impossible.${NC}"
        [ -n "$install_result" ] && echo -e "${YELLOW}  Détail SSH: ${install_result//$'\n'/ }${NC}"
        return 1
    fi
    rm -f "$public_key_file"

    echo -e "${BLUE}Vérification avec une nouvelle connexion par clé uniquement...${NC}"
    if ! verify_ssh_key_only "$identity_file"; then
        echo -e "${RED}✗ La clé a pu être ajoutée, mais la connexion par clé seule a échoué.${NC}"
        echo -e "${YELLOW}  La connexion ShipGlows reste dans son mode précédent.${NC}"
        echo -e "${YELLOW}  Si la clé a une passphrase, charge-la avec: ssh-add $identity_file${NC}"
        return 1
    fi

    if ! promote_connection_state_to_key "$REMOTE_HOST" "$identity_file"; then
        echo -e "${RED}✗ La clé fonctionne, mais l'état local n'a pas pu être mis à jour.${NC}"
        echo -e "${YELLOW}  Relance cette action; la clé publique distante ne sera pas dupliquée.${NC}"
        return 1
    fi

    SSH_AUTH_METHOD="key"
    SSH_IDENTITY_FILE="$(resolve_identity_path "$identity_file")"
    echo -e "${GREEN}✓ Connexion promue vers la clé SSH ($install_result).${NC}"
    echo -e "${GREEN}✓ Les tunnels utiliseront désormais cette clé sans mot de passe serveur.${NC}"
    if sync_standard_ssh_identity "$REMOTE_HOST" "$SSH_IDENTITY_FILE"; then
        echo -e "${GREEN}✓ Les commandes ssh et mosh utiliseront aussi cette clé pour cet hôte.${NC}"
    else
        echo -e "${YELLOW}⚠ La clé ShipGlows fonctionne, mais ~/.ssh/config n'a pas pu être mis à jour.${NC}"
        echo -e "${YELLOW}  Pour SSH/Mosh direct, utilise: ssh -i $SSH_IDENTITY_FILE $REMOTE_HOST${NC}"
    fi
}

print_remote_app_warmup_hint() {
    local port="$1"
    local name="$2"

    echo -e "    ${YELLOW}Le tunnel peut être créé avant que l'app distante écoute vraiment.${NC}"
    echo -e "    ${YELLOW}Si ${name} reconstruit Flutter Web, attendez dans les logs PM2 :${NC}"
    echo -e "      ${CYAN}pm2 logs ${name} --lines 50${NC}"
    echo -e "      ${GREEN}✓ Built build/web${NC}"
    echo -e "      ${GREEN}... serving on http://localhost:${port}${NC}"
    echo -e "    ${YELLOW}Puis relancez urls/tunnel.${NC}"
}

menu_letter_key() {
    local index="$1"
    local alphabet="abcdefghijklmopqrstuvwyz"
    local base=${#alphabet}
    local key=""
    local n="$index"

    while true; do
        local rem=$((n % base))
        key="${alphabet:rem:1}${key}"
        n=$((n / base - 1))
        [ "$n" -lt 0 ] && break
    done

    printf '%s' "$key"
}

read_menu_choice() {
    local target_var="$1"
    local allow_two_chars="${2:-false}"
    local value=""
    local next=""

    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        read -rsn1 value < /dev/tty
        if [ "$allow_two_chars" = true ] && [[ "$value" =~ ^[[:alnum:]]$ ]]; then
            if read -rsn1 -t 0.25 next < /dev/tty 2>/dev/null && [[ "$next" =~ ^[[:alnum:]]$ ]]; then
                value="${value}${next}"
            fi
        fi
        while read -rsn1 -t 0.05 _ < /dev/tty 2>/dev/null; do :; done
        printf '\n' > /dev/tty
    else
        read -r value
    fi

    value=$(normalize_menu_choice "$value")
    printf -v "$target_var" '%s' "$value"
}

save_and_activate_connection() {
    local target="$1"
    local identity_file="${2-}"
    local auth_method="${3:-key}"

    if ! validate_connection_target "$target"; then
        echo -e "${RED}✗ Cible invalide: $target${NC}"
        echo -e "${YELLOW}  Format attendu: IP, domaine avec un point, alias SSH défini dans ~/.ssh/config, ou user@host.${NC}"
        return 1
    fi

    auth_method="$(normalize_menu_choice "$auth_method")"
    case "$auth_method" in
        password|key) ;;
        *)
            auth_method="key"
            ;;
    esac

    if [ "$auth_method" != "password" ] && ! validate_identity_file "$identity_file"; then
        echo -e "${RED}✗ Clé SSH invalide ou introuvable: $identity_file${NC}"
        echo -e "${YELLOW}  Si tu entres seulement un nom de fichier, ShipGlows cherche dans le dossier courant, ~/.ssh/ puis ton dossier home.${NC}"
        echo -e "${YELLOW}  Laisse vide pour utiliser la configuration SSH normale.${NC}"
        return 1
    fi

    if [ "$auth_method" = "password" ]; then
        identity_file=""
    elif [ -n "$identity_file" ]; then
        identity_file=$(resolve_identity_path "$identity_file")
        chmod 600 "$identity_file" 2>/dev/null || true
    fi

    echo ""
    echo -e "${BLUE}Test SSH vers $target...${NC}"
    SSH_AUTH_METHOD="$auth_method"
    SSH_IDENTITY_FILE="$identity_file"
    local previous_remote_host="$REMOTE_HOST"
    REMOTE_HOST="$target"
    local ssh_output=""
    if ssh_output=$(run_remote_ssh "echo ok" 2>&1); then
        echo -e "${GREEN}✓ Connexion réussie${NC}"
        REMOTE_HOST="$target"
        SSH_IDENTITY_FILE="$identity_file"
        SSH_AUTH_METHOD="$auth_method"
        save_current_connection
        save_identity_file "$identity_file"
        save_auth_method "$auth_method"
        chmod 600 "$CURRENT_CONNECTION_FILE" 2>/dev/null || true
        add_saved_connection "$target" "$auth_method" "$identity_file"
        CACHED_SESSION_INFO=""
        CACHED_SESSION_TIME=0
        if [ "$auth_method" = "password" ]; then
            echo -e "${GREEN}✓ Serveur actif enregistré pour urls, tunnel, shipglows-mcp-login, Clerk et Blacksmith (mot de passe)${NC}"
        else
            echo -e "${GREEN}✓ Serveur actif enregistré pour urls, tunnel, shipglows-mcp-login, Clerk et Blacksmith${NC}"
        fi
        return 0
    fi

    REMOTE_HOST="$previous_remote_host"
    echo -e "${RED}✗ Connexion impossible vers $target${NC}"
    if [ -n "$ssh_output" ]; then
        echo -e "${YELLOW}  Détail SSH: ${ssh_output//$'\n'/ }${NC}"
    fi
    if [ "$auth_method" = "password" ]; then
        echo -e "${YELLOW}  Vérifiez l'IP, l'utilisateur SSH et le mot de passe autorisé sur le serveur.${NC}"
    else
        echo -e "${YELLOW}  Vérifiez l'IP, l'utilisateur SSH et la clé autorisée sur le serveur.${NC}"
    fi
    return 1
}

prompt_auth_method() {
    local auth_method=""

    echo "" >&2
    echo -e "${BLUE}Choisis la méthode d'authentification SSH.${NC}" >&2
    echo -e "${YELLOW}La clé SSH/agent reste le mode par défaut. Le mot de passe ouvre une invite SSH interactive et ne stocke aucun secret.${NC}" >&2
    local_menu_line "k" "🔑 Clé SSH / agent" >&2
    local_menu_line "p" "🔓 Mot de passe SSH" >&2
    echo "" >&2
    prompt_inline "${YELLOW}Méthode d'authentification ?${NC} " >&2
    read_menu_choice auth_choice true

    case "$auth_choice" in
        p|password)
            auth_method="password"
            ;;
        k|""|key)
            auth_method="key"
            ;;
        *)
            echo -e "${YELLOW}Choix non reconnu; clé SSH/agent par défaut.${NC}" >&2
            auth_method="key"
            ;;
    esac

    printf '%s' "$auth_method"
}

configure_new_server() {
    local_screen_header "Configurer un nouveau serveur"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}${REMOTE_HOST:-non configurée}${NC}"
    echo ""
    echo -e "${BLUE}ShipGlows va enregistrer l'adresse SSH du nouveau serveur.${NC}"
    echo -e "${BLUE}Tu peux entrer une IP, un domaine, un alias SSH déjà défini, ou directement user@host.${NC}"
    echo -e "${YELLOW}Exemples:${NC} 203.0.113.10, mon-serveur.com, hetzner, ubuntu@203.0.113.10"
    echo ""
    prompt_inline "${YELLOW}Adresse IP ou host du nouveau serveur:${NC} "
    read -r server_host
    server_host="$(trim_input "$server_host")"
    if [ -z "$server_host" ]; then
        echo -e "${RED}✗ Adresse vide${NC}"
        return 1
    fi

    if [[ "$server_host" == *"@"* ]]; then
        if ! validate_connection_target "$server_host"; then
            echo -e "${RED}✗ Adresse invalide: $server_host${NC}"
            echo -e "${YELLOW}  Utilise user@IP, user@domaine.tld, ou user@alias-ssh déjà défini dans ~/.ssh/config.${NC}"
            return 1
        fi
    elif ! validate_connection_host "$server_host"; then
        echo -e "${RED}✗ Adresse invalide: $server_host${NC}"
        echo -e "${YELLOW}  Entre une IP valide, un domaine avec un point, ou un alias SSH déjà défini dans ~/.ssh/config.${NC}"
        return 1
    fi

    local target=""
    if [[ "$server_host" == *"@"* ]]; then
        target="$server_host"
        echo -e "${BLUE}Utilisateur SSH détecté dans l'adresse: ${GREEN}${target%%@*}${NC}"
    else
        echo ""
        echo -e "${BLUE}L'utilisateur SSH est le compte Linux utilisé pour te connecter au serveur. Sur beaucoup de serveurs Ubuntu cloud, c'est ${GREEN}ubuntu${BLUE}. Selon l'hébergeur, ça peut aussi être ${GREEN}root${BLUE}, ${GREEN}debian${BLUE}, ${GREEN}ec2-user${BLUE}, etc.${NC}"
        echo -e "${YELLOW}Laisse vide pour utiliser la valeur par défaut : ${GREEN}ubuntu${YELLOW}.${NC}"
        echo -e "${YELLOW}Si le test échoue, réessaie avec l'utilisateur indiqué par ton hébergeur.${NC}"
        prompt_inline "${YELLOW}Utilisateur SSH:${NC} "
        read -r server_user
        server_user="$(trim_input "$server_user")"
        if [ -n "$server_user" ] && ! validate_ssh_user "$server_user"; then
            echo -e "${RED}✗ Utilisateur SSH invalide: $server_user${NC}"
            echo -e "${YELLOW}  Utilise seulement lettres, chiffres, point, tiret ou underscore.${NC}"
            return 1
        fi
        server_user="${server_user:-ubuntu}"
        target="${server_user}@${server_host}"
    fi

    local auth_method
    auth_method="$(prompt_auth_method)"

    local identity_file=""
    if [ "$auth_method" != "password" ]; then
        echo ""
        echo -e "${BLUE}La clé SSH est le fichier privé utilisé si ta connexion demande une clé spéciale.${NC}"
        echo -e "${BLUE}Exemple: ~/.ssh/id_ed25519${NC}"
        echo -e "${YELLOW}Laisse vide pour utiliser la valeur par défaut : connexion SSH normale.${NC}"
        prompt_inline "${YELLOW}Chemin de la clé SSH si tu l'as enregistrée dans un dossier particulier ou avec un nom spécifique:${NC} "
        read -r identity_file
        identity_file="$(normalize_identity_input "$identity_file")"
        if [ -n "$identity_file" ]; then
            echo -e "${BLUE}Clé SSH utilisée:${NC} ${GREEN}$identity_file${NC}"
        fi
    else
        echo ""
        echo -e "${BLUE}Le mode mot de passe gardera la connexion sans clé SSH enregistrée.${NC}"
    fi

    echo ""
    echo -e "${BLUE}Connexion qui va être testée:${NC} ${GREEN}$target${NC}"
    if [ "$auth_method" = "password" ]; then
        echo -e "${BLUE}Méthode: ${GREEN}mot de passe SSH${NC}"
    else
        echo -e "${BLUE}Méthode: ${GREEN}clé SSH / agent${NC}"
    fi
    if ! save_and_activate_connection "$target" "$identity_file" "$auth_method"; then
        return 1
    fi

    if [ "$auth_method" = "password" ]; then
        echo ""
        prompt_inline "${YELLOW}Installer maintenant une clé SSH pour ne plus saisir le mot de passe ? [o/N]${NC} "
        local promote_now=""
        read -r promote_now
        promote_now="$(normalize_menu_choice "$promote_now")"
        case "$promote_now" in
            o|oui|y|yes)
                install_ssh_key_for_current_server
                ;;
        esac
    fi
    return 0
}

# Menu to select/add connection
select_connection() {
    local_screen_header "Gestion des connexions"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}${REMOTE_HOST:-non configurée}${NC}"
    echo ""

    # Get saved connections
    local saved=$(get_saved_connections)
    local options=()
    local keys=()
    local i=1

    echo -e "${BLUE}Connexions enregistrées:${NC}"
    echo ""

    if [ -n "$saved" ]; then
        while IFS= read -r conn; do
            [ -n "$conn" ] || continue
            local conn_target="$conn"
            local conn_auth_method="key"
            local conn_identity_file=""
            if [[ "$conn" == *"|"* ]]; then
                IFS='|' read -r conn_target conn_auth_method conn_identity_file <<< "$conn"
            fi
            local key
            key=$(menu_letter_key $((i - 1)))
            local auth_label="clé SSH/agent"
            if [ "$conn_auth_method" = "password" ]; then
                auth_label="mot de passe"
            fi
            if [ "$conn_target" = "$REMOTE_HOST" ]; then
                echo -e "  ${CYAN}$key)${NC} ${LIGHT_BLUE}$conn_target${NC} ${YELLOW}[${auth_label}]${NC} ${GREEN}(actuel)${NC}"
            else
                echo -e "  ${CYAN}$key)${NC} ${LIGHT_BLUE}$conn_target${NC} ${YELLOW}[${auth_label}]${NC}"
            fi
            options+=("${conn_target}|${conn_auth_method}|${conn_identity_file}")
            keys+=("$key")
            ((i++))
        done <<< "$saved"
    else
        echo -e "  ${YELLOW}Aucune connexion enregistrée${NC}"
    fi

    echo ""
    local_menu_line "n" "➕ Nouvelle connexion"
    local_menu_line "x" "← Retour"
    echo ""
    prompt_inline "${YELLOW}Tape la lettre de ton choix ?${NC} "
    read_menu_choice choice true

    case "$choice" in
        x|q)
            return 0
            ;;
        n)
            configure_new_server
            ;;
        *)
            local idx=-1
            for ((i=0; i<${#keys[@]}; i++)); do
                if [ "$choice" = "${keys[$i]}" ]; then
                    idx=$i
                    break
                fi
            done

            if [ "$idx" -ge 0 ]; then
                local selected_record="${options[$idx]}"
                local selected_target=""
                local selected_auth_method="key"
                local selected_identity_file=""
                IFS='|' read -r selected_target selected_auth_method selected_identity_file <<< "$selected_record"
                save_and_activate_connection "$selected_target" "$selected_identity_file" "$selected_auth_method" || pause
            else
                echo -e "${RED}❌ Choix invalide${NC}"
                pause
            fi
            ;;
    esac
}

# Load connection at startup
load_current_connection

# Cached session info (to avoid repeated SSH calls)
CACHED_SESSION_INFO=""
CACHED_SESSION_TIME=0

# Function to retrieve server session info from canonical ShipGlows install paths
fetch_server_session_info() {
    if [ -z "$REMOTE_HOST" ]; then
        echo SESSION_NOT_CONFIGURED
        return 0
    fi

    run_remote_ssh "bash -lc '
        for lib_path in \
            \"\${SHIPGLOWS_ROOT:-\$HOME/shipglows}/lib.sh\"
        do
            if [ -f \"\$lib_path\" ]; then
                source \"\$lib_path\" 2>/dev/null
                get_session_info_for_ssh 2>/dev/null
                exit 0
            fi
        done

        echo SESSION_NOT_FOUND
    '" 2>&1
}

should_show_session_scan_loader() {
    [ -n "$REMOTE_HOST" ] || return 1
    [ "${SHIPGLOWS_NO_ANIMATION:-${SHIPGLOWS_NO_ANIMATION:-}}" != "1" ] || return 1
    [ "${TERM:-}" != "dumb" ] || return 1
    [ -w /dev/tty ] 2>/dev/null || return 1
}

render_session_scan_frame() {
    local frame="$1"
    local scan_cap scan_upper scan_top scan_mid scan_bottom scan_lower scan_base
    local host_label="${REMOTE_HOST:-serveur}"

    if [ "${#host_label}" -gt 22 ]; then
        host_label="${host_label:0:19}..."
    fi

    case $((frame % 4)) in
        0)
            scan_cap="     |  "
            scan_upper="      |     "
            scan_top="       |      "
            scan_mid="-------o------"
            scan_bottom="       |      "
            scan_lower="      |     "
            scan_base="     |  "
            ;;
        1)
            scan_cap="       /"
            scan_upper="        /   "
            scan_top="        /     "
            scan_mid="-------o------"
            scan_bottom="      /       "
            scan_lower="    /       "
            scan_base="/       "
            ;;
        2)
            scan_cap="        "
            scan_upper="            "
            scan_top="              "
            scan_mid="-------o------"
            scan_bottom="              "
            scan_lower="            "
            scan_base="        "
            ;;
        *)
            scan_cap="\\       "
            scan_upper="    \\       "
            scan_top="      \\       "
            scan_mid="-------o------"
            scan_bottom="        \\     "
            scan_lower="        \\   "
            scan_base="       \\"
            ;;
    esac

    printf "\033[2K\r%b\n" "${CYAN}      .------------------------.${NC}" > /dev/tty
    printf "\033[2K\r%b\n" "${CYAN}      |${NC}${BLUE} SONAR SSH${NC}${YELLOW}  scan réseau ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b\n" "${CYAN}      |${NC}        .------.        ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b\n" "${CYAN}      |${NC}      .'${GREEN}" "$scan_cap" "${NC}'.      ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b\n" "${CYAN}      |${NC}     /${GREEN}" "$scan_upper" "${NC}\\     ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b\n" "${CYAN}      |${NC}    |${GREEN}" "$scan_top" "${NC}|    ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b\n" "${CYAN}      |${NC}    |${GREEN}" "$scan_mid" "${NC}|    ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b\n" "${CYAN}      |${NC}    |${GREEN}" "$scan_bottom" "${NC}|    ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b%s%b\n" "${CYAN}      |${NC}     " "\\" "${GREEN}" "$scan_lower" "${NC}/     ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b%s%b\n" "${CYAN}      |${NC}      '.${GREEN}" "$scan_base" "${NC}.'      ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b\n" "${CYAN}      |${NC}        '------'        ${CYAN}|${NC}" > /dev/tty
    printf "\033[2K\r%b\n" "${CYAN}      '------------------------'${NC}" > /dev/tty
    printf "\033[2K\r%b\n" "${BLUE}      Recherche SSH: ${GREEN}${host_label}${BLUE}...${NC}" > /dev/tty
}

clear_session_scan_loader() {
    local lines=13
    local i=0

    printf "\033[%sA\r" "$lines" > /dev/tty
    while [ "$i" -lt "$lines" ]; do
        printf "\033[2K\r" > /dev/tty
        [ "$i" -lt $((lines - 1)) ] && printf "\n" > /dev/tty
        i=$((i + 1))
    done
    printf "\033[%sA\r" "$((lines - 1))" > /dev/tty
}

cleanup_session_scan_loader_state() {
    local fetch_pid="${1:-}"
    local tmp_file="${2:-}"
    local rendered="${3:-0}"

    [ -n "$fetch_pid" ] && kill "$fetch_pid" 2>/dev/null || true
    [ "$rendered" = "1" ] && clear_session_scan_loader 2>/dev/null || true
    printf "\033[?25h" > /dev/tty 2>/dev/null || true
    [ -n "$tmp_file" ] && rm -f "$tmp_file"
}

fetch_server_session_info_with_loader() {
    local tmp_file=""
    local fetch_pid=""
    local frame=0
    local rendered_frame=0
    local status=0

    tmp_file=$(mktemp "${TMPDIR:-/tmp}/shipglows-session.XXXXXX") || {
        fetch_server_session_info
        return
    }

    trap 'status=$?; cleanup_session_scan_loader_state "$fetch_pid" "$tmp_file" "$rendered_frame"; exit "$status"' INT TERM

    fetch_server_session_info > "$tmp_file" &
    fetch_pid=$!

    printf "\033[?25l" > /dev/tty
    while kill -0 "$fetch_pid" 2>/dev/null; do
        [ "$frame" -gt 0 ] && printf "\033[13A\r" > /dev/tty
        render_session_scan_frame "$frame"
        rendered_frame=1
        frame=$((frame + 1))
        sleep 0.18
    done

    wait "$fetch_pid" || status=$?
    [ "$rendered_frame" = "1" ] && clear_session_scan_loader
    printf "\033[?25h" > /dev/tty
    trap - INT TERM

    cat "$tmp_file"
    rm -f "$tmp_file"
    return "$status"
}

# Function to retrieve server session info (with caching)
get_server_session_info() {
    local target_var="${1:-}"
    local current_time=$(date +%s)
    local cache_ttl=300  # Cache for 5 minutes

    # Return cached info if fresh
    if [ -n "$CACHED_SESSION_INFO" ] && [ $((current_time - CACHED_SESSION_TIME)) -lt $cache_ttl ]; then
        if [ -n "$target_var" ]; then
            printf -v "$target_var" '%s' "$CACHED_SESSION_INFO"
        else
            echo "$CACHED_SESSION_INFO"
        fi
        return 0
    fi

    # Retrieve session info from server
    if should_show_session_scan_loader; then
        CACHED_SESSION_INFO=$(fetch_server_session_info_with_loader)
    else
        CACHED_SESSION_INFO=$(fetch_server_session_info)
    fi

    CACHED_SESSION_TIME=$current_time
    if [ -n "$target_var" ]; then
        printf -v "$target_var" '%s' "$CACHED_SESSION_INFO"
    else
        echo "$CACHED_SESSION_INFO"
    fi
}

center_session_banner_text() {
    local text="$1"
    local width="${2:-50}"
    local text_len=${#text}

    if [ "$text_len" -ge "$width" ]; then
        printf "%s" "$text"
        return
    fi

    local pad=$(( (width - text_len) / 2 ))
    printf "%*s%s" "$pad" "" "$text"
}

# Function to display server session banner
display_server_session_banner() {
    local session_info=""
    get_server_session_info session_info

    if echo "$session_info" | grep -q "SESSION_START"; then
        # Parse session info
        local session_user=$(echo "$session_info" | grep "^USER:" | cut -d: -f2)
        local session_host=$(echo "$session_info" | grep "^HOST:" | cut -d: -f2)
        local session_code=$(echo "$session_info" | grep "^CODE:" | cut -d: -f2)
        local hash_art=$(echo "$session_info" | sed -n '/---HASH_ART_START---/,/---HASH_ART_END---/p' | grep -v "^---")

        echo -e "${LIGHT_PURPLE}$(center_session_banner_text "Server Session Identity")${NC}"
        echo -e "${CYAN}══════════════════════════════════════════════════${NC}"

        # Display hash art
        while IFS= read -r line; do
            echo -e "              ${BLUE}$line${NC}"
        done <<< "$hash_art"

        echo -e "${GREEN}$(center_session_banner_text "$session_user@$session_host")${NC}"
        echo -e "${LIGHT_BLUE}$(center_session_banner_text "$session_code")${NC}"
        echo -e "${YELLOW}──────────────────────────────────────────────────${NC}"
    elif echo "$session_info" | grep -q "SESSION_NOT_FOUND"; then
        echo -e "${YELLOW}⚠ Session identity unavailable (ShipGlows not found on server)${NC}"
    elif echo "$session_info" | grep -q "SESSION_NOT_CONFIGURED"; then
        echo -e "${YELLOW}⚠ Connexion distante non configurée${NC}"
    elif [ -z "$session_info" ]; then
        echo -e "${YELLOW}⚠ Could not connect to server${NC}"
    else
        echo -e "${YELLOW}⚠ Could not connect to server${NC}"
        echo -e "${YELLOW}  Détail SSH: ${session_info//$'\n'/ }${NC}"
    fi
}

# Fonction d'affichage avec couleurs
print_header() {
    local_screen_header "Gestionnaire de session"

    # Display server session identity (includes user@host info)
    display_server_session_banner
}

# Fonction d'affichage du menu
show_menu() {
    echo -e "${YELLOW}Choisissez une option :${NC}"
    if [ -z "$REMOTE_HOST" ]; then
        echo -e "${YELLOW}Connexion distante non configurée. Choisissez c pour ajouter le nouveau serveur.${NC}"
    fi
    echo ""
    local_menu_line "t" "🚀 Démarrer une session"
    local_menu_line "u" "📋 Voir les adresses des projets"
    local_menu_line "a" "🛑 Terminer la session"
    local_menu_line "s" "📊 Voir l'état de la session"
    local_menu_line "r" "🔄 Relancer la session"
    local_menu_line "c" "🌐 Choisir un serveur"
    local_menu_line "k" "🔑 Sécuriser l'accès à ce serveur"
    local_menu_line "o" "🔐 Authentifications distantes"
    echo ""
    local_menu_line "l" "🔌 Choisir une connexion enregistrée"
    local_menu_line "x" "❌ Quitter"
    echo ""
}

tunnel_watch_pid_file() {
    printf '%s/tunnel-watch.pid\n' "$CONFIG_DIR"
}

tunnel_watch_status() {
    local pid_file pid
    pid_file="$(tunnel_watch_pid_file)"
    pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        return 0
    fi
    rm -f "$pid_file"
    return 1
}

start_tunnel_watch() {
    local pid_file pid
    pid_file="$(tunnel_watch_pid_file)"
    tunnel_watch_status && return 0

    if ! command -v autossh >/dev/null 2>&1; then
        echo -e "${RED}✗ autossh est requis pour la synchronisation automatique${NC}"
        return 1
    fi

    nohup "$SCRIPT_DIR/tunnel-watch.sh" >>"$CONFIG_DIR/tunnel-watch.log" 2>&1 &
    pid=$!
    printf '%s\n' "$pid" > "$pid_file"
    chmod 600 "$pid_file" 2>/dev/null || true
    echo -e "${GREEN}✓ Session automatique activée pour $REMOTE_HOST${NC}"
}

stop_tunnel_watch() {
    local pid_file pid
    pid_file="$(tunnel_watch_pid_file)"
    pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [ -n "$pid" ]; then
        kill "$pid" 2>/dev/null || true
    fi
    rm -f "$pid_file"
}

run_mcp_login_menu() {
    local provider=""

    local_screen_header "Login OAuth MCP distant"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    local_menu_line "v" "vercel"
    local_menu_line "s" "supabase"
    local_menu_line "a" "all"
    local_menu_line "c" "custom"
    local_menu_line "x" "retour"
    echo ""
    echo -e "${YELLOW}Clerk CLI et Blacksmith ont leurs flows dédiés dans le menu Authentifications.${NC}"
    echo ""
    prompt_inline "${YELLOW}Tape la lettre de ton choix ?${NC} "
    read_menu_choice login_choice

    case "$login_choice" in
        v) provider="vercel" ;;
        s) provider="supabase" ;;
        a) provider="all" ;;
        c)
            prompt_inline "${YELLOW}Nom du provider MCP:${NC} "
            read -r provider
            provider="$(trim_input "$provider")"
            ;;
        x|q) return 0 ;;
        *)
            echo -e "${RED}❌ Choix invalide${NC}"
            return 1
        ;;
    esac

    if [ "$provider" = "blacksmith" ]; then
        echo ""
        echo -e "${BLUE}Blacksmith n'est pas un MCP Codex officiel dans ShipGlows.${NC}"
        echo -e "${BLUE}Je bascule vers le tunnel OAuth Blacksmith dédié.${NC}"
        echo ""
        "$SCRIPT_DIR/blacksmith-login.sh"
        return $?
    fi

    if [ "$provider" = "clerk-cli" ]; then
        echo ""
        echo -e "${BLUE}Je bascule vers le tunnel OAuth Clerk CLI dédié.${NC}"
        echo ""
        "$SCRIPT_DIR/clerk-login.sh"
        return $?
    fi

    if [ -z "$provider" ]; then
        echo -e "${RED}❌ Provider vide${NC}"
        return 1
    fi

    "$SCRIPT_DIR/mcp-login.sh" "$provider"
}

run_clerk_login_menu() {
    local_screen_header "Login Clerk CLI distant"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    echo -e "${BLUE}Ce flow lance ${GREEN}clerk auth login${BLUE} sur le serveur et ouvre le callback OAuth via tunnel SSH local.${NC}"
    echo -e "${YELLOW}Il corrige le cas où Clerk ouvre une URL localhost depuis une session SSH distante.${NC}"
    echo ""
    "$SCRIPT_DIR/clerk-login.sh"
}

run_blacksmith_login_menu() {
    local_screen_header "Login Blacksmith distant"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    echo -e "${BLUE}Ce flow lance Blacksmith sur le serveur et ouvre le callback OAuth via tunnel SSH local.${NC}"
    echo -e "${YELLOW}Il corrige le cas où Blacksmith affiche une URL localhost qui finit en connection refused.${NC}"
    echo ""
    "$SCRIPT_DIR/blacksmith-login.sh"
}

prompt_turso_project_dir() {
    local project_dir=""

    echo -e "${BLUE}Recherche des environnements Flox contenant Turso côté serveur...${NC}" >&2
    local remote_projects
    remote_projects=$(run_remote_ssh "bash -lc '
        find \"\$HOME\" /home /opt -maxdepth 5 -path \"*/.flox/env/manifest.toml\" -type f 2>/dev/null |
        while IFS= read -r manifest; do
            if grep -Eiq \"(^|[^A-Za-z0-9_-])(turso|turso-cli)([^A-Za-z0-9_-]|\$)\" \"\$manifest\"; then
                project_dir=\${manifest%/.flox/env/manifest.toml}
                printf \"%s\n\" \"\$project_dir\"
            fi
        done |
        sort -u |
        head -20
    '" 2>/dev/null || true)

    if [ -n "$remote_projects" ]; then
        echo -e "${BLUE}Env Turso détectés:${NC}" >&2
        local options=()
        local keys=()
        local i=0
        local detected

        while IFS= read -r detected; do
            [ -n "$detected" ] || continue
            local key
            key=$(menu_letter_key "$i")
            options+=("$detected")
            keys+=("$key")
            echo -e "  ${CYAN}${key})${NC} ${LIGHT_BLUE}$detected${NC}" >&2
            ((i++))
        done <<< "$remote_projects"

        echo -e "  ${CYAN}g)${NC} Turso global / aucun project-dir" >&2
        echo -e "  ${CYAN}m)${NC} Saisir un chemin manuellement" >&2
        echo "" >&2
        printf "%b" "${YELLOW}Choix project-dir Turso ?${NC} " >&2

        local choice=""
        read_menu_choice choice true
        case "$choice" in
            g|"")
                printf ''
                return 0
                ;;
            m)
                ;;
            *)
                local idx
                for ((idx=0; idx<${#keys[@]}; idx++)); do
                    if [ "$choice" = "${keys[$idx]}" ]; then
                        printf '%s' "${options[$idx]}"
                        return 0
                    fi
                done
                echo -e "${YELLOW}Choix non reconnu; saisie manuelle.${NC}" >&2
                ;;
        esac
    fi

    # This helper is called through command substitution; prompts must not go to stdout.
    printf "%b" "${YELLOW}Project-dir Flox distant si Turso n'est pas global (Entrée pour aucun):${NC} " >&2
    read -r project_dir
    project_dir="$(trim_input "$project_dir")"
    printf '%s' "$project_dir"
}

run_turso_login_menu() {
    local project_dir=""

    local_screen_header "Login Turso distant"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    echo -e "${BLUE}Ce flow lance ${GREEN}turso auth login --headless${BLUE} sur le serveur et ouvre ou affiche l'URL locale.${NC}"
    echo -e "${BLUE}Si Turso affiche un token/code long dans le navigateur, ShipGlows te demandera de le coller ensuite.${NC}"
    echo -e "${YELLOW}Turso ne suit pas exactement le même modèle callback que Blacksmith/Supabase; le mode headless est le chemin remote officiel.${NC}"
    echo ""
    project_dir="$(prompt_turso_project_dir)"

    if [ -n "$project_dir" ]; then
        "$SCRIPT_DIR/turso-login.sh" --project-dir "$project_dir"
    else
        "$SCRIPT_DIR/turso-login.sh"
    fi
}

run_turso_checks_menu() {
    local project_dir=""
    local db_name=""

    local_screen_header "Checks Turso distants"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    echo -e "${BLUE}Ce flow vérifie l'auth Turso puis les tables jobs/CustomerPersona sur la base choisie.${NC}"
    echo ""
    prompt_inline "${YELLOW}Nom de base Turso (défaut: contentflow-prod2):${NC} "
    read -r db_name
    db_name="$(trim_input "$db_name")"
    [ -n "$db_name" ] || db_name="contentflow-prod2"
    project_dir="$(prompt_turso_project_dir)"

    if [ -n "$project_dir" ]; then
        "$SCRIPT_DIR/turso-ssh.sh" --no-copy --project-dir "$project_dir" "$db_name"
    else
        "$SCRIPT_DIR/turso-ssh.sh" --no-copy "$db_name"
    fi
}

run_turso_copy_session_menu() {
    local project_dir=""
    local db_name=""

    local_screen_header "Copie session Turso"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    echo -e "${YELLOW}Fallback seulement: ce flow copie ~/.config/turso local vers le serveur.${NC}"
    echo -e "${YELLOW}Préfère Login Turso distant quand c'est possible.${NC}"
    echo ""
    prompt_inline "${YELLOW}Nom de base pour checks après copie (Entrée pour aucun):${NC} "
    read -r db_name
    db_name="$(trim_input "$db_name")"
    project_dir="$(prompt_turso_project_dir)"

    if [ -n "$project_dir" ] && [ -n "$db_name" ]; then
        "$SCRIPT_DIR/turso-ssh.sh" --project-dir "$project_dir" "$db_name"
    elif [ -n "$project_dir" ]; then
        "$SCRIPT_DIR/turso-ssh.sh" --project-dir "$project_dir"
    elif [ -n "$db_name" ]; then
        "$SCRIPT_DIR/turso-ssh.sh" "$db_name"
    else
        "$SCRIPT_DIR/turso-ssh.sh"
    fi
}

run_turso_menu() {
    local login_choice=""

    local_screen_header "Turso distant"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    local_menu_line "l" "Login Turso distant"
    local_menu_line "c" "Checks ContentFlow jobs/CustomerPersona"
    local_menu_line "f" "Fallback: copier la session Turso locale"
    local_menu_line "x" "retour"
    echo ""
    prompt_inline "${YELLOW}Tape la lettre de ton choix ?${NC} "
    read_menu_choice login_choice

    case "$login_choice" in
        l)
            run_turso_login_menu
            ;;
        c)
            run_turso_checks_menu
            ;;
        f)
            run_turso_copy_session_menu
            ;;
        x|q)
            return 0
            ;;
        *)
            echo -e "${RED}❌ Choix invalide${NC}"
            return 1
            ;;
    esac
}

run_auth_menu() {
    local login_choice=""

    local_screen_header "Authentifications distantes"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    local_menu_line "m" "Login OAuth MCP Codex"
    local_menu_line "k" "Login Clerk CLI"
    local_menu_line "b" "Login Blacksmith"
    local_menu_line "t" "Turso - Login et checks"
    local_menu_line "x" "retour"
    echo ""
    prompt_inline "${YELLOW}Tape la lettre de ton choix ?${NC} "
    read_menu_choice login_choice

    case "$login_choice" in
        m)
            run_mcp_login_menu
            ;;
        k)
            run_clerk_login_menu
            ;;
        b)
            run_blacksmith_login_menu
            ;;
        t)
            run_turso_menu
            ;;
        x|q)
            return 0
            ;;
        *)
            echo -e "${RED}❌ Choix invalide${NC}"
            return 1
            ;;
    esac
}

# Fonction pour obtenir les ports actifs
get_active_ports() {
    run_remote_ssh "$(shipglows_remote_pm2_ports_command lines)"
}

# Fonction pour récupérer uniquement les vrais processus de tunnel
get_tunnel_processes() {
    ps -eo pid=,args= | while read -r pid cmd; do
        [ -n "$pid" ] || continue

        case " $cmd " in
            *" $REMOTE_HOST "*) ;;
            *) continue ;;
        esac

        case " $cmd " in
            *" autossh "*"-L "*":127.0.0.1:"*|*"/autossh "*"-L "*":127.0.0.1:"*|*" ssh "*"-N "*"-L "*":127.0.0.1:"*|*"/ssh "*"-N "*"-L "*":127.0.0.1:"*)
                printf "%s %s\n" "$pid" "$cmd"
                ;;
        esac
    done
}

# Fonction pour récupérer uniquement les PIDs des vrais tunnels
get_tunnel_pids() {
    get_tunnel_processes | awk '{print $1}'
}

# Fonction pour vérifier qu'un port local répond
is_local_tunnel_ready() {
    local port="$1"

        if command -v nc &> /dev/null && nc -z 127.0.0.1 "$port" 2>/dev/null; then
        return 0
    fi

    if command -v lsof &> /dev/null && lsof -i :"$port" &> /dev/null; then
        return 0
    fi

    curl -s --connect-timeout 1 "http://127.0.0.1:${port}" &> /dev/null
}

# Fonction pour attendre que les tunnels soient bien levés
verify_tunnels_ready() {
    local ports_data="$1"
    local max_attempts=5
    local attempt=1
    local pending="$ports_data"

    while [ $attempt -le $max_attempts ] && [ -n "$pending" ]; do
        local next_pending=""

        while IFS= read -r line; do
            [ -n "$line" ] || continue
            local port name
            port=$(echo "$line" | cut -d':' -f1)
            name=$(echo "$line" | cut -d':' -f2)

            if ! is_local_tunnel_ready "$port"; then
                next_pending="${next_pending}${line}"$'\n'
            fi
        done <<< "$pending"

        pending=$(printf "%s" "$next_pending" | sed '/^$/d')
        [ -z "$pending" ] && return 0

        sleep 1
        attempt=$((attempt + 1))
    done

    echo "$pending"
    return 1
}

# Fonction pour démarrer les tunnels
start_tunnels() {
    local_screen_header "Démarrage d'une session"

    if [ -z "$REMOTE_HOST" ]; then
        echo -e "${RED}✗ Aucune connexion distante configurée${NC}"
        echo -e "${YELLOW}  Choisissez l'option l pour ajouter votre nouveau serveur.${NC}"
        return 1
    fi
    
    if ! command -v autossh &> /dev/null; then
        echo -e "${RED}✗ Impossible de démarrer la session : un composant local est manquant.${NC}"
        echo -e "${YELLOW}  Lancez l'installation de la configuration locale puis réessayez.${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Préparation de la session...${NC}"
    PIDS=$(get_tunnel_pids)
    if [ -n "$PIDS" ]; then
        echo "$PIDS" | while read -r pid; do
            [ -n "$pid" ] || continue
            kill "$pid" 2>/dev/null || true
        done
    fi
    sleep 1
    
    # Récupérer les ports
    echo -e "${BLUE}Recherche des projets disponibles...${NC}"
    if ! PORTS=$(get_active_ports); then
        echo -e "${RED}✗ Impossible de récupérer les ports du serveur distant${NC}"
        echo -e "${YELLOW}  Vérifiez la connexion au serveur puis réessayez.${NC}"
        return 1
    fi
    
    if [ -z "$PORTS" ]; then
        echo -e "${RED}✗ Aucun port trouvé sur le serveur distant${NC}"
        echo -e "${YELLOW}  Vérifiez que PM2 tourne ou qu'une session Flutter Web tmux est active.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Connexion aux projets...${NC}"

    if ! ensure_reusable_ssh_session; then
        echo -e "${RED}✗ Impossible d'ouvrir la session SSH partagée pour les tunnels.${NC}"
        echo -e "${YELLOW}  Vérifiez l'accès SSH puis relancez.${NC}"
        return 1
    fi
    
    # Créer les tunnels
    while IFS= read -r line; do
        port=$(echo "$line" | cut -d':' -f1)
        name=$(echo "$line" | cut -d':' -f2)
        
        echo -e "${GREEN}  ✓ ${name}${NC}"
        
        local autossh_args=(
            -M 0 -f -N
            -o "ServerAliveInterval=30"
            -o "ServerAliveCountMax=3"
            -o "ExitOnForwardFailure=yes"
            -L "${port}:127.0.0.1:${port}"
        )
        while IFS= read -r arg; do
            autossh_args+=("$arg")
        done < <(ssh_tunnel_args)
        local autossh_output=""
        if ! autossh_output=$(autossh "${autossh_args[@]}" "$REMOTE_HOST" 2>&1); then
            echo -e "${RED}  ✗ Connexion impossible pour ${name}${NC}"
            [ "${SHIPGLOWS_DEBUG:-${SHIPGLOWS_DEBUG:-0}}" = "1" ] && [ -n "$autossh_output" ] && echo -e "${YELLOW}    Détail: ${autossh_output//$'\n'/ }${NC}"
            return 1
        fi
    done <<< "$PORTS"
    
    echo ""
    echo -e "${YELLOW}⏳ Finalisation de la session...${NC}"
    FAILED_TUNNELS=$(verify_tunnels_ready "$PORTS")

    if [ -n "$FAILED_TUNNELS" ]; then
        echo -e "${YELLOW}⚠ Certains tunnels ne répondent pas encore :${NC}"
        while IFS= read -r line; do
            [ -n "$line" ] || continue
            port=$(echo "$line" | cut -d':' -f1)
            name=$(echo "$line" | cut -d':' -f2)
            echo -e "  ${RED}✗${NC} localhost:${port} ${YELLOW}(${name})${NC}"
            print_remote_app_warmup_hint "$port" "$name"
        done <<< "$FAILED_TUNNELS"
        return 1
    fi

    echo -e "${GREEN}✅ Session démarrée${NC}"
    start_tunnel_watch
}

# Fonction pour afficher les URLs
show_urls() {
    local_screen_header "URLs disponibles"
    
    PORTS=$(get_active_ports)
    
    if [ -z "$PORTS" ]; then
        echo -e "${RED}✗ Aucun port trouvé${NC}"
        return 1
    fi
    
    while IFS= read -r line; do
        port=$(echo "$line" | cut -d':' -f1)
        name=$(echo "$line" | cut -d':' -f2)
        
        # Vérifier si le port local est accessible (méthode la plus fiable)
    if command -v nc &> /dev/null && nc -z 127.0.0.1 "$port" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
        elif command -v lsof &> /dev/null && lsof -i :${port} &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
        elif curl -s --connect-timeout 1 http://127.0.0.1:${port} &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
        else
            echo -e "  ${RED}✗${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${RED}[tunnel inactif]${NC}"
        fi
    done <<< "$PORTS"
}

# Fonction pour arrêter les tunnels
stop_tunnels() {
    local_screen_header "Fin de la session" danger
    stop_tunnel_watch
    
    PIDS=$(get_tunnel_pids)
    
    if [ -z "$PIDS" ]; then
        echo -e "${YELLOW}⚠ Aucune session active trouvée${NC}"
        if [ "${SHIPGLOWS_DEBUG:-${SHIPGLOWS_DEBUG:-0}}" = "1" ]; then
            echo ""
            echo -e "${BLUE}💡 Processus SSH en cours:${NC}"
            ps aux | grep ssh | grep -v grep | grep -v ssh-agent || true
        fi
    else
        echo "$PIDS" | while read -r pid; do
            if kill "$pid" 2>/dev/null; then
                :
            fi
        done
        
        # Attendre un peu
        sleep 1
        
        # Vérifier qu'ils sont bien arrêtés
        REMAINING=$(get_tunnel_pids)
        if [ -n "$REMAINING" ]; then
            echo -e "${YELLOW}Finalisation de la fermeture...${NC}"
            echo "$REMAINING" | xargs kill -9 2>/dev/null
        fi
        
        echo -e "${GREEN}✓ Session terminée${NC}"
    fi
}

# Fonction pour afficher le statut
show_status() {
    local_screen_header "Statut des tunnels"

    local processes=""
    processes=$(get_tunnel_processes)
    local ports=""
    ports=$(get_active_ports || true)
    local active_count=0
    local inactive_count=0

    if [ -n "$processes" ]; then
        local count=""
        count=$(echo "$processes" | wc -l | tr -d ' ')
        echo -e "${GREEN}✓ Session active${NC}"
        echo -e "  ${GREEN}•${NC} $count projet(s) accessible(s)"
        echo ""
    else
        echo -e "${YELLOW}⚠ Aucune session active${NC}"
        echo ""
    fi

    if [ -z "$ports" ]; then
        echo -e "${YELLOW}⚠ Aucun port actif remonté par le serveur distant.${NC}"
        echo -e "${YELLOW}  Vérifiez que PM2 tourne ou qu'une session Flutter Web tmux est active.${NC}"
        return 0
    fi

    echo -e "${BLUE}💡 Synchronisation attendue serveur -> local:${NC}"
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        local port name
        port=$(echo "$line" | cut -d':' -f1)
        name=$(echo "$line" | cut -d':' -f2)

        if is_local_tunnel_ready "$port"; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
            active_count=$((active_count + 1))
        else
            echo -e "  ${RED}✗${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${RED}[manquant côté local]${NC}"
            inactive_count=$((inactive_count + 1))
        fi
    done <<< "$ports"

    echo ""
    if [ "$inactive_count" -eq 0 ]; then
        echo -e "${GREEN}✓ Synchronisation OK: ${active_count} tunnel(s) attendu(s), ${active_count} actif(s) en local.${NC}"
    else
        echo -e "${YELLOW}⚠ Synchronisation partielle: ${active_count} actif(s), ${inactive_count} manquant(s) côté local.${NC}"
    fi
}

# Fonction de pause
pause() {
    local pause_key=""

    echo ""
    echo -e "${YELLOW}Appuyez sur une touche pour continuer...${NC}"
    read_menu_choice pause_key
}

# Fonction principale
main() {
    while true; do
        local_clear_screen
        print_header
        show_menu

        prompt_inline "${YELLOW}Tape la lettre de ton choix ?${NC} "
        read_menu_choice CHOICE
        local_clear_screen

        case $CHOICE in
            t)
                start_tunnels
                pause
                ;;
            u)
                show_urls
                pause
                ;;
            a)
                stop_tunnels
                pause
                ;;
            s)
                show_status
                pause
                ;;
            r)
                local_screen_header "Relancer la session"
                stop_tunnels || true
                sleep 2
                if ! start_tunnels; then
                    echo ""
                    echo -e "${YELLOW}⚠ Redémarrage incomplet : vérifiez le statut des tunnels${NC}"
                fi
                pause
                ;;
            c)
                configure_new_server
                pause
                ;;
            k)
                install_ssh_key_for_current_server
                pause
                ;;
            o)
                run_auth_menu
                pause
                ;;
            l)
                select_connection
                ;;
            x|q)
                echo -e "${GREEN}👋 Au revoir !${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide${NC}"
                pause
                ;;
        esac
    done
}

# Lancer le menu
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main
fi

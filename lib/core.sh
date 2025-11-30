# --- Core Functions ---

load_config() {
    local config_file="$HOME/.config/ipcheck/keys.conf"
    if [[ -f "$config_file" ]]; then
        # Validate config file permissions (should be 600)
        local perms
        perms=$(stat -c "%a" "$config_file" 2>/dev/null || stat -f "%OLp" "$config_file" 2>/dev/null || echo "644")
        if [[ "$perms" != "600" ]] && [[ "$perms" != "0600" ]]; then
            log_message "WARNING: Config file permissions are $perms, should be 600"
        fi
        set -o allexport
        # shellcheck source=/dev/null
        source "$config_file"
        set +o allexport
    fi
}

write_status() {
    local ip_dir="$1" check_name="$2" status="$3" details="$4"
    local status_code
    case "$status" in
    "${GREEN}PASSED"*) status_code=0 ;;
    "${RED}FAILED"*) status_code=1 ;;
    "${YELLOW}SKIPPED"*) status_code=2 ;;
    *) status_code=3 ;; # ERROR
    esac
    echo "$status_code|$status|$details" >"$ip_dir/$check_name"
}

spinner() {
    local pid=$1 delay=0.1 spinstr='|/-\'
    while ps -p "$pid" >/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    printf "    \r"
}

get_server_ip() {
    curl -s --max-time 10 https://api.ipify.org || curl -s --max-time 10 https://ifconfig.me || echo ""
}

# Detect best available menu tool (priority: fzf > dialog > whiptail > none)
detect_menu_tool() {
    if command -v fzf &>/dev/null; then
        echo "fzf"
    elif command -v dialog &>/dev/null; then
        echo "dialog"
    elif command -v whiptail &>/dev/null; then
        echo "whiptail"
    else
        echo "none"
    fi
}


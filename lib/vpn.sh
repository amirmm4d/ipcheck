# --- VPN Installation Functions ---

install_singbox() {
    log_message "Installing Sing-box" "INFO"
    echo -e "${BLUE}Installing Sing-box...${NC}"
    local install_script
    install_script=$(curl -fsSL https://sing-box.sagernet.org/install.sh || true)
    if [[ -z "$install_script" ]]; then
        echo -e "${RED}Error: Failed to download Sing-box installer.${NC}" >&2
        return 1
    fi
    bash -c "$install_script" || {
        echo -e "${RED}Error: Sing-box installation failed.${NC}" >&2
        return 1
    }
    echo -e "${GREEN}✓ Sing-box installed successfully.${NC}"
    return 0
}

install_xray() {
    log_message "Installing Xray" "INFO"
    echo -e "${BLUE}Installing Xray...${NC}"
    local install_script
    install_script=$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh || true)
    if [[ -z "$install_script" ]]; then
        echo -e "${RED}Error: Failed to download Xray installer.${NC}" >&2
        return 1
    fi
    bash -c "$install_script" || {
        echo -e "${RED}Error: Xray installation failed.${NC}" >&2
        return 1
    }
    echo -e "${GREEN}✓ Xray installed successfully.${NC}"
    return 0
}

install_v2ray() {
    log_message "Installing V2Ray" "INFO"
    echo -e "${BLUE}Installing V2Ray...${NC}"
    local install_script
    install_script=$(curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh || true)
    if [[ -z "$install_script" ]]; then
        echo -e "${RED}Error: Failed to download V2Ray installer.${NC}" >&2
        return 1
    fi
    bash -c "$install_script" || {
        echo -e "${RED}Error: V2Ray installation failed.${NC}" >&2
        return 1
    }
    echo -e "${GREEN}✓ V2Ray installed successfully.${NC}"
    return 0
}

install_shadowsocks() {
    log_message "Installing Shadowsocks-libev" "INFO"
    echo -e "${BLUE}Installing Shadowsocks-libev...${NC}"
    if command -v apt-get &>/dev/null; then
        apt-get update && apt-get install -y shadowsocks-libev || return 1
    elif command -v yum &>/dev/null; then
        yum install -y epel-release && yum install -y shadowsocks-libev || return 1
    elif command -v dnf &>/dev/null; then
        dnf install -y shadowsocks-libev || return 1
    else
        echo -e "${RED}Error: Unsupported package manager.${NC}" >&2
        return 1
    fi
    echo -e "${GREEN}✓ Shadowsocks-libev installed successfully.${NC}"
    return 0
}

install_openvpn() {
    log_message "Installing OpenVPN" "INFO"
    echo -e "${BLUE}Installing OpenVPN...${NC}"
    if command -v apt-get &>/dev/null; then
        apt-get update && apt-get install -y openvpn easy-rsa || return 1
    elif command -v yum &>/dev/null; then
        yum install -y epel-release && yum install -y openvpn easy-rsa || return 1
    elif command -v dnf &>/dev/null; then
        dnf install -y openvpn easy-rsa || return 1
    else
        echo -e "${RED}Error: Unsupported package manager.${NC}" >&2
        return 1
    fi
    echo -e "${GREEN}✓ OpenVPN installed successfully.${NC}"
    echo -e "${YELLOW}Note: You need to configure OpenVPN manually after installation.${NC}"
    return 0
}

install_cisco() {
    log_message "Installing Cisco AnyConnect (OpenConnect)" "INFO"
    echo -e "${BLUE}Installing OpenConnect (Cisco AnyConnect compatible)...${NC}"
    if command -v apt-get &>/dev/null; then
        apt-get update && apt-get install -y openconnect || return 1
    elif command -v yum &>/dev/null; then
        yum install -y epel-release && yum install -y openconnect || return 1
    elif command -v dnf &>/dev/null; then
        dnf install -y openconnect || return 1
    else
        echo -e "${RED}Error: Unsupported package manager.${NC}" >&2
        return 1
    fi
    echo -e "${GREEN}✓ OpenConnect (Cisco compatible) installed successfully.${NC}"
    echo -e "${YELLOW}Note: OpenConnect is a Cisco AnyConnect compatible client.${NC}"
    return 0
}

# Auto-install VPN without prompting
auto_install_vpn() {
    local ip="$1"
    local vpn_type="${AUTO_VPN_TYPE:-singbox}"  # Default to singbox if not specified
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: VPN installation requires root privileges.${NC}" >&2
        return 1
    fi
    
    local score=100
    local ip_dir="$STATUS_DIR/$(echo "$ip" | tr '.' '_')"
    if [[ -f "$ip_dir/ip_score.json" ]]; then
        # Validate JSON before parsing
        if [[ -f "$ip_dir/ip_score.json" ]] && jq . "$ip_dir/ip_score.json" >/dev/null 2>&1; then
            score=$(jq -r '.clean_score // 100' "$ip_dir/ip_score.json" 2>/dev/null || echo "100")
            # If score is null, use default
            if [[ "$score" == "null" ]]; then
                score="100"
            fi
        else
            score="100"
        fi
    fi
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ IP Check Complete!${NC}"
    echo -e "${BLUE}IP Address: ${YELLOW}$ip${NC}"
    echo -e "${BLUE}Clean Score: ${YELLOW}$score/100${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BLUE}Auto-installing VPN: ${YELLOW}$vpn_type${NC}\n"
    
    case "$vpn_type" in
        singbox|sing-box|1)
            install_singbox
            ;;
        xray|2)
            install_xray
            ;;
        v2ray|3)
            install_v2ray
            ;;
        shadowsocks|shadowsocks-libev|4)
            install_shadowsocks
            ;;
        openvpn|5)
            install_openvpn
            ;;
        cisco|openconnect|6)
            install_cisco
            ;;
        *)
            echo -e "${YELLOW}Unknown VPN type '$vpn_type'. Installing default: Sing-box${NC}"
            install_singbox
            ;;
    esac
}

ask_vpn_installation() {
    local ip="$1"
    local vpn_type="${2:-}"  # Optional VPN type parameter
    
    # If VPN type is provided, use auto-install
    if [[ -n "$vpn_type" ]]; then
        AUTO_VPN_TYPE="$vpn_type"
        auto_install_vpn "$ip"
        return $?
    fi
    
    # Otherwise, ask interactively
    local score=100
    
    # Get score if available
    local ip_dir="$STATUS_DIR/$(echo "$ip" | tr '.' '_')"
    if [[ -f "$ip_dir/ip_score.json" ]]; then
        # Validate JSON before parsing
        if [[ -f "$ip_dir/ip_score.json" ]] && jq . "$ip_dir/ip_score.json" >/dev/null 2>&1; then
            score=$(jq -r '.clean_score // 100' "$ip_dir/ip_score.json" 2>/dev/null || echo "100")
            # If score is null, use default
            if [[ "$score" == "null" ]]; then
                score="100"
            fi
        else
            score="100"
        fi
    fi
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ IP Check Complete!${NC}"
    echo -e "${BLUE}IP Address: ${YELLOW}$ip${NC}"
    echo -e "${BLUE}Clean Score: ${YELLOW}$score/100${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Note: VPN installation requires root privileges.${NC}"
        return 0
    fi
    
    echo -e "${BLUE}Would you like to install a VPN server?${NC}"
    echo -e "  1) Sing-box (Recommended for Reality)"
    echo -e "  2) Xray (Xray-core)"
    echo -e "  3) V2Ray (V2Fly)"
    echo -e "  4) Shadowsocks-libev"
    echo -e "  5) OpenVPN"
    echo -e "  6) OpenConnect (Cisco AnyConnect compatible)"
    echo -e "  7) Skip installation"
    echo
    read -p "Select option (1-7): " vpn_choice
    
    case "$vpn_choice" in
        1)
            install_singbox
            ;;
        2)
            install_xray
            ;;
        3)
            install_v2ray
            ;;
        4)
            install_shadowsocks
            ;;
        5)
            install_openvpn
            ;;
        6)
            install_cisco
            ;;
        7)
            echo -e "${YELLOW}Skipping VPN installation.${NC}"
            ;;
        *)
            echo -e "${YELLOW}Invalid option. Skipping installation.${NC}"
            ;;
    esac
}

uninstall_ipcheck() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Uninstall requires root privileges. Please run with sudo.${NC}" >&2
        exit 1
    fi
    
    echo -e "${YELLOW}Uninstalling ipcheck...${NC}"
    
    # Remove binary
    if [[ -f "/usr/local/bin/ipcheck" ]]; then
        rm -f "/usr/local/bin/ipcheck"
        echo -e "${GREEN}✓ Removed /usr/local/bin/ipcheck${NC}"
    fi
    
    # Remove library directory
    if [[ -d "/usr/local/lib/ipcheck" ]]; then
        rm -rf "/usr/local/lib/ipcheck"
        echo -e "${GREEN}✓ Removed library directory /usr/local/lib/ipcheck${NC}"
    fi
    
    # Remove man page
    if [[ -f "/usr/share/man/man1/ipcheck.1.gz" ]]; then
        rm -f "/usr/share/man/man1/ipcheck.1.gz"
        mandb -q 2>/dev/null || true
        echo -e "${GREEN}✓ Removed man page${NC}"
    fi
    
    echo -e "${GREEN}✅ Uninstallation complete.${NC}"
    echo -e "${YELLOW}Note: Configuration file (~/.config/ipcheck/keys.conf) was not removed to preserve your API keys.${NC}"
    exit 0
}

parse_combined_flags() {
    local flag_string="$1"
    local -a parsed_flags=()
    
    # Parse combined flags like "gdt" into individual flags
    for (( i=0; i<${#flag_string}; i++ )); do
        local char="${flag_string:$i:1}"
        parsed_flags+=("-$char")
    done
    
    echo "${parsed_flags[@]}"
}

main() {
    # If no arguments, show interactive menu
    if [[ $# -eq 0 ]]; then
        interactive_menu
        exit 0
    fi
    
    # Pre-process arguments to handle combined flags like -gdt
    local processed_args=()
    local args_array=("$@")
    local i=0
    while [[ $i -lt ${#args_array[@]} ]]; do
        local arg="${args_array[$i]}"
        local next_arg="${args_array[$((i+1))]:-}"
        
        # Check if it's a combined flag (starts with - and has multiple letters, not followed by a number)
        if [[ "$arg" =~ ^-[a-zA-Z]{2,}$ ]] && [[ ! "$next_arg" =~ ^[0-9]+$ ]] && [[ "$arg" != "-"*[0-9]* ]]; then
            # Split combined flags: -gdt -> -g -d -t
            local flags="${arg#-}"
            for (( j=0; j<${#flags}; j++ )); do
                processed_args+=("-${flags:$j:1}")
            done
        else
            processed_args+=("$arg")
        fi
        ((i++))
    done
    
    # Call process_main_args with processed arguments
    process_main_args "${processed_args[@]}"
    exit $?

    # Check for uninstall first
    for arg in "$@"; do
        if [[ "$arg" == "-U" ]] || [[ "$arg" == "--uninstall" ]]; then
            uninstall_ipcheck
        fi
    done
    
    # Check for help
    for arg in "$@"; do
        if [[ "$arg" == "-H" ]] || [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]] && [[ ! " ${processed_args[*]} " =~ " -h " ]]; then
        usage
            exit 0
    fi
    done

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -i)
            IFS=',' read -ra ADDR <<<"$2"
            for ip in "${ADDR[@]}"; do ips_to_check+=("$ip"); done
            shift
            ;;
        -f)
            if [[ -f "$2" ]]; then
                mapfile -t FILE_IPS <"$2"
                for ip in "${FILE_IPS[@]}"; do [[ -n "$ip" ]] && ips_to_check+=("$ip"); done
            else
                echo -e "${RED}Error: File not found at '$2'${NC}" >&2
                exit 1
            fi
            shift
            ;;
        -S)
            local server_ip
            server_ip=$(get_server_ip)
            if [[ -n "$server_ip" ]]; then 
                ips_to_check+=("$server_ip")
                ASK_VPN_INSTALL=true  # Auto-enable VPN question for server check
            else
                echo -e "${RED}Error: Could not determine server's public IP.${NC}" >&2
                exit 1
            fi
            ;;
        -q) enable_ipqs=true; run_all_checks=false ;;
        -a) enable_abuseipdb=true; run_all_checks=false ;;
        -s) enable_scamalytics=true; run_all_checks=false ;;
        -r) enable_ripe=true; run_all_checks=false ;;
        -c) enable_host=true; run_all_checks=false ;;
        -h)
            # Check if it's help or hosttracker (help takes precedence if it's the only flag)
            if [[ $# -eq 1 ]] && [[ -z "$ips_to_check" ]]; then
                usage
                exit 0
            else
                enable_hosttracker=true
                run_all_checks=false
            fi
            ;;
        -j) output_format="json" ;;
        -F)
            fail_threshold="$2"
            if ! [[ "$fail_threshold" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error: -F requires a number.${NC}"
                exit 1
            fi
            shift
            ;;
        -l)
            LOG_DIR="$2"
            if [[ ! -d "$LOG_DIR" ]]; then
                mkdir -p "$LOG_DIR" || {
                    echo -e "${RED}Error: Cannot create log directory '$LOG_DIR'.${NC}" >&2
                    exit 1
                }
            fi
            log_message "Logging enabled: $LOG_DIR" "INFO"
            shift
            ;;
        -L)
            LOG_FORMAT="$2"
            if [[ "$LOG_FORMAT" != "txt" ]] && [[ "$LOG_FORMAT" != "json" ]]; then
                echo -e "${RED}Error: -L must be 'txt' or 'json'.${NC}" >&2
                exit 1
            fi
            shift
            ;;
        -g) ENABLE_SCORING=true ;;
        -d) ENABLE_CDN_CHECK=true ;;
        -t) ENABLE_ROUTING_CHECK=true ;;
        -p) ENABLE_PORT_SCAN=true ;;
        -R) ENABLE_REALITY_TEST=true ;;
        -u) ENABLE_USAGE_HISTORY=true ;;
        -n) ENABLE_SUGGESTIONS=true ;;
        -v) ASK_VPN_INSTALL=true ;;
        -A|--all)
            # Enable all checks and all advanced features
            enable_ipqs=true
            enable_abuseipdb=true
            enable_scamalytics=true
            enable_ripe=true
            enable_host=true
            enable_hosttracker=true
            ENABLE_SCORING=true
            ENABLE_CDN_CHECK=true
            ENABLE_ROUTING_CHECK=true
            ENABLE_PORT_SCAN=true
            ENABLE_REALITY_TEST=true
            ENABLE_USAGE_HISTORY=true
            ENABLE_SUGGESTIONS=true
            run_all_checks=false
            ;;
        -y)
            ASK_VPN_INSTALL=true
            AUTO_VPN_TYPE="${2:-singbox}"  # Default to singbox if not specified
            shift
            ;;
        --ally)
            # Enable all checks and auto-install VPN
            enable_ipqs=true
            enable_abuseipdb=true
            enable_scamalytics=true
            enable_ripe=true
            enable_host=true
            enable_hosttracker=true
            ENABLE_SCORING=true
            ENABLE_CDN_CHECK=true
            ENABLE_ROUTING_CHECK=true
            ENABLE_PORT_SCAN=true
            ENABLE_REALITY_TEST=true
            ENABLE_USAGE_HISTORY=true
            ENABLE_SUGGESTIONS=true
            run_all_checks=false
            ASK_VPN_INSTALL=true
            # Check if next argument is a VPN type (not a flag)
            if [[ $# -gt 1 ]] && [[ ! "$2" =~ ^- ]]; then
                AUTO_VPN_TYPE="$2"
                shift
            else
                AUTO_VPN_TYPE="singbox"  # Default
            fi
            ;;
        -U) uninstall_ipcheck ;;
        -H|--help)
            usage
            exit 0
            ;;
        # Handle combined flags that might have been missed
        -[a-zA-Z]{2,})
            # This shouldn't happen after preprocessing, but handle it anyway
            local flags="${1#-}"
            for (( i=0; i<${#flags}; i++ )); do
                local flag_char="${flags:$i:1}"
                case "$flag_char" in
                    q) enable_ipqs=true; run_all_checks=false ;;
                    a) enable_abuseipdb=true; run_all_checks=false ;;
                    s) enable_scamalytics=true; run_all_checks=false ;;
                    r) enable_ripe=true; run_all_checks=false ;;
                    c) enable_host=true; run_all_checks=false ;;
                    h) enable_hosttracker=true; run_all_checks=false ;;
                    g) ENABLE_SCORING=true ;;
                    d) ENABLE_CDN_CHECK=true ;;
                    t) ENABLE_ROUTING_CHECK=true ;;
                    p) ENABLE_PORT_SCAN=true ;;
                    R) ENABLE_REALITY_TEST=true ;;
                    u) ENABLE_USAGE_HISTORY=true ;;
                    n) ENABLE_SUGGESTIONS=true ;;
                    j) output_format="json" ;;
                    v) ASK_VPN_INSTALL=true ;;
                esac
            done
            ;;
        # Backward compatibility with old flags
        --file)
            if [[ -f "$2" ]]; then
                mapfile -t FILE_IPS <"$2"
                for ip in "${FILE_IPS[@]}"; do [[ -n "$ip" ]] && ips_to_check+=("$ip"); done
            else
                echo -e "${RED}Error: File not found at '$2'${NC}" >&2
                exit 1
            fi
            shift
            ;;
        --server)
            local server_ip
            server_ip=$(get_server_ip)
            if [[ -n "$server_ip" ]]; then 
                ips_to_check+=("$server_ip")
                ASK_VPN_INSTALL=true
            else
                echo -e "${RED}Error: Could not determine server's public IP.${NC}" >&2
                exit 1
            fi
            ;;
        --json) output_format="json" ;;
        --fail-if)
            fail_threshold="$2"
            if ! [[ "$fail_threshold" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error: --fail-if requires a number.${NC}"
                exit 1
            fi
            shift
            ;;
        --log-format)
            LOG_FORMAT="$2"
            if [[ "$LOG_FORMAT" != "txt" ]] && [[ "$LOG_FORMAT" != "json" ]]; then
                echo -e "${RED}Error: --log-format must be 'txt' or 'json'.${NC}" >&2
                exit 1
            fi
            shift
            ;;
        --score) ENABLE_SCORING=true ;;
        --cdn) ENABLE_CDN_CHECK=true ;;
        --routing) ENABLE_ROUTING_CHECK=true ;;
        --port-scan) ENABLE_PORT_SCAN=true ;;
        --reality) ENABLE_REALITY_TEST=true ;;
        --usage-history) ENABLE_USAGE_HISTORY=true ;;
        --suggestions) ENABLE_SUGGESTIONS=true ;;
        --uninstall) uninstall_ipcheck ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        esac
        shift
    done

    if [ ${#ips_to_check[@]} -eq 0 ]; then
        echo -e "${RED}Error: No IP addresses to check. Please provide input.${NC}" >&2
        usage
        exit 1
    fi

    # If no specific checks selected, run all
    if $run_all_checks; then
        enable_ipqs=true
        enable_abuseipdb=true
        enable_scamalytics=true
        enable_ripe=true
        enable_host=true
        enable_hosttracker=true
    fi

    load_config
    log_message "Starting IP checks for: ${ips_to_check[*]}"

    local total_ips=${#ips_to_check[@]}
    local current_ip_num=0
    for ip in "${ips_to_check[@]}"; do
        ((current_ip_num++))
        printf "${BLUE}🔎 [%d/%d] Checking IP: %s${NC}\n" "$current_ip_num" "$total_ips" "$ip"
        local ip_dir="$STATUS_DIR/$(echo "$ip" | tr '.' '_')"
        mkdir -p "$ip_dir"
        
        # Run enabled checks in parallel
        local pids=()
        $enable_ipqs && check_ipqs "$ip" "$ip_dir" & pids+=($!)
        $enable_abuseipdb && check_abuseipdb "$ip" "$ip_dir" & pids+=($!)
        $enable_scamalytics && check_scamalytics "$ip" "$ip_dir" & pids+=($!)
        $enable_ripe && check_ripe "$ip" "$ip_dir" & pids+=($!)
        $enable_host && check_host "$ip" "$ip_dir" & pids+=($!)
        $enable_hosttracker && check_hosttracker "$ip" "$ip_dir" & pids+=($!)
        
        # Additional API checks for scoring
        if $ENABLE_SCORING; then
            check_ipapi "$ip" "$ip_dir" & pids+=($!)
            check_ipregistry "$ip" "$ip_dir" & pids+=($!)
            check_spamhaus "$ip" "$ip_dir" & pids+=($!)
        fi
        
        # Wait for all checks to complete
        for pid in "${pids[@]}"; do
            wait "$pid" || true
        done
        
        # Run advanced features (sequential, as they may depend on previous results)
        if $ENABLE_CDN_CHECK; then
            detect_cdn "$ip" "$ip_dir"
        fi
        
        if $ENABLE_SCORING; then
            generate_score_report "$ip"
            generate_abuse_report "$ip" "$ip_dir"
        fi
        
        # Auto-enable scoring for server check to show score before VPN question
        if [[ "$ip" == "${ips_to_check[0]}" ]] && [[ ${#ips_to_check[@]} -eq 1 ]] && $ASK_VPN_INSTALL; then
            if ! $ENABLE_SCORING; then
                # Run scoring checks if not already enabled
                check_ipapi "$ip" "$ip_dir" & pids_scoring=($!)
                check_ipregistry "$ip" "$ip_dir" & pids_scoring+=($!)
                check_spamhaus "$ip" "$ip_dir" & pids_scoring+=($!)
                for pid in "${pids_scoring[@]}"; do
                    wait "$pid" || true
                done
            fi
            generate_score_report "$ip"
        fi
        
        if $ENABLE_ROUTING_CHECK; then
            test_routing "$ip" "$ip_dir"
        fi
        
        if $ENABLE_PORT_SCAN; then
            scan_ports "$ip" "$ip_dir"
        fi
        
        if $ENABLE_REALITY_TEST; then
            test_reality_fingerprint "$ip" "$ip_dir"
        fi
        
        if $ENABLE_USAGE_HISTORY; then
            check_usage_history "$ip" "$ip_dir"
        fi
        
        if $ENABLE_SUGGESTIONS; then
            generate_suggestions "$ip" "$ip_dir"
        fi
        
        printf "${GREEN}✅ [%d/%d] Done: %s${NC}\n" "$current_ip_num" "$total_ips" "$ip"
    done

    echo -e "\n${BLUE}--- Final Report ---${NC}"
    local final_exit_code=0
    local all_passed=true
    
    case "$output_format" in
        json)
            if ! generate_json_report "$(printf "%s\n" "${ips_to_check[@]}")" "$fail_threshold"; then
                final_exit_code=1
                all_passed=false
            fi
            ;;
        yaml)
            if ! generate_yaml_report "$(printf "%s\n" "${ips_to_check[@]}")" "$fail_threshold"; then
                final_exit_code=1
                all_passed=false
            fi
            ;;
        csv)
            if ! generate_csv_report "$(printf "%s\n" "${ips_to_check[@]}")" "$fail_threshold"; then
                final_exit_code=1
                all_passed=false
            fi
            ;;
        xml)
            if ! generate_xml_report "$(printf "%s\n" "${ips_to_check[@]}")" "$fail_threshold"; then
                final_exit_code=1
                all_passed=false
            fi
            ;;
        table|*)
        for ip in "${ips_to_check[@]}"; do
            local ip_dir="$STATUS_DIR/$(echo "$ip" | tr '.' '_')"
            if ! generate_table_report "$ip" "$ip_dir" "$fail_threshold"; then
                    final_exit_code=1
                    all_passed=false
            fi
        done
            ;;
    esac

    # Ask for VPN installation if requested and checks passed
    if $ASK_VPN_INSTALL && $all_passed; then
        # If only one IP was checked (server IP), ask for VPN installation
        if [[ ${#ips_to_check[@]} -eq 1 ]]; then
            if [[ -n "$AUTO_VPN_TYPE" ]]; then
                # Auto-install VPN
                auto_install_vpn "${ips_to_check[0]}"
            else
                # Interactive installation
                ask_vpn_installation "${ips_to_check[0]}"
            fi
        fi
    elif $ASK_VPN_INSTALL && ! $all_passed; then
        echo -e "\n${YELLOW}⚠️  VPN installation skipped: Some checks failed.${NC}"
        log_message "VPN installation skipped: Some checks failed" "WARN"
    fi

    exit "$final_exit_code"
}

main "$@"

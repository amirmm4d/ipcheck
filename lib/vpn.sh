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


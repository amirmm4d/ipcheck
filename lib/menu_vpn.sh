# --- VPN Menu Functions ---

show_vpn_menu() {
    show_logo
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${NC}                                                              ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}⚠️  Error: VPN installation requires root privileges${NC}          ${RED}║${NC}"
        echo -e "${RED}║${NC}                                                              ${RED}║${NC}"
        echo -e "${RED}║${NC}  ${YELLOW}Please run with: ${GREEN}sudo ipcheck${NC}                              ${RED}║${NC}"
        echo -e "${RED}║${NC}                                                              ${RED}║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        echo -ne "${BLUE}Press Enter to continue...${NC}"
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            IFS= read -r <&3
            exec 3<&-
        else
            IFS= read -r
        fi
        return
    fi
    
    # Use fzf for VPN selection
    local menu_options=(
        "1) 🚀 Sing-box (Recommended for Reality)"
        "2) ⚡ Xray (Xray-core)"
        "3) 🌐 V2Ray (V2Fly)"
        "4) 🔒 Shadowsocks-libev"
        "5) 🛡️  OpenVPN"
        "6) 🔐 OpenConnect (Cisco AnyConnect compatible)"
        "7) ⬅️  Back to main menu"
    )
    
    local selected=""
    local vpn_choice=""
    
    if command -v fzf &>/dev/null; then
        selected=$(printf '%s\n' "${menu_options[@]}" | \
            fzf --height=12 --reverse --border \
            --header="🔧 VPN Installation / نصب VPN" \
            --prompt="👉 Select VPN > " \
            --pointer="▶" 2>/dev/null || echo "")
        
        if [[ -n "$selected" ]]; then
            vpn_choice=$(echo "$selected" | grep -o '^[0-9]' | head -1)
        fi
    fi
    
    if [[ -z "$vpn_choice" ]]; then
        # Fallback to old menu
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}🔧 VPN Installation / نصب VPN${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│${NC}  ${BLUE}Select VPN to install / انتخاب VPN برای نصب:${NC}"
        echo -e "${YELLOW}│${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}1)${NC} ${BLUE}🚀 Sing-box${NC} (Recommended for Reality)"
        echo -e "${YELLOW}│${NC}  ${GREEN}2)${NC} ${BLUE}⚡ Xray${NC} (Xray-core)"
        echo -e "${YELLOW}│${NC}  ${GREEN}3)${NC} ${BLUE}🌐 V2Ray${NC} (V2Fly)"
        echo -e "${YELLOW}│${NC}  ${GREEN}4)${NC} ${BLUE}🔒 Shadowsocks-libev${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}5)${NC} ${BLUE}🛡️  OpenVPN${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}6)${NC} ${BLUE}🔐 OpenConnect${NC} (Cisco AnyConnect compatible)"
        echo -e "${YELLOW}│${NC}  ${GREEN}7)${NC} ${BLUE}⬅️  Back to main menu${NC}"
        echo -e "${YELLOW}└────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -ne "${BLUE}👉 Select option (1-7): ${NC}"
        
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            IFS= read -r vpn_choice <&3
            exec 3<&-
        elif [[ -t 0 ]]; then
            IFS= read -r vpn_choice
        else
            IFS= read -r vpn_choice || vpn_choice=""
        fi
        vpn_choice=$(printf '%s' "$vpn_choice" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    
    case "$vpn_choice" in
        1) install_singbox ;;
        2) install_xray ;;
        3) install_v2ray ;;
        4) install_shadowsocks ;;
        5) install_openvpn ;;
        6) install_cisco ;;
        7) return ;;
        *)
            echo -e "${YELLOW}⚠ Invalid option.${NC}"
            sleep 1
            ;;
    esac
    
    if [[ "$vpn_choice" =~ ^[1-6]$ ]]; then
        echo
        echo -ne "${BLUE}Press Enter to continue...${NC}"
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            IFS= read -r <&3
            exec 3<&-
        else
            IFS= read -r
        fi
    fi
}

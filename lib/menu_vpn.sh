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
        "1) 🚀 Sing-box|Modern, lightweight, supports Reality protocol (Recommended for Reality)|1"
        "2) ⚡ Xray|High-performance proxy platform (Xray-core)|2"
        "3) 🌐 V2Ray|Popular proxy platform with extensive features (V2Fly)|3"
        "4) 🔒 Shadowsocks-libev|Lightweight SOCKS5 proxy|4"
        "5) 🛡️  OpenVPN|Industry-standard VPN protocol|5"
        "6) 🔐 OpenConnect|Compatible with Cisco AnyConnect VPN|6"
        "7) ⬅️  Back to main menu|Return to main menu|7"
    )
    
    local selected
    selected=$(printf '%s\n' "${menu_options[@]}" | \
        fzf --height=15 --reverse --border --header="🔧 VPN Installation / نصب VPN" \
        --prompt="👉 Select VPN > " \
        --pointer="▶" \
        --preview="echo {} | cut -d'|' -f2" \
        --preview-window=right:40%:wrap \
        --delimiter='|' \
        --with-nth=1 || echo "")
    
    if [[ -z "$selected" ]]; then
        return
    fi
    
    local vpn_choice
    vpn_choice=$(echo "$selected" | cut -d'|' -f3)
    
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

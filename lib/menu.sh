# --- Interactive Menu Functions ---

show_logo() {
    echo -e "${BLUE}"
    echo "    ██╗██████╗  ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗"
    echo "    ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝"
    echo "    ██║██████╔╝██║     ███████║█████╗  ██║     █████╔╝"
    echo "    ██║██╔═══╝ ██║     ██╔══██║██╔══╝  ██║     ██╔═██╗"
    echo "    ██║██║     ╚██████╗██║  ██║███████╗╚██████╗██║  ██╗"
    echo "    ╚═╝╚═╝      ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝"
    echo "    ════════════════════════════════════════════════════"
    echo "    Advanced IP Reputation Checker v2.1.8"
    echo -e "${NC}"
    echo
}

show_main_menu() {
    show_logo
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Main Menu / منوی اصلی${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}1)${NC} ${BLUE}🔍 Check IP Address${NC} / ${BLUE}بررسی آدرس IP${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Analyze IP reputation, quality score, CDN detection, routing health"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} بررسی اعتبار IP، امتیاز کیفیت، تشخیص CDN، سلامت مسیریابی"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}2)${NC} ${BLUE}🔧 Install VPN Server${NC} / ${BLUE}نصب سرور VPN${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Install Sing-box, Xray, V2Ray, Shadowsocks, OpenVPN, or OpenConnect"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} نصب Sing-box، Xray، V2Ray، Shadowsocks، OpenVPN یا OpenConnect"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}3)${NC} ${BLUE}🗑️  Uninstall IPCheck${NC} / ${BLUE}حذف IPCheck${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Remove IPCheck from your system"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} حذف IPCheck از سیستم شما"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}4)${NC} ${BLUE}❌ Exit${NC} / ${BLUE}خروج${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Exit the application"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} خروج از برنامه"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_ip_check_menu() {
    clear
    show_logo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 IP Check Options / گزینه‌های بررسی IP${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC}  ${BLUE}Input Method / روش ورودی:${NC}"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}1)${NC} ${BLUE}✍️  Enter IP address(es) manually${NC} / ${BLUE}وارد کردن دستی آدرس IP${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Type one or more IP addresses (comma-separated)"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} وارد کردن یک یا چند آدرس IP (جدا شده با کاما)"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}2)${NC} ${BLUE}🖥️  Check server's public IP${NC} / ${BLUE}بررسی IP عمومی سرور${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Automatically detect and check this server's public IP"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} تشخیص و بررسی خودکار IP عمومی این سرور"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}3)${NC} ${BLUE}📄 Load from file${NC} / ${BLUE}بارگذاری از فایل${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Load IP addresses from a text file (one per line)"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} بارگذاری آدرس‌های IP از فایل متنی (هر خط یک IP)"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}4)${NC} ${BLUE}⬅️  Back to main menu${NC} / ${BLUE}بازگشت به منوی اصلی${NC}"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${BLUE}👉 Select input method (1-4): ${NC}"
    
    local input_method=""
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        exec 3< /dev/tty
        IFS= read -r input_method <&3
        exec 3<&-
    elif [[ -t 0 ]]; then
        IFS= read -r input_method
    else
        exec 3< /dev/tty 2>/dev/null
        if [[ $? -eq 0 ]]; then
            IFS= read -r input_method <&3
            exec 3<&-
        else
            IFS= read -r input_method || input_method=""
        fi
    fi
    input_method=$(printf '%s' "$input_method" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    local ip_input=""
    local result=""
    case "$input_method" in
        1)
            echo
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -ne "${BLUE}📝 Enter IP address(es) (comma-separated): ${NC}"
            if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                exec 3< /dev/tty
                IFS= read -r ip_input <&3
                exec 3<&-
            else
                IFS= read -r ip_input
            fi
            ip_input=$(printf '%s' "$ip_input" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -z "$ip_input" ]]; then
                echo -e "${YELLOW}⚠ No IP address entered. Cancelling...${NC}"
                result="INPUT:CANCEL"
            else
                result="INPUT:$ip_input"
            fi
            ;;
        2)
            echo
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}🔍 Detecting server's public IP...${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            local server_ip
            server_ip=$(get_server_ip)
            if [[ -n "$server_ip" ]] && [[ "$server_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo -e "${GREEN}✓${NC} ${BLUE}Server's public IP: ${GREEN}$server_ip${NC}"
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo
                echo -ne "${BLUE}Press Enter to continue with IP check...${NC}"
                if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                    exec 3< /dev/tty
                    IFS= read -r <&3
                    exec 3<&-
                else
                    IFS= read -r
                fi
                result="INPUT:--server"
            else
                echo -e "${RED}✗${NC} ${RED}Error: Could not determine server's public IP.${NC}"
                echo -e "${YELLOW}Please check your internet connection or try again later.${NC}"
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo
                echo -ne "${BLUE}Press Enter to go back...${NC}"
                if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                    exec 3< /dev/tty
                    IFS= read -r <&3
                    exec 3<&-
                else
                    IFS= read -r
                fi
                result="INPUT:CANCEL"
            fi
            ;;
        3)
            echo
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -ne "${BLUE}📁 Enter file path: ${NC}"
            if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                exec 3< /dev/tty
                IFS= read -r file_path <&3
                exec 3<&-
            else
                IFS= read -r file_path
            fi
            file_path=$(printf '%s' "$file_path" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -z "$file_path" ]]; then
                echo -e "${YELLOW}⚠ No file path entered. Cancelling...${NC}"
                result="INPUT:CANCEL"
            else
                result="INPUT:--file:$file_path"
            fi
            ;;
        4)
            result="INPUT:CANCEL"
            ;;
        *)
            echo -e "${YELLOW}⚠ Invalid option.${NC}"
            sleep 1
            result="INPUT:CANCEL"
            ;;
    esac
    
    # Store result in global variable
    IPCHECK_MENU_RESULT="$result"
}

show_check_options_menu() {
    local selected_flags=""
    
    # Define all options with their flags and descriptions
    local -a options=(
        "q:IPQualityScore:Basic Checks"
        "a:AbuseIPDB:Basic Checks"
        "s:Scamalytics:Basic Checks"
        "r:RIPE Atlas:Basic Checks"
        "c:Check-Host:Basic Checks"
        "h:HostTracker:Basic Checks"
        "g:IP Quality Score:Advanced Features"
        "d:CDN Detection:Advanced Features"
        "t:Routing Health:Advanced Features"
        "p:Port Scan:Advanced Features"
        "R:Reality Test:Advanced Features"
        "u:Usage History:Advanced Features"
        "n:Suggestions:Advanced Features"
        "j:JSON Output:Output Options"
        "l:Enable Logging:Output Options"
    )
    
    local current_index=0
    local total_options=${#options[@]}
    
    # Read a single character from terminal
    read_char() {
        local char
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            IFS= read -rs -n1 char <&3
            exec 3<&-
        else
            IFS= read -rs -n1 char
        fi
        printf '%s' "$char"
    }
    
    while true; do
        clear
        show_logo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Select Check Options / انتخاب گزینه‌های بررسی${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        
        local current_section=""
        local option_index=0
        
        for option in "${options[@]}"; do
            local flag="${option%%:*}"
            local desc="${option#*:}"
            desc="${desc%%:*}"
            local section="${option##*:}"
            
            # Print section header when section changes
            if [[ "$section" != "$current_section" ]]; then
                if [[ -n "$current_section" ]]; then
                    echo
                fi
                case "$section" in
                    "Basic Checks")
                        echo -e "${BLUE}Basic Checks / بررسی‌های پایه:${NC}"
                        ;;
                    "Advanced Features")
                        echo -e "\n${BLUE}Advanced Features / ویژگی‌های پیشرفته:${NC}"
                        ;;
                    "Output Options")
                        echo -e "\n${BLUE}Output Options / گزینه‌های خروجی:${NC}"
                        ;;
                esac
                current_section="$section"
            fi
            
            # Check if selected
            local is_selected=false
            [[ "$selected_flags" == *"$flag"* ]] && is_selected=true
            
            # Highlight current option
            if [[ $option_index -eq $current_index ]]; then
                if $is_selected; then
                    echo -e "  ${GREEN}▶${NC} ${YELLOW}[${GREEN}✓${YELLOW}]${NC} ${GREEN}$flag${NC} - $desc"
                else
                    echo -e "  ${GREEN}▶${NC} ${YELLOW}[${NC} ${YELLOW}]${NC} ${GREEN}$flag${NC} - $desc"
                fi
            else
                if $is_selected; then
                    echo -e "    ${YELLOW}[${GREEN}✓${YELLOW}]${NC} $flag - $desc"
                else
                    echo -e "    ${YELLOW}[${NC} ${YELLOW}]${NC} $flag - $desc"
                fi
            fi
            
            ((option_index++))
        done
        
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [[ -n "$selected_flags" ]]; then
            echo -e "${BLUE}Selected flags: ${GREEN}${selected_flags}${NC}"
        else
            echo -e "${BLUE}Selected flags: ${YELLOW}none (will run all basic checks)${NC}"
        fi
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        echo -e "${BLUE}Instructions:${NC}"
        echo -e "  ${YELLOW}↑${NC}/${YELLOW}↓${NC} - Navigate  ${YELLOW}Space${NC}/${YELLOW}Enter${NC} - Toggle  ${YELLOW}a${NC} - Select all  ${YELLOW}c${NC} - Clear  ${YELLOW}d${NC} - Done"
        echo
        
        # Read key input
        local key
        key=$(read_char)
        
        # Handle escape sequences for arrow keys
        if [[ "$key" == $'\x1b' ]]; then
            local key2 key3
            key2=$(read_char)
            if [[ "$key2" == '[' ]]; then
                key3=$(read_char)
                case "$key3" in
                    'A') # Up arrow
                        if [[ $current_index -gt 0 ]]; then
                            ((current_index--))
                        else
                            current_index=$((total_options - 1))
                        fi
                        ;;
                    'B') # Down arrow
                        if [[ $current_index -lt $((total_options - 1)) ]]; then
                            ((current_index++))
                        else
                            current_index=0
                        fi
                        ;;
                esac
            fi
        elif [[ "$key" == $'\x20' ]] || [[ "$key" == $'\x0a' ]] || [[ "$key" == $'\x0d' ]]; then
            # Space or Enter - toggle current option
            local current_flag
            current_flag=$(echo "${options[$current_index]}" | cut -d: -f1)
            if [[ "$selected_flags" == *"$current_flag"* ]]; then
                selected_flags="${selected_flags//$current_flag/}"
            else
                selected_flags+="$current_flag"
            fi
        elif [[ "$key" == 'a' ]] || [[ "$key" == 'A' ]]; then
            # Select all
            selected_flags="qasrchgdtpRunjl"
        elif [[ "$key" == 'c' ]] || [[ "$key" == 'C' ]]; then
            # Clear all
            selected_flags=""
        elif [[ "$key" == 'd' ]] || [[ "$key" == 'D' ]]; then
            # Done
            IPCHECK_MENU_RESULT="FLAGS:$selected_flags"
            return
        fi
    done
}

show_vpn_menu() {
    show_logo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔧 VPN Installation / نصب VPN${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
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
    
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC}  ${BLUE}Select VPN to install / انتخاب VPN برای نصب:${NC}"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}1)${NC} ${BLUE}🚀 Sing-box${NC} (Recommended for Reality / توصیه شده برای Reality)"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Modern, lightweight, supports Reality protocol"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} مدرن، سبک، پشتیبانی از پروتکل Reality"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}2)${NC} ${BLUE}⚡ Xray${NC} (Xray-core)"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} High-performance proxy platform"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} پلتفرم پروکسی با عملکرد بالا"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}3)${NC} ${BLUE}🌐 V2Ray${NC} (V2Fly)"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Popular proxy platform with extensive features"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} پلتفرم پروکسی محبوب با ویژگی‌های گسترده"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}4)${NC} ${BLUE}🔒 Shadowsocks-libev${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Lightweight SOCKS5 proxy"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} پروکسی SOCKS5 سبک"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}5)${NC} ${BLUE}🛡️  OpenVPN${NC}"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Industry-standard VPN protocol"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} پروتکل VPN استاندارد صنعتی"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}6)${NC} ${BLUE}🔐 OpenConnect${NC} (Cisco AnyConnect compatible)"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} Compatible with Cisco AnyConnect VPN"
    echo -e "${YELLOW}│${NC}     ${YELLOW}→${NC} سازگار با VPN Cisco AnyConnect"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│${NC}  ${GREEN}7)${NC} ${BLUE}⬅️  Back to main menu${NC} / ${BLUE}بازگشت به منوی اصلی${NC}"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${BLUE}👉 Select option (1-7): ${NC}"
    
    local vpn_choice=""
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        exec 3< /dev/tty
        IFS= read -r vpn_choice <&3
        exec 3<&-
    elif [[ -t 0 ]]; then
        IFS= read -r vpn_choice
    else
        exec 3< /dev/tty 2>/dev/null
        if [[ $? -eq 0 ]]; then
            IFS= read -r vpn_choice <&3
            exec 3<&-
        else
            IFS= read -r vpn_choice || vpn_choice=""
        fi
    fi
    vpn_choice=$(printf '%s' "$vpn_choice" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
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

interactive_menu() {
    while true; do
        show_main_menu
        
        # Read input directly (not from command substitution)
        echo -ne "${BLUE}👉 Select an option (1-4): ${NC}"
        local main_choice=""
        
        # Force read from /dev/tty
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            IFS= read -r main_choice <&3
            exec 3<&-
        elif [[ -t 0 ]]; then
            IFS= read -r main_choice
        else
            exec 3< /dev/tty 2>/dev/null
            if [[ $? -eq 0 ]]; then
                IFS= read -r main_choice <&3
                exec 3<&-
            else
                IFS= read -r main_choice || main_choice=""
            fi
        fi
        
        # Trim whitespace and newlines
        main_choice=$(printf '%s' "$main_choice" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        case "$main_choice" in
            1)
                # Call menu directly (it displays itself)
                show_ip_check_menu
                local input_result="$IPCHECK_MENU_RESULT"
                
                if [[ -z "$input_result" ]] || [[ "$input_result" == "INPUT:CANCEL" ]]; then
                    continue
                fi
                
                # Call check options menu directly (interactive with arrow keys)
                show_check_options_menu
                local check_result="$IPCHECK_MENU_RESULT"
                
                if [[ "$check_result" == "FLAGS:"* ]]; then
                    local flags="${check_result#FLAGS:}"
                    local input="${input_result#INPUT:}"
                    
                    # Build command
                    local cmd_args=()
                    
                    if [[ "$input" == "--server" ]]; then
                        cmd_args+=("-S")
                    elif [[ "$input" == --file:* ]]; then
                        cmd_args+=("-f" "${input#--file:}")
                    else
                        cmd_args+=("-i" "$input")
                    fi
                    
                    # Add flags
                    if [[ "$flags" != "all" ]] && [[ -n "$flags" ]]; then
                        # Add individual flags or combined
                        if [[ ${#flags} -gt 1 ]]; then
                            # Combined flags like "gdt"
                            cmd_args+=("-$flags")
                        else
                            # Single flag
                            cmd_args+=("-$flags")
                        fi
                    fi
                    
                    # Execute
                    echo -e "\n${BLUE}Running: ipcheck ${cmd_args[*]}${NC}\n"
                    process_main_args "${cmd_args[@]}"
                    local exit_code=$?
                    echo
                    read -p "Press Enter to continue..."
                fi
                ;;
            2)
                show_vpn_menu
                ;;
            3)
                if [[ $EUID -ne 0 ]]; then
                    echo -e "${RED}Error: Uninstall requires root privileges.${NC}"
                    read -p "Press Enter to continue..."
                else
                    echo -e "${YELLOW}Are you sure you want to uninstall IPCheck? (y/n) [default: y]: ${NC}"
                    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                        exec 3< /dev/tty
                        IFS= read -r confirm <&3
                        exec 3<&-
                    else
                        IFS= read -r confirm
                    fi
                    # Trim whitespace and convert to lowercase
                    confirm=$(echo "$confirm" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')
                    # If empty or y, proceed with uninstall
                    if [[ -z "$confirm" ]] || [[ "$confirm" == "y" ]]; then
                        uninstall_ipcheck
                    fi
                fi
                ;;
            4)
                echo -e "${GREEN}Goodbye! / خداحافظ!${NC}"
                exit 0
                ;;
            "")
                # Empty input, show menu again
                echo -e "\n${YELLOW}⚠️  Please select an option (1-4).${NC}"
                sleep 1
                continue
                ;;
            *)
                echo -e "\n${RED}❌ Invalid option: '${main_choice}'. Please select 1-4.${NC}"
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                local dummy
                if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                    exec 3< /dev/tty
                    read -r dummy <&3
                    exec 3<&-
                else
                    read -r dummy
                fi
                ;;
        esac
    done
}

process_main_args() {
    # This function contains the main argument processing logic
    # (extracted from main to avoid recursion)
    local ips_to_check=()
    local output_format="table"
    local fail_threshold=1
    local enable_ipqs=false
    local enable_abuseipdb=false
    local enable_scamalytics=false
    local enable_ripe=false
    local enable_host=false
    local enable_hosttracker=false
    local run_all_checks=true
    
    # Pre-process arguments to handle combined flags
    local processed_args=()
    local i=0
    local args_array=("$@")
    while [[ $i -lt ${#args_array[@]} ]]; do
        local arg="${args_array[$i]}"
        local next_arg="${args_array[$((i+1))]:-}"
        
        if [[ "$arg" =~ ^-[a-zA-Z]{2,}$ ]] && [[ ! "$next_arg" =~ ^[0-9]+$ ]]; then
            local flags="${arg#-}"
            for (( j=0; j<${#flags}; j++ )); do
                processed_args+=("-${flags:$j:1}")
            done
        else
            processed_args+=("$arg")
        fi
        ((i++))
    done
    
    set -- "${processed_args[@]}"
    
    # Now process arguments (same as main function)
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
                return 1
            fi
            shift
            ;;
        -S)
            local server_ip
            server_ip=$(get_server_ip)
            if [[ -n "$server_ip" ]]; then 
                ips_to_check+=("$server_ip")
                ASK_VPN_INSTALL=true
            else
                echo -e "${RED}Error: Could not determine server's public IP.${NC}" >&2
                return 1
            fi
            ;;
        -q) enable_ipqs=true; run_all_checks=false ;;
        -a) enable_abuseipdb=true; run_all_checks=false ;;
        -s) enable_scamalytics=true; run_all_checks=false ;;
        -r) enable_ripe=true; run_all_checks=false ;;
        -c) enable_host=true; run_all_checks=false ;;
        -h)
            if [[ $# -eq 1 ]] && [[ ${#ips_to_check[@]} -eq 0 ]]; then
                usage
                return 0
            else
                enable_hosttracker=true
                run_all_checks=false
            fi
            ;;
        -j) output_format="json" ;;
        -o|--output)
            case "$2" in
                json|yaml|csv|xml|table)
                    output_format="$2"
                    ;;
                *)
                    echo -e "${RED}Error: Invalid output format '$2'. Valid formats: json, yaml, csv, xml, table${NC}" >&2
                    return 1
                    ;;
            esac
            shift
            ;;
        -F)
            fail_threshold="$2"
            if ! [[ "$fail_threshold" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error: -F requires a number.${NC}"
                return 1
            fi
            shift
            ;;
        -l)
            LOG_DIR="$2"
            if [[ ! -d "$LOG_DIR" ]]; then
                mkdir -p "$LOG_DIR" || {
                    echo -e "${RED}Error: Cannot create log directory '$LOG_DIR'.${NC}" >&2
                    return 1
                }
            fi
            log_message "Logging enabled: $LOG_DIR" "INFO"
            shift
            ;;
        -L)
            LOG_FORMAT="$2"
            if [[ "$LOG_FORMAT" != "txt" ]] && [[ "$LOG_FORMAT" != "json" ]]; then
                echo -e "${RED}Error: -L must be 'txt' or 'json'.${NC}" >&2
                return 1
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
        -U) uninstall_ipcheck ;;
        -H|--help)
            usage
            return 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            return 1
            ;;
        esac
        shift
    done
    
    # Continue with main execution logic
    if [ ${#ips_to_check[@]} -eq 0 ]; then
        echo -e "${RED}Error: No IP addresses to check. Please provide input.${NC}" >&2
        usage
        return 1
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
    log_message "Starting IP checks for: ${ips_to_check[*]}" "INFO"
    
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
        if [[ ${#ips_to_check[@]} -eq 1 ]]; then
            if [[ -n "$AUTO_VPN_TYPE" ]]; then
                # Auto-install VPN
                auto_install_vpn "${ips_to_check[0]}"
            else
                # Interactive installation
                if [[ -n "$AUTO_VPN_TYPE" ]]; then
                # Auto-install VPN
                auto_install_vpn "${ips_to_check[0]}"
            else
                # Interactive installation
                ask_vpn_installation "${ips_to_check[0]}"
            fi
            fi
        fi
    elif $ASK_VPN_INSTALL && ! $all_passed; then
        echo -e "\n${YELLOW}⚠️  VPN installation skipped: Some checks failed.${NC}"
        log_message "VPN installation skipped: Some checks failed" "WARN"
    fi
    
    # Clean up raw data files (they're already included in JSON output)
    log_message "Cleaning up temporary raw data files" "INFO"
    for ip in "${ips_to_check[@]}"; do
        local ip_dir="$STATUS_DIR/$(echo "$ip" | tr '.' '_')"
        rm -f "$ip_dir"/raw_*.json "$ip_dir"/raw_*.txt 2>/dev/null || true
    done
    
    return $final_exit_code
}


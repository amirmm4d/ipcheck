# --- Main Menu Functions ---

show_logo() {
    echo -e "${BLUE}"
    echo "    ██╗██████╗  ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗"
    echo "    ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝"
    echo "    ██║██████╔╝██║     ███████║█████╗  ██║     █████╔╝"
    echo "    ██║██╔═══╝ ██║     ██╔══██║██╔══╝  ██║     ██╔═██╗"
    echo "    ██║██║     ╚██████╗██║  ██║███████╗╚██████╗██║  ██╗"
    echo "    ╚═╝╚═╝      ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝"
    echo "    ════════════════════════════════════════════════════"
    echo "    Advanced IP Reputation Checker v${IPCHECK_VERSION:-2.2.7}"
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

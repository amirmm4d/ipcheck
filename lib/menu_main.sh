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
    echo "    Advanced IP Reputation Checker v${IPCHECK_VERSION:-2.2.35}"
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
        # Check if dialog is available
        local tool
        tool=$(detect_menu_tool)
        
        # If dialog is not available and we have root, try to install it
        if [[ "$tool" != "dialog" ]] && [[ $EUID -eq 0 ]]; then
            echo -e "${BLUE}⚠️  dialog is not installed. Attempting to install...${NC}"
            if install_dialog_if_missing; then
                echo -e "${GREEN}✅ dialog installed successfully!${NC}"
                sleep 1
                tool="dialog"
            else
                echo -e "${YELLOW}⚠️  Could not install dialog automatically.${NC}"
                echo -e "${YELLOW}   Using fallback text menu.${NC}"
                sleep 1
            fi
        fi
        
        local main_choice=""
        local use_fallback=false
        
        if [[ "$tool" == "dialog" ]]; then
            # Use dialog menu
            show_logo
            local menu_options=(
                "🔍 Check IP Address / بررسی آدرس IP"
                "🔧 Install VPN Server / نصب سرور VPN"
                "🗑️  Uninstall IPCheck / حذف IPCheck"
                "❌ Exit / خروج"
            )
            
            local selected
            selected=$(show_menu "📋 Main Menu / منوی اصلی" "${menu_options[@]}")
            
            if [[ -n "$selected" ]]; then
                # Map selection to choice number
                case "$selected" in
                    *"Check IP Address"*|*"بررسی آدرس IP"*)
                        main_choice="1"
                        ;;
                    *"Install VPN Server"*|*"نصب سرور VPN"*)
                        main_choice="2"
                        ;;
                    *"Uninstall IPCheck"*|*"حذف IPCheck"*)
                        main_choice="3"
                        ;;
                    *"Exit"*|*"خروج"*)
                        main_choice="4"
                        ;;
                esac
            else
                # User cancelled or dialog failed - fall back to text menu
                use_fallback=true
            fi
        else
            # No dialog available, use fallback
            use_fallback=true
        fi
        
        # Use fallback text menu if needed
        if [[ "$use_fallback" == "true" ]]; then
            show_main_menu
            echo -ne "${BLUE}👉 Select an option (1-4): ${NC}"
            if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                exec 3< /dev/tty
                IFS= read -r main_choice <&3
                exec 3<&-
            elif [[ -t 0 ]]; then
                IFS= read -r main_choice
            else
                IFS= read -r main_choice || main_choice=""
            fi
            main_choice=$(printf '%s' "$main_choice" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ "$main_choice" == "4" ]] || [[ -z "$main_choice" ]]; then
                echo -e "${GREEN}Goodbye! / خداحافظ!${NC}"
                exit 0
            fi
        fi
        
        case "$main_choice" in
            1)
                # Initialize result variable to avoid unbound variable error
                IPCHECK_MENU_RESULT=""
                
                # Call menu directly (it displays itself)
                # Note: We can't use subshell here because variables won't propagate
                set +e
                show_ip_check_menu 2>/dev/null || true
                set -e
                local input_result="${IPCHECK_MENU_RESULT:-}"
                
                if [[ -z "$input_result" ]] || [[ "$input_result" == "INPUT:CANCEL" ]]; then
                    continue
                fi
                
                # Reset for next menu call
                IPCHECK_MENU_RESULT=""
                
                # Call check options menu directly (interactive with arrow keys)
                # Don't redirect stderr to avoid hiding terminal issues
                set +e
                show_check_options_menu || true
                set -e
                
                local check_result="${IPCHECK_MENU_RESULT:-}"
                
                # If check was cancelled or empty, go back to main menu
                if [[ -z "$check_result" ]] || [[ "$check_result" == "FLAGS:CANCEL" ]]; then
                    continue
                fi
                
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
                    
                    # Execute the command
                    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -e "${BLUE}Running: ipcheck ${cmd_args[*]}${NC}"
                    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
                    # Call process_main_args and capture exit code
                    process_main_args "${cmd_args[@]}"
                    local exit_code=$?
                    echo
                    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -ne "${BLUE}Press Enter to return to main menu...${NC}"
                    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                        exec 3< /dev/tty
                        IFS= read -r <&3
                        exec 3<&-
                    else
                        IFS= read -r
                    fi
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

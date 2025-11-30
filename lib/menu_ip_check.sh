# --- IP Check Menu Functions ---

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
                echo -e "${BLUE}Continuing to check options menu...${NC}"
                sleep 1.5 2>/dev/null || sleep 1
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
    
    local total_options=${#options[@]}
    local current_index=0
    local -a selected=()
    
    # Initialize selected array (0 = not selected, 1 = selected)
    for ((i=0; i<total_options; i++)); do
        selected[$i]=0
    done
    
    # Enable raw mode for reading single characters
    local stty_save=""
    
    # Function to restore terminal (must be defined before trap)
    restore_terminal() {
        if [[ -n "$stty_save" ]] && [[ -c /dev/tty ]]; then
            stty "$stty_save" < /dev/tty 2>/dev/null || true
            trap - EXIT INT TERM
        fi
    }
    
    if [[ -c /dev/tty ]]; then
        stty_save=$(stty -g < /dev/tty 2>/dev/null || echo "")
        if [[ -n "$stty_save" ]]; then
            stty -echo -icanon time 0 min 0 < /dev/tty 2>/dev/null || true
            # Set trap to restore terminal settings on exit
            trap restore_terminal EXIT INT TERM
        fi
    fi
    
    # Function to display menu
    display_checkbox_menu() {
        clear
        show_logo
        
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Select Check Options / انتخاب گزینه‌های بررسی${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        
        local current_section=""
        local option_num=0
        
        # Display options grouped by section
        for ((i=0; i<total_options; i++)); do
            local option="${options[$i]}"
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
            
            # Display checkbox and option
            local checkbox=""
            local color=""
            if [[ $i -eq $current_index ]]; then
                # Current item - highlight
                if [[ ${selected[$i]} -eq 1 ]]; then
                    checkbox="${GREEN}[✓]${NC}"
                    color="${GREEN}"
                else
                    checkbox="${YELLOW}[ ]${NC}"
                    color="${YELLOW}"
                fi
                echo -e "  ${color}▶${NC} $checkbox ${color}$flag${NC} - ${color}$desc${NC}"
            else
                # Other items
                if [[ ${selected[$i]} -eq 1 ]]; then
                    checkbox="${GREEN}[✓]${NC}"
                    color="${GREEN}"
                else
                    checkbox="${NC}[ ]${NC}"
                    color="${NC}"
                fi
                echo -e "    $checkbox ${color}$flag${NC} - ${color}$desc${NC}"
            fi
        done
        
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}Instructions / راهنما:${NC}"
        echo -e "  ${BLUE}↑${NC}/${BLUE}↓${NC} - Move up/down / حرکت بالا/پایین"
        echo -e "  ${BLUE}Space${NC} - Toggle selection / تغییر انتخاب"
        echo -e "  ${BLUE}Enter${NC} - Confirm (default: all basic checks) / تایید (پیش‌فرض: همه بررسی‌های پایه)"
        echo -e "  ${BLUE}q${NC} or ${BLUE}ESC${NC} - Cancel / لغو"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    }
    
    # Main loop
    while true; do
        display_checkbox_menu
        
        # Read single character
        local key=""
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            key=$(dd bs=1 count=1 < /dev/tty 2>/dev/null || echo "")
        else
            # Fallback: read from stdin
            IFS= read -rs -n1 key || key=""
        fi
        
        # Handle escape sequences (arrow keys)
        if [[ "$key" == $'\x1b' ]]; then
            # Read next character
            local key2=""
            if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                key2=$(dd bs=1 count=1 < /dev/tty 2>/dev/null || echo "")
            else
                IFS= read -rs -n1 key2 || key2=""
            fi
            
            if [[ "$key2" == "[" ]]; then
                # Read third character
                local key3=""
                if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                    key3=$(dd bs=1 count=1 < /dev/tty 2>/dev/null || echo "")
                else
                    IFS= read -rs -n1 key3 || key3=""
                fi
                
                case "$key3" in
                    "A") # Up arrow
                        if [[ $current_index -gt 0 ]]; then
                            ((current_index--))
                        fi
                        ;;
                    "B") # Down arrow
                        if [[ $current_index -lt $((total_options - 1)) ]]; then
                            ((current_index++))
                        fi
                        ;;
                esac
            elif [[ -z "$key2" ]]; then
                # ESC key (no following character)
                restore_terminal
                trap - EXIT INT TERM
                IPCHECK_MENU_RESULT="FLAGS:CANCEL"
                return
            fi
        elif [[ "$key" == " " ]]; then
            # Space - toggle selection
            if [[ ${selected[$current_index]} -eq 0 ]]; then
                selected[$current_index]=1
            else
                selected[$current_index]=0
            fi
        elif [[ "$key" == "" ]] || [[ "$key" == $'\n' ]] || [[ "$key" == $'\r' ]]; then
            # Enter - confirm
            # Build selected flags string first
            local selected_flags=""
            for ((i=0; i<total_options; i++)); do
                if [[ ${selected[$i]} -eq 1 ]]; then
                    local flag="${options[$i]%%:*}"
                    selected_flags+="$flag"
                fi
            done
            
            # If nothing selected, use default (all basic checks)
            if [[ -z "$selected_flags" ]]; then
                selected_flags="qasrch"
            fi
            
            # Set result first, then restore terminal
            IPCHECK_MENU_RESULT="FLAGS:$selected_flags"
            restore_terminal
            trap - EXIT INT TERM
            return
        elif [[ "$key" == "q" ]] || [[ "$key" == "Q" ]]; then
            # q - cancel
            restore_terminal
            trap - EXIT INT TERM
            IPCHECK_MENU_RESULT="FLAGS:CANCEL"
            return
        fi
    done
    
    # This should not be reached, but just in case
    # Restore terminal settings
    restore_terminal
    trap - EXIT INT TERM
    
    # Build selected flags string
    local selected_flags=""
    for ((i=0; i<total_options; i++)); do
        if [[ ${selected[$i]} -eq 1 ]]; then
            local flag="${options[$i]%%:*}"
            selected_flags+="$flag"
        fi
    done
    
    # If nothing selected, cancel
    if [[ -z "$selected_flags" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:CANCEL"
        return
    fi
    
    # Set result before returning
    IPCHECK_MENU_RESULT="FLAGS:$selected_flags"
}

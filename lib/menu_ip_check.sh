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
    # Load API keys to check availability
    load_config
    
    # Check which API keys are available
    local has_ipqs_key=0
    local has_abuseipdb_key=0
    local has_ripe_key=0
    local has_ht_key=0
    
    if [[ -n "${IPQS_KEY:-}" ]]; then
        has_ipqs_key=1
    fi
    if [[ -n "${ABUSEIPDB_KEY:-}" ]]; then
        has_abuseipdb_key=1
    fi
    if [[ -n "${RIPE_KEY:-}" ]]; then
        has_ripe_key=1
    fi
    if [[ -n "${HT_KEY:-}" ]]; then
        has_ht_key=1
    fi
    
    # Define all options with their flags, descriptions, and API key requirements
    local -a options=(
        "q:IPQualityScore:Basic Checks:$has_ipqs_key"
        "a:AbuseIPDB:Basic Checks:$has_abuseipdb_key"
        "s:Scamalytics:Basic Checks:1"
        "r:RIPE Atlas:Basic Checks:$has_ripe_key"
        "c:Check-Host:Basic Checks:1"
        "h:HostTracker:Basic Checks:$has_ht_key"
        "g:IP Quality Score:Advanced Features:1"
        "d:CDN Detection:Advanced Features:1"
        "t:Routing Health:Advanced Features:1"
        "p:Port Scan:Advanced Features:1"
        "R:Reality Test:Advanced Features:1"
        "u:Usage History:Advanced Features:1"
        "n:Suggestions:Advanced Features:1"
        "j:JSON Output:Output Options:1"
        "l:Enable Logging:Output Options:1"
    )
    
    local total_options=${#options[@]}
    local current_index=0
    local -a selected=()
    
    # Initialize selected array (0 = not selected, 1 = selected)
    for ((i=0; i<total_options; i++)); do
        selected[$i]=0
    done
    
    # Function to restore terminal (for cleanup if needed)
    restore_terminal() {
        # No terminal settings to restore since we're not changing them
        :
    }
    
    # Function to display menu
    display_checkbox_menu() {
        clear
        
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Select Check Options / انتخاب گزینه‌های بررسی${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        
        local current_section=""
        local option_num=0
        
        # Display options grouped by section
        for ((i=0; i<total_options; i++)); do
            local option="${options[$i]}"
            local flag="${option%%:*}"
            local temp="${option#*:}"
            local desc="${temp%%:*}"
            temp="${temp#*:}"
            local section="${temp%%:*}"
            local has_key="${temp##*:}"
            
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
            local disabled=""
            
            # Check if option is disabled (no API key)
            if [[ "$has_key" == "0" ]]; then
                disabled=" (API key required)"
                # Use dim/gray color for disabled items
                if [[ $i -eq $current_index ]]; then
                    # Current item - highlight but grayed out
                    checkbox="${YELLOW}[ ]${NC}"
                    color="${YELLOW}"
                    echo -e "  ${color}▶${NC} ${YELLOW}[ ]${NC} ${YELLOW}$flag${NC} - ${YELLOW}$desc${NC}${YELLOW}$disabled${NC}"
                else
                    # Other items - grayed out (dimmed)
                    checkbox="${NC}[ ]${NC}"
                    color="${NC}"
                    # Use tput dim if available, otherwise just normal color
                    if command -v tput >/dev/null 2>&1; then
                        local dim=$(tput dim 2>/dev/null || echo "")
                        local nodim=$(tput sgr0 2>/dev/null || echo "")
                        echo -e "    ${dim}$checkbox${nodim} ${dim}$flag${nodim} - ${dim}$desc${nodim}${YELLOW}$disabled${NC}"
                    else
                        echo -e "    $checkbox $flag - $desc${YELLOW}$disabled${NC}"
                    fi
                fi
            else
                # Enabled option
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
            fi
        done
        
        echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}Instructions / راهنما:${NC}"
        echo -e "  ${BLUE}↑${NC}/${BLUE}↓${NC} - Move up/down / حرکت بالا/پایین"
        echo -e "  ${BLUE}Space${NC} - Toggle selection / تغییر انتخاب"
        echo -e "  ${BLUE}Enter${NC} - Confirm selection / تایید انتخاب"
        echo -e "  ${BLUE}q${NC} or ${BLUE}ESC${NC} - Cancel / لغو"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    }
    
    # Display menu once before loop
    display_checkbox_menu
    
    # Main loop
    while true; do
        # Read input - use read to properly capture Enter and other keys
        local input=""
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            # Read input line (Enter will be empty string or newline)
            IFS= read -r input < /dev/tty 2>/dev/null || input=""
        else
            # Fallback: read from stdin
            IFS= read -r input 2>/dev/null || input=""
        fi
        
        # Handle Enter key (empty input or just newline)
        if [[ -z "$input" ]] || [[ "$input" == $'\n' ]] || [[ "$input" == $'\r' ]]; then
            # Enter - confirm
            # Build selected flags string first
            local selected_flags=""
            for ((i=0; i<total_options; i++)); do
                if [[ ${selected[$i]} -eq 1 ]]; then
                    local flag="${options[$i]%%:*}"
                    selected_flags+="$flag"
                fi
            done
            
            # If nothing selected, show message and continue
            if [[ -z "$selected_flags" ]]; then
                # Show message briefly
                clear
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${YELLOW}⚠ Please select at least one option / لطفاً حداقل یک گزینه انتخاب کنید${NC}"
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                sleep 1.5 2>/dev/null || sleep 1
                display_checkbox_menu
                continue
            fi
            
            # Show confirmation with checkmark
            clear
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${GREEN}✓${NC} ${BLUE}Selected options confirmed / گزینه‌های انتخاب شده تایید شد${NC}"
            echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            sleep 0.8 2>/dev/null || sleep 0.5
            
            # Set result first, then restore terminal
            IPCHECK_MENU_RESULT="FLAGS:$selected_flags"
            restore_terminal
            trap - EXIT INT TERM
            return
        fi
        
        # Get first character for other keys
        local key="${input:0:1}"
        
        # Handle escape sequences (arrow keys and ESC)
        if [[ "$key" == $'\x1b' ]]; then
            # Check if it's an arrow key sequence
            if [[ ${#input} -ge 3 ]] && [[ "${input:1:1}" == "[" ]]; then
                # Arrow key sequence
                local key3="${input:2:1}"
                case "$key3" in
                    "A") # Up arrow
                        if [[ $current_index -gt 0 ]]; then
                            ((current_index--))
                        fi
                        display_checkbox_menu
                        ;;
                    "B") # Down arrow
                        if [[ $current_index -lt $((total_options - 1)) ]]; then
                            ((current_index++))
                        fi
                        display_checkbox_menu
                        ;;
                esac
            else
                # ESC key (standalone) or 'q'
                if [[ "$input" == "q" ]] || [[ "$input" == "Q" ]] || [[ "$key" == $'\x1b' ]]; then
                    restore_terminal
                    trap - EXIT INT TERM
                    IPCHECK_MENU_RESULT="FLAGS:CANCEL"
                    return
                fi
            fi
        elif [[ "$key" == " " ]]; then
            # Space - toggle selection (only if option is enabled)
            local option="${options[$current_index]}"
            local temp="${option#*:}"
            temp="${temp#*:}"
            local has_key="${temp##*:}"
            
            if [[ "$has_key" == "1" ]]; then
                if [[ ${selected[$current_index]} -eq 0 ]]; then
                    selected[$current_index]=1
                else
                    selected[$current_index]=0
                fi
                # Refresh menu to show updated selection
                display_checkbox_menu
            fi
        elif [[ "$input" == "q" ]] || [[ "$input" == "Q" ]]; then
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

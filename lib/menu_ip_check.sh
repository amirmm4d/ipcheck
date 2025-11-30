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
        local char=""
        local old_stty=""
        
        # Save terminal settings
        if command -v stty >/dev/null 2>&1; then
            old_stty=$(stty -g 2>/dev/null || echo "")
            if [[ -n "$old_stty" ]]; then
                # Set terminal to raw mode (no echo, no canonical mode)
                # Remove time 0 min 0 to allow blocking read
                stty -echo -icanon 2>/dev/null || true
            fi
        fi
        
        # Try to read from /dev/tty directly
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            # Read without timeout - will block until key is pressed
            IFS= read -rs -n1 char <&3 2>/dev/null || char=""
            exec 3<&-
        else
            # Fallback: try stdin
            IFS= read -rs -n1 char 2>/dev/null || char=""
        fi
        
        # Restore terminal settings
        if [[ -n "$old_stty" ]] && command -v stty >/dev/null 2>&1; then
            stty "$old_stty" 2>/dev/null || true
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
        
        # Read key input - wait for user input
        local key=""
        # Read character - will block until user presses a key
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
            elif [[ "$key2" == "" ]]; then
                # ESC key alone - exit
                IPCHECK_MENU_RESULT="FLAGS:CANCEL"
                return
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
        elif [[ "$key" == 'q' ]] || [[ "$key" == 'Q' ]]; then
            # Quit
            IPCHECK_MENU_RESULT="FLAGS:CANCEL"
            return
        fi
    done
}

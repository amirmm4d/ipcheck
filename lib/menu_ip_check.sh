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
    clear
    show_logo
    
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
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Select Check Options / انتخاب گزینه‌های بررسی${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    local current_section=""
    local option_num=0
    
    # Display options grouped by section
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
        
        ((option_num++))
        echo -e "  ${GREEN}$option_num)${NC} $flag - $desc"
    done
    
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Instructions:${NC}"
    echo -e "  • Enter option numbers separated by commas (e.g., 1,3,7)"
    echo -e "  • Enter 'all' to select all options"
    echo -e "  • Enter 'basic' to select all basic checks"
    echo -e "  • Enter 'advanced' to select all advanced features"
    echo -e "  • Enter flags directly (e.g., qagdt)"
    echo -e "  • Press Enter without input to skip (will run all basic checks)"
    echo -e "  • Enter 'q' or 'cancel' to go back"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -ne "${BLUE}👉 Your selection: ${NC}"
    
    local user_input=""
    if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
        exec 3< /dev/tty
        IFS= read -r user_input <&3
        exec 3<&-
    elif [[ -t 0 ]]; then
        IFS= read -r user_input
    else
        IFS= read -r user_input || user_input=""
    fi
    
    # Clean input
    user_input=$(printf '%s' "$user_input" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')
    
    # Handle special cases
    if [[ -z "$user_input" ]]; then
        # Empty input - cancel
        IPCHECK_MENU_RESULT="FLAGS:CANCEL"
        return
    elif [[ "$user_input" == "q" ]] || [[ "$user_input" == "cancel" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:CANCEL"
        return
    elif [[ "$user_input" == "all" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:qasrchgdtpRunjl"
        return
    elif [[ "$user_input" == "basic" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:qasrch"
        return
    elif [[ "$user_input" == "advanced" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:gdtpRun"
        return
    fi
    
    # Check if input contains numbers (option selection) or letters (flag selection)
    local selected_flags=""
    
    if [[ "$user_input" =~ [0-9] ]]; then
        # User entered numbers - parse them
        IFS=',' read -ra selections <<< "$user_input"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | tr -d '[:space:]')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [[ $sel -ge 1 ]] && [[ $sel -le ${#options[@]} ]]; then
                local idx=$((sel - 1))
                local flag="${options[$idx]%%:*}"
                if [[ "$selected_flags" != *"$flag"* ]]; then
                    selected_flags+="$flag"
                fi
            fi
        done
    else
        # User entered flags directly (e.g., "qagdt")
        # Validate and extract valid flags
        for ((i=0; i<${#user_input}; i++)); do
            local char="${user_input:$i:1}"
            # Check if this character is a valid flag
            for option in "${options[@]}"; do
                local flag="${option%%:*}"
                if [[ "$flag" == "$char" ]] && [[ "$selected_flags" != *"$flag"* ]]; then
                    selected_flags+="$flag"
                    break
                fi
            done
        done
    fi
    
    IPCHECK_MENU_RESULT="FLAGS:$selected_flags"
}

# --- IP Check Menu Functions ---

show_ip_check_menu() {
    show_logo
    
    # Use fzf for input method selection
    local menu_options=(
        "1) ✍️  Enter IP address(es) manually / وارد کردن دستی آدرس IP"
        "2) 🖥️  Check server's public IP / بررسی IP عمومی سرور"
        "3) 📄 Load from file / بارگذاری از فایل"
        "4) ⬅️  Back to main menu / بازگشت به منوی اصلی"
    )
    
    local selected
    selected=$(show_menu "📋 IP Check Options / گزینه‌های بررسی IP" "${menu_options[@]}")
    
    local input_method=""
    if [[ -n "$selected" ]]; then
        input_method=$(echo "$selected" | grep -o '^[0-9]' | head -1)
    fi
    
    if [[ -z "$input_method" ]]; then
        # Fallback to old menu
        clear
        show_logo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}📋 IP Check Options / گزینه‌های بررسی IP${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│${NC}  ${BLUE}Input Method / روش ورودی:${NC}"
        echo -e "${YELLOW}│${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}1)${NC} ${BLUE}✍️  Enter IP address(es) manually${NC} / ${BLUE}وارد کردن دستی آدرس IP${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}2)${NC} ${BLUE}🖥️  Check server's public IP${NC} / ${BLUE}بررسی IP عمومی سرور${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}3)${NC} ${BLUE}📄 Load from file${NC} / ${BLUE}بارگذاری از فایل${NC}"
        echo -e "${YELLOW}│${NC}  ${GREEN}4)${NC} ${BLUE}⬅️  Back to main menu${NC} / ${BLUE}بازگشت به منوی اصلی${NC}"
        echo -e "${YELLOW}└────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -ne "${BLUE}👉 Select input method (1-4): ${NC}"
        
        if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
            exec 3< /dev/tty
            IFS= read -r input_method <&3
            exec 3<&-
        elif [[ -t 0 ]]; then
            IFS= read -r input_method
        else
            IFS= read -r input_method || input_method=""
        fi
        input_method=$(printf '%s' "$input_method" | tr -d '\n\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi
    
    local ip_input=""
    local result=""
    case "$input_method" in
        1)
            # Use fzf to prompt for IP input (or fallback to read)
            ip_input=$(echo "" | fzf --print-query --height=3 --reverse --border \
                --header="📝 Enter IP address(es) (comma-separated) / وارد کردن آدرس IP" \
                --prompt="IP > " 2>/dev/null | head -1)
            
            if [[ -z "$ip_input" ]]; then
                # Fallback to regular read if fzf doesn't work
                echo -ne "${BLUE}📝 Enter IP address(es) (comma-separated): ${NC}"
                if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                    exec 3< /dev/tty
                    IFS= read -r ip_input <&3
                    exec 3<&-
                else
                    IFS= read -r ip_input
                fi
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
            # Use fzf to select file (with file browser)
            local file_path
            file_path=$(find . -type f 2>/dev/null | head -50 | \
                fzf --height=15 --reverse --border \
                --header="📁 Select file / انتخاب فایل" \
                --prompt="File > " \
                --preview="head -20 {} 2>/dev/null || echo 'Cannot preview'" \
                --preview-window=right:50%:wrap 2>/dev/null || echo "")
            
            if [[ -z "$file_path" ]]; then
                # Fallback to regular read
                echo -ne "${BLUE}📁 Enter file path: ${NC}"
                if [[ -c /dev/tty ]] && [[ -r /dev/tty ]]; then
                    exec 3< /dev/tty
                    IFS= read -r file_path <&3
                    exec 3<&-
                else
                    IFS= read -r file_path
                fi
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
    
    # Build fzf menu options with sections and availability
    local -a menu_items=()
    
    # Basic Checks section
    menu_items+=("━━━ Basic Checks / بررسی‌های پایه ━━━")
    if [[ $has_ipqs_key -eq 1 ]]; then
        menu_items+=("q - IPQualityScore")
    else
        menu_items+=("q - IPQualityScore (API key required)")
    fi
    if [[ $has_abuseipdb_key -eq 1 ]]; then
        menu_items+=("a - AbuseIPDB")
    else
        menu_items+=("a - AbuseIPDB (API key required)")
    fi
    menu_items+=("s - Scamalytics")
    if [[ $has_ripe_key -eq 1 ]]; then
        menu_items+=("r - RIPE Atlas")
    else
        menu_items+=("r - RIPE Atlas (API key required)")
    fi
    menu_items+=("c - Check-Host")
    if [[ $has_ht_key -eq 1 ]]; then
        menu_items+=("h - HostTracker")
    else
        menu_items+=("h - HostTracker (API key required)")
    fi
    
    # Advanced Features section
    menu_items+=("━━━ Advanced Features / ویژگی‌های پیشرفته ━━━")
    menu_items+=("g - IP Quality Score")
    menu_items+=("d - CDN Detection")
    menu_items+=("t - Routing Health")
    menu_items+=("p - Port Scan")
    menu_items+=("R - Reality Test")
    menu_items+=("u - Usage History")
    menu_items+=("n - Suggestions")
    
    # Output Options section
    menu_items+=("━━━ Output Options / گزینه‌های خروجی ━━━")
    menu_items+=("j - JSON Output")
    menu_items+=("l - Enable Logging")
    
    # Use universal multi-select menu
    local selected_items
    selected_items=$(show_multi_menu "Select Check Options / انتخاب گزینه‌های بررسی" "${menu_items[@]}")
    
    if [[ -z "$selected_items" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:CANCEL"
        return
    fi
    
    # Extract flags from selected items (skip section headers)
    local selected_flags=""
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue
        # Skip section headers (lines starting with ━━━)
        if [[ "$line" =~ ^━━━ ]]; then
            continue
        fi
        # Extract flag (first character before space and dash)
        # Format: "q - IPQualityScore" or "q - IPQualityScore (API key required)"
        if [[ "$line" =~ ^([a-zA-Z0-9])[[:space:]]*-[[:space:]]* ]]; then
            local flag="${BASH_REMATCH[1]}"
            # Check if option is available (not disabled - doesn't contain "API key required")
            if [[ ! "$line" =~ "API key required" ]]; then
                selected_flags+="$flag"
            fi
        fi
    done <<< "$selected_items"
    
    if [[ -z "$selected_flags" ]]; then
        IPCHECK_MENU_RESULT="FLAGS:CANCEL"
        return
    fi
    
    IPCHECK_MENU_RESULT="FLAGS:$selected_flags"
}

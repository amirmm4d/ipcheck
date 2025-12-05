# --- Main Logic ---

usage() {
    echo "Usage: ipcheck [options]"
    echo
    echo "Input Options (at least one is required):"
    echo "  -i <IPs>        Comma-separated list of IP addresses to check."
    echo "  -f <path>       Path to a file containing a list of IPs (one per line)."
    echo "  -S              Automatically check the public IP of this server."
    echo
    echo "Check Selection (if none specified, all available checks run):"
    echo "  -a              Run AbuseIPDB check"
    echo "  -s              Run Scamalytics check"
    echo "  -r              Run RIPE Atlas check"
    echo "  -c              Run Check-Host ping test"
    echo "  -h              Run HostTracker check"
    echo
    echo "Advanced Features:"
    echo "  -g              Generate IP Quality Clean Score (0-100)"
    echo "  -d              Detect CDN/proxy presence (Cloudflare, AWS, etc.)"
    echo "  -t              Run routing health analysis (requires mtr/traceroute)"
    echo "  -p              Scan critical ports for risk assessment"
    echo "  -R              Test Sing-box Reality fingerprint compatibility"
    echo "  -u              Check prior usage (VPN/proxy/botnet history)"
    echo "  -n              Generate smart suggestions based on results"
    echo
    echo "Output & Behavior Options:"
    echo "  -j              Output the report in JSON format instead of a table."
    echo "  -F <N>          Exit with error if N or more checks fail (default: 1)."
    echo "  -l <DIR>        Enable logging to specified directory."
    echo "  -L txt|json     Log format: txt or json (default: txt)"
    echo "  -v              Ask to install VPN after server check (interactive)"
    echo
    echo "Other Options:"
    echo "  -U              Uninstall ipcheck (requires root)"
    echo "  -H              Show this help message."
}

main() {
    # If no arguments, run automatic full check on server IP
    if [[ $# -eq 0 ]]; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}🔍 Detecting server's public IP...${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        local server_ip
        server_ip=$(get_server_ip)
        
        if [[ -z "$server_ip" ]]; then
            echo -e "${RED}❌ Error: Could not determine server's public IP.${NC}" >&2
            echo -e "${YELLOW}Please use: ipcheck -i <IP> or ipcheck -S${NC}" >&2
            exit 1
        fi
        
        echo -e "${GREEN}✓ Server's public IP: ${server_ip}${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}Running full analysis with all available checks...${NC}"
        echo -e "${YELLOW}Note: Checks requiring API keys will be skipped if keys are not configured.${NC}"
        echo ""
        
        # Run with all features enabled, but VPN installation disabled
        # Use -i to pass the IP directly instead of -S (which would call get_server_ip again)
        # -A: all checks and all advanced features
        # VPN installation is NOT requested (no -v flag)
        # Temporarily disable exit on error to allow process_main_args to handle errors gracefully
        set +e
        process_main_args -i "$server_ip" -A
        local exit_code=$?
        set -e
        
        # If process_main_args returned an error, exit with that code
        if [[ $exit_code -ne 0 ]]; then
            exit $exit_code
        fi
        
        # Otherwise, exit successfully
        exit 0
    fi
    
    # Pre-process arguments to handle combined flags like -gdt
    local processed_args=()
    local args_array=("$@")
    local i=0
    while [[ $i -lt ${#args_array[@]} ]]; do
        local arg="${args_array[$i]}"
        local next_arg="${args_array[$((i+1))]:-}"
        
        # Check if it's a combined flag (starts with - and has multiple letters, not followed by a number)
        if [[ "$arg" =~ ^-[a-zA-Z]{2,}$ ]] && [[ ! "$next_arg" =~ ^[0-9]+$ ]] && [[ "$arg" != "-"*[0-9]* ]]; then
            # Split combined flags: -gdt -> -g -d -t
            local flags="${arg#-}"
            for (( j=0; j<${#flags}; j++ )); do
                processed_args+=("-${flags:$j:1}")
            done
        else
            processed_args+=("$arg")
        fi
        ((i++))
    done
    
    # Call process_main_args with processed arguments
    process_main_args "${processed_args[@]}"
    exit $?
}


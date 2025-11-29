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
    echo "  -q              Run IPQualityScore check"
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
    # If no arguments, show interactive menu
    if [[ $# -eq 0 ]]; then
        interactive_menu
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


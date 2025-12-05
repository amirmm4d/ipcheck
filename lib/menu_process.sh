# --- Menu Processing Functions ---

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
    
    # Reset VPN installation flag (will be set to true only if -v flag is provided)
    ASK_VPN_INSTALL=false
    
    # Note: ENABLE_* flags are global variables defined in ipcheck
    # They will be set by -A flag or individual flags (-g, -d, -t, etc.)
    # We don't reset them here to preserve their state from previous calls
    
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
            shift 2  # Shift both -i and the IP argument
            ;;
        -f)
            if [[ -f "$2" ]]; then
                mapfile -t FILE_IPS <"$2"
                for ip in "${FILE_IPS[@]}"; do [[ -n "$ip" ]] && ips_to_check+=("$ip"); done
            else
                echo -e "${RED}Error: File not found at '$2'${NC}" >&2
                return 1
            fi
            shift 2  # Shift both -f and the file path argument
            ;;
        -S)
            local server_ip
            server_ip=$(get_server_ip)
            if [[ -n "$server_ip" ]]; then 
                ips_to_check+=("$server_ip")
                # Only set ASK_VPN_INSTALL=true if -v flag is explicitly provided
                # Default is false (no VPN installation prompt)
                # This will be set to true later if -v flag is found
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
            shift 2  # Shift both -o/--output and the format value
            ;;
        -F)
            fail_threshold="$2"
            if ! [[ "$fail_threshold" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Error: -F requires a number.${NC}"
                return 1
            fi
            shift 2  # Shift both -F and the threshold value
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
            shift 2  # Shift both -l and the directory path
            ;;
        -L)
            LOG_FORMAT="$2"
            if [[ "$LOG_FORMAT" != "txt" ]] && [[ "$LOG_FORMAT" != "json" ]]; then
                echo -e "${RED}Error: -L must be 'txt' or 'json'.${NC}" >&2
                return 1
            fi
            shift 2  # Shift both -L and the format value
            ;;
        -g) ENABLE_SCORING=true ;;
        -d) ENABLE_CDN_CHECK=true ;;
        -t) ENABLE_ROUTING_CHECK=true ;;
        -p) ENABLE_PORT_SCAN=true ;;
        -R) ENABLE_REALITY_TEST=true ;;
        -u) ENABLE_USAGE_HISTORY=true ;;
        -n) ENABLE_SUGGESTIONS=true ;;
        -v) ASK_VPN_INSTALL=true ;;
        -A|--all)
            # Enable all checks and all advanced features
            enable_ipqs=true
            enable_abuseipdb=true
            enable_scamalytics=true
            enable_ripe=true
            enable_host=true
            enable_hosttracker=true
            ENABLE_SCORING=true
            ENABLE_CDN_CHECK=true
            ENABLE_ROUTING_CHECK=true
            ENABLE_PORT_SCAN=true
            ENABLE_REALITY_TEST=true
            ENABLE_USAGE_HISTORY=true
            ENABLE_SUGGESTIONS=true
            run_all_checks=false
            ;;
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
        # Use set +e to ensure all checks run even if some fail
        set +e
        local pids=()
        $enable_ipqs && check_ipqs "$ip" "$ip_dir" & pids+=($!)
        $enable_abuseipdb && check_abuseipdb "$ip" "$ip_dir" & pids+=($!)
        $enable_scamalytics && check_scamalytics "$ip" "$ip_dir" & pids+=($!)
        $enable_ripe && check_ripe "$ip" "$ip_dir" & pids+=($!)
        $enable_host && check_host "$ip" "$ip_dir" & pids+=($!)
        $enable_hosttracker && check_hosttracker "$ip" "$ip_dir" & pids+=($!)
        
        # Additional API checks for scoring
        echo "DEBUG: ENABLE_SCORING=$ENABLE_SCORING" >&2
        if $ENABLE_SCORING; then
            log_message "Running scoring API checks for $ip" "DEBUG"
            check_ipapi "$ip" "$ip_dir" & pids+=($!)
            check_ipregistry "$ip" "$ip_dir" & pids+=($!)
            check_spamhaus "$ip" "$ip_dir" & pids+=($!)
        else
            log_message "Scoring disabled, skipping ipapi/ipregistry/spamhaus checks" "DEBUG"
        fi
        
        # Wait for all checks to complete
        for pid in "${pids[@]}"; do
            wait "$pid" || true
        done
        # Restore error handling
        set -e
        
        # Run advanced features (sequential, as they may depend on previous results)
        # Use set +e to ensure all checks run even if some fail
        set +e
        
        # Debug: Log which advanced features are enabled
        echo "DEBUG: Advanced features - CDN=$ENABLE_CDN_CHECK, Scoring=$ENABLE_SCORING, Routing=$ENABLE_ROUTING_CHECK, Port=$ENABLE_PORT_SCAN, Reality=$ENABLE_REALITY_TEST, Usage=$ENABLE_USAGE_HISTORY, Suggestions=$ENABLE_SUGGESTIONS" >&2
        log_message "Advanced features enabled: CDN=$ENABLE_CDN_CHECK, Scoring=$ENABLE_SCORING, Routing=$ENABLE_ROUTING_CHECK, Port=$ENABLE_PORT_SCAN, Reality=$ENABLE_REALITY_TEST, Usage=$ENABLE_USAGE_HISTORY, Suggestions=$ENABLE_SUGGESTIONS" "DEBUG"
        
        if $ENABLE_CDN_CHECK; then
            log_message "Running CDN detection for $ip" "DEBUG"
            detect_cdn "$ip" "$ip_dir" || true
        fi
        
        if $ENABLE_SCORING; then
            log_message "Running scoring for $ip" "DEBUG"
            generate_score_report "$ip" || true
            generate_abuse_report "$ip" "$ip_dir" || true
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
            generate_score_report "$ip" || true
        fi
        
        if $ENABLE_ROUTING_CHECK; then
            log_message "Running routing check for $ip" "DEBUG"
            test_routing "$ip" "$ip_dir" || true
        fi
        
        if $ENABLE_PORT_SCAN; then
            log_message "Running port scan for $ip" "DEBUG"
            scan_ports "$ip" "$ip_dir" || true
        fi
        
        if $ENABLE_REALITY_TEST; then
            log_message "Running reality test for $ip" "DEBUG"
            test_reality_fingerprint "$ip" "$ip_dir" || true
        fi
        
        if $ENABLE_USAGE_HISTORY; then
            log_message "Running usage history check for $ip" "DEBUG"
            check_usage_history "$ip" "$ip_dir" || true
        fi
        
        if $ENABLE_SUGGESTIONS; then
            log_message "Running suggestions generation for $ip" "DEBUG"
            generate_suggestions "$ip" "$ip_dir" || true
        fi
        
        # Restore error handling
        set -e
        
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
                ask_vpn_installation "${ips_to_check[0]}"
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

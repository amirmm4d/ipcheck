# --- Port Scanning Functions ---

scan_ports() {
    local ip="$1" ip_dir="$2"
    log_message "Scanning ports for $ip" "INFO"
    
    local ports=(22 80 443 8080 8443 53 3389)
    local open_ports=()
    local closed_ports=()
    local filtered_ports=()
    local risk_level="low"
    
    # Check for scanning tools
    local has_nc=false has_ss=false
    command -v nc &>/dev/null && has_nc=true
    command -v ss &>/dev/null && has_ss=true
    
    if ! $has_nc && ! $has_ss; then
        write_status "$ip_dir" "Port_Scan" "${YELLOW}SKIPPED" "nc/ss not available"
        log_message "Port scan skipped: tools not available" "WARN"
        return
    fi
    
    echo -e "${YELLOW}⚠️  Port scanning may be considered intrusive. Proceeding...${NC}" >&2
    
    for port in "${ports[@]}"; do
        local status="closed"
        if $has_nc; then
            if timeout 2 nc -z -v "$ip" "$port" &>/dev/null; then
                status="open"
                open_ports+=("$port")
            fi
        elif $has_ss; then
            # ss can't directly scan remote ports, use nc fallback or skip
            if timeout 2 bash -c "echo > /dev/tcp/$ip/$port" 2>/dev/null; then
                status="open"
                open_ports+=("$port")
            else
                status="closed"
                closed_ports+=("$port")
            fi
        fi
        log_message "Port $port: $status" "DEBUG"
    done
    
    # Assess risk
    local risk_score=0
    for port in "${open_ports[@]}"; do
        case "$port" in
            22) risk_score=$((risk_score + 5)) ;;   # SSH - normal
            80|443) risk_score=$((risk_score + 2)) ;; # HTTP/HTTPS - normal
            8080|8443) risk_score=$((risk_score + 10)) ;; # Alternative web ports - higher risk
            53) risk_score=$((risk_score + 15)) ;;   # DNS - unusual if open
            3389) risk_score=$((risk_score + 20)) ;; # RDP - high risk
        esac
    done
    
    if [[ $risk_score -ge 30 ]]; then
        risk_level="high"
    elif [[ $risk_score -ge 15 ]]; then
        risk_level="medium"
    fi
    
    # Generate port scan report
    local port_json
    port_json=$(jq -n \
        --arg ip "$ip" \
        --argjson open "$(IFS=','; echo "[${open_ports[*]}]")" \
        --argjson closed "$(IFS=','; echo "[${closed_ports[*]}]")" \
        --arg risk "$risk_level" \
        --argjson score "$risk_score" \
        '{
            ip: $ip,
            open_ports: ($open | fromjson),
            closed_ports: ($closed | fromjson),
            risk_level: $risk,
            risk_score: ($score | tonumber)
        }')
    
    echo "$port_json" > "$ip_dir/port_scan.json"
    PORT_RESULTS["$ip"]="$port_json"
    
    local details="Open: ${#open_ports[@]}, Risk: $risk_level"
    if [[ "$risk_level" == "high" ]]; then
        write_status "$ip_dir" "Port_Scan" "${RED}HIGH_RISK" "$details"
        log_message "Port scan HIGH RISK for $ip: $details" "WARN"
    elif [[ "$risk_level" == "medium" ]]; then
        write_status "$ip_dir" "Port_Scan" "${YELLOW}MEDIUM_RISK" "$details"
        log_message "Port scan MEDIUM RISK for $ip: $details" "INFO"
    else
        write_status "$ip_dir" "Port_Scan" "${GREEN}LOW_RISK" "$details"
        log_message "Port scan LOW RISK for $ip: $details" "INFO"
    fi
}


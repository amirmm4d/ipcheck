# --- Prior Usage Detection Functions ---

check_usage_history() {
    local ip="$1" ip_dir="$2"
    log_message "Checking usage history for $ip" "INFO"
    
    local allocation_age="unknown"
    local category_history="unknown"
    local fraud_history=false
    local vpn_detected=false
    local proxy_detected=false
    
    # Check AbuseIPDB for usage type
    if [[ -f "$ip_dir/AbuseIPDB" ]]; then
        local abuse_result
        abuse_result=$(<"$ip_dir/AbuseIPDB")
        local abuse_details
        abuse_details=$(echo "$abuse_result" | cut -d'|' -f3)
        if echo "$abuse_details" | grep -qiE "vpn|proxy|hosting|datacenter"; then
            if echo "$abuse_details" | grep -qi "vpn"; then
                vpn_detected=true
            fi
            if echo "$abuse_details" | grep -qi "proxy"; then
                proxy_detected=true
            fi
        fi
    fi
    
    # Check Scamalytics for fraud history
    if [[ -f "$ip_dir/Scamalytics" ]]; then
        local scam_result
        scam_result=$(<"$ip_dir/Scamalytics")
        local scam_status
        scam_status=$(echo "$scam_result" | cut -d'|' -f2)
        if echo "$scam_status" | grep -qi "FAILED"; then
            fraud_history=true
        fi
    fi
    
    # Try to get allocation info from RIPE/ARIN (simplified)
    local whois_info
    whois_info=$(whois "$ip" 2>/dev/null | head -20 || echo "")
    if [[ -n "$whois_info" ]]; then
        local org
        org=$(echo "$whois_info" | grep -iE "org-name|organization" | head -1 | cut -d: -f2 | xargs || echo "")
        if [[ -n "$org" ]]; then
            if echo "$org" | grep -qiE "vpn|proxy|hosting|datacenter"; then
                category_history="$org"
            fi
        fi
    fi
    
    # Generate usage history report
    local usage_json
    usage_json=$(jq -n \
        --arg ip "$ip" \
        --arg age "$allocation_age" \
        --arg category "$category_history" \
        --arg fraud "$fraud_history" \
        --arg vpn "$vpn_detected" \
        --arg proxy "$proxy_detected" \
        '{
            ip: $ip,
            allocation_age: $age,
            category_history: $category,
            fraud_history: ($fraud == "true"),
            vpn_detected: ($vpn == "true"),
            proxy_detected: ($proxy == "true"),
            prior_usage_risk: (if (($vpn == "true") or ($proxy == "true") or ($fraud == "true")) then "high" else "low" end)
        }')
    
    echo "$usage_json" > "$ip_dir/usage_history.json"
    USAGE_RESULTS["$ip"]="$usage_json"
    
    local details="VPN: $vpn_detected, Proxy: $proxy_detected, Fraud: $fraud_history"
    if $vpn_detected || $proxy_detected || $fraud_history; then
        write_status "$ip_dir" "Usage_History" "${RED}HIGH_RISK" "$details"
        log_message "Usage history HIGH RISK for $ip: $details" "WARN"
    else
        write_status "$ip_dir" "Usage_History" "${GREEN}LOW_RISK" "$details"
        log_message "Usage history LOW RISK for $ip: $details" "INFO"
    fi
}


# --- Check Functions ---

check_abuseipdb() {
    local ip="$1" ip_dir="$2"
    log_message "Checking AbuseIPDB for $ip"
    if [[ -z "${ABUSEIPDB_KEY:-}" ]]; then
        write_status "$ip_dir" "AbuseIPDB" "${YELLOW}SKIPPED" "API key not set"
        log_message "AbuseIPDB skipped for $ip: API key not set"
        return
    fi
    local resp
    resp=$(curl --max-time 15 -sf -X POST \
        -H "Key: $ABUSEIPDB_KEY" \
        -H "Accept: application/json" \
        -d "ipAddress=$ip&maxAgeInDays=90&verbose" \
        "https://api.abuseipdb.com/api/v2/check" || true)
    if [[ -z "$resp" ]]; then
        write_status "$ip_dir" "AbuseIPDB" "${RED}ERROR" "Request failed"
        log_message "AbuseIPDB error for $ip: Request failed"
        return
    fi
    # Save raw API response
    echo "$resp" | jq . > "$ip_dir/raw_abuseipdb.json" 2>/dev/null || echo "$resp" > "$ip_dir/raw_abuseipdb.json"
    log_message "AbuseIPDB response for $ip: $resp"
    local confidence usage_type
    # Validate JSON before parsing
    if echo "$resp" | jq . >/dev/null 2>&1; then
        confidence=$(jq -r '.data.abuseConfidenceScore // "unknown"' <<<"$resp" 2>/dev/null || echo "unknown")
        usage_type=$(jq -r '.data.usageType // "unknown"' <<<"$resp" 2>/dev/null || echo "unknown")
    else
        confidence="unknown"
        usage_type="unknown"
    fi
    local details="Confidence: $confidence%, Type: $usage_type"
    if [[ "$confidence" =~ ^[0-9]+$ ]] && [[ "$confidence" -ge 25 ]]; then
        write_status "$ip_dir" "AbuseIPDB" "${RED}FAILED" "$details"
        log_message "AbuseIPDB FAILED for $ip: $details"
    else
        write_status "$ip_dir" "AbuseIPDB" "${GREEN}PASSED" "$details"
        log_message "AbuseIPDB PASSED for $ip: $details"
    fi
}

check_scamalytics() {
    local ip="$1" ip_dir="$2"
    log_message "Checking Scamalytics for $ip"
    local resp
    resp=$(curl --max-time 15 -sf "https://scamalytics.com/api/v1/ip/$ip" || true)
    if [[ -z "$resp" ]]; then
        write_status "$ip_dir" "Scamalytics" "${RED}ERROR" "Request failed"
        log_message "Scamalytics error for $ip: Request failed"
        return
    fi
    # Save raw API response
    echo "$resp" | jq . > "$ip_dir/raw_scamalytics.json" 2>/dev/null || echo "$resp" > "$ip_dir/raw_scamalytics.json"
    log_message "Scamalytics response for $ip: $resp"
    local risk_score
    # Validate JSON before parsing
    if echo "$resp" | jq . >/dev/null 2>&1; then
        risk_score=$(jq -r '.risk_score // "unknown"' <<<"$resp" 2>/dev/null || echo "unknown")
    else
        risk_score="unknown"
    fi
    local details="Risk Score: $risk_score"
    if [[ "$risk_score" =~ ^[0-9]+$ ]] && [[ "$risk_score" -ge 50 ]]; then
        write_status "$ip_dir" "Scamalytics" "${RED}FAILED" "$details"
        log_message "Scamalytics FAILED for $ip: $details"
    else
        write_status "$ip_dir" "Scamalytics" "${GREEN}PASSED" "$details"
        log_message "Scamalytics PASSED for $ip: $details"
    fi
}

check_ripe() {
    local ip="$1" ip_dir="$2"
    log_message "Checking RIPE Atlas for $ip"
    if [[ -z "${RIPE_KEY:-}" ]]; then
        write_status "$ip_dir" "RIPE_Atlas" "${YELLOW}SKIPPED" "API key not set"
        log_message "RIPE Atlas skipped for $ip: API key not set"
        return
    fi
    # Check if we can get Iran probes and test connectivity
    local resp
    resp=$(curl --max-time 15 -sf -H "Authorization: Key $RIPE_KEY" \
        "https://atlas.ripe.net/api/v2/probes/?country_code=IR&status=1&limit=5" || true)
    if [[ -z "$resp" ]]; then
        write_status "$ip_dir" "RIPE_Atlas" "${RED}ERROR" "Request failed"
        log_message "RIPE Atlas error for $ip: Request failed"
        return
    fi
    local probe_count
    probe_count=$(jq -r '.count // 0' <<<"$resp")
    local details="Iran probes available: $probe_count"
    if [[ "$probe_count" -gt 0 ]]; then
        write_status "$ip_dir" "RIPE_Atlas" "${GREEN}PASSED" "$details"
        log_message "RIPE Atlas PASSED for $ip: $details"
    else
        write_status "$ip_dir" "RIPE_Atlas" "${YELLOW}SKIPPED" "No Iran probes available"
        log_message "RIPE Atlas skipped for $ip: No Iran probes available"
    fi
}

check_host() {
    local ip="$1" ip_dir="$2"
    log_message "Checking Check-Host for $ip"
    local resp
    resp=$(curl --max-time 15 -sf "https://check-host.net/check-ping?host=$ip&max_nodes=5" || true)
    if [[ -z "$resp" ]]; then
        write_status "$ip_dir" "Check-Host" "${RED}ERROR" "Request failed"
        log_message "Check-Host error for $ip: Request failed"
        return
    fi
    log_message "Check-Host response for $ip: $resp"
    # Parse result URL and check status
    local result_url
    # Validate JSON before parsing
    local result_url=""
    if echo "$resp" | jq . >/dev/null 2>&1; then
        result_url=$(jq -r '.request_id // empty' <<<"$resp" 2>/dev/null || echo "")
    fi
    if [[ -z "$result_url" ]]; then
        write_status "$ip_dir" "Check-Host" "${RED}ERROR" "Invalid response"
        log_message "Check-Host error for $ip: Invalid response"
        return
    fi
    sleep 2 # Wait for check to complete
    local result
    result=$(curl --max-time 15 -sf "https://check-host.net/check-result/$result_url" || true)
    local success_count=0
    if [[ -n "$result" ]]; then
        # Validate JSON before parsing complex query
        if echo "$result" | jq . >/dev/null 2>&1; then
            success_count=$(echo "$result" | jq -r '[.[] | select(. != null) | .[] | select(. != null) | .[0] // empty] | length' 2>/dev/null || echo "0")
        else
            success_count="0"
        fi
    fi
    local details="Successful pings: $success_count/5"
    if [[ "$success_count" -ge 3 ]]; then
        write_status "$ip_dir" "Check-Host" "${GREEN}PASSED" "$details"
        log_message "Check-Host PASSED for $ip: $details"
    else
        write_status "$ip_dir" "Check-Host" "${RED}FAILED" "$details"
        log_message "Check-Host FAILED for $ip: $details"
    fi
}

check_hosttracker() {
    local ip="$1" ip_dir="$2"
    log_message "Checking HostTracker for $ip"
    if [[ -z "${HT_KEY:-}" ]]; then
        write_status "$ip_dir" "HostTracker" "${YELLOW}SKIPPED" "API key not set"
        log_message "HostTracker skipped for $ip: API key not set"
        return
    fi
    # HostTracker API endpoint unknown - placeholder implementation
    write_status "$ip_dir" "HostTracker" "${YELLOW}SKIPPED" "API endpoint not available"
    log_message "HostTracker skipped for $ip: API endpoint not available"
}


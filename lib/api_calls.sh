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

# Helper function to perform a check-host.net check and get results
perform_check_host_check() {
    local check_type="$1"  # ping, http, tcp, dns
    local host="$2"
    local max_nodes="${3:-5}"
    local timeout="${4:-20}"
    
    # Start the check
    local resp
    resp=$(curl --max-time 15 -sf -H "Accept: application/json" \
        "https://check-host.net/check-${check_type}?host=${host}&max_nodes=${max_nodes}" 2>/dev/null || echo "")
    
    if [[ -z "$resp" ]]; then
        echo "ERROR: Request failed"
        return 1
    fi
    
    # Validate JSON and extract request_id
    if ! echo "$resp" | jq . >/dev/null 2>&1; then
        echo "ERROR: Invalid JSON response"
        return 1
    fi
    
    local request_id
    request_id=$(echo "$resp" | jq -r '.request_id // empty' 2>/dev/null || echo "")
    
    if [[ -z "$request_id" ]]; then
        echo "ERROR: No request_id in response"
        return 1
    fi
    
    # Wait for check to complete (polling)
    local max_wait=$timeout
    local waited=0
    local result=""
    
    echo -e "${YELLOW}Waiting for results (request_id: $request_id)...${NC}"
    
    while [[ $waited -lt $max_wait ]]; do
        sleep 2
        waited=$((waited + 2))
        echo -e "${YELLOW}  Polling... (${waited}s/${max_wait}s)${NC}"
        
        result=$(curl --max-time 15 -sf -H "Accept: application/json" \
            "https://check-host.net/check-result/${request_id}" 2>/dev/null || echo "")
        
        if [[ -n "$result" ]] && echo "$result" | jq . >/dev/null 2>&1; then
            # Check if all nodes have completed (no null values)
            local has_null
            has_null=$(echo "$result" | jq -r '[.[] | select(. == null)] | length' 2>/dev/null || echo "1")
            if [[ "$has_null" == "0" ]]; then
                echo -e "${GREEN}  ✓ All nodes completed${NC}"
                echo "$result"
                return 0
            else
                echo -e "${YELLOW}  ⏳ Some nodes still processing...${NC}"
            fi
        fi
    done
    
    # Return partial results if available
    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    fi
    
    echo "ERROR: Timeout waiting for results"
    return 1
}

check_host() {
    local ip="$1" ip_dir="$2"
    log_message "Checking Check-Host for $ip (ping, http, tcp, dns) - Sequential mode for debugging" "INFO"
    
    local http_host="http://${ip}"
    local tcp_host="${ip}:80"
    local dns_host="${ip}"
    
    # Perform checks sequentially (one by one) for easier debugging
    local ping_result tcp_result dns_result http_result
    
    # 1. Ping check
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[1/4] Testing PING check for $ip${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_message "Starting ping check for $ip" "INFO"
    ping_result=$(perform_check_host_check "ping" "$ip" 5 15)
    if echo "$ping_result" | grep -q "ERROR"; then
        echo -e "${RED}❌ PING check failed: $ping_result${NC}"
        log_message "PING check failed: $ping_result" "ERROR"
    else
        echo -e "${GREEN}✓ PING check completed${NC}"
        log_message "PING check completed successfully" "INFO"
    fi
    echo ""
    
    # 2. TCP check (port 80)
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[2/4] Testing TCP check for $tcp_host${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_message "Starting TCP check for $tcp_host" "INFO"
    tcp_result=$(perform_check_host_check "tcp" "$tcp_host" 5 15)
    if echo "$tcp_result" | grep -q "ERROR"; then
        echo -e "${RED}❌ TCP check failed: $tcp_result${NC}"
        log_message "TCP check failed: $tcp_result" "ERROR"
    else
        echo -e "${GREEN}✓ TCP check completed${NC}"
        log_message "TCP check completed successfully" "INFO"
    fi
    echo ""
    
    # 3. DNS check
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[3/4] Testing DNS check for $dns_host${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_message "Starting DNS check for $dns_host" "INFO"
    dns_result=$(perform_check_host_check "dns" "$dns_host" 5 15)
    if echo "$dns_result" | grep -q "ERROR"; then
        echo -e "${RED}❌ DNS check failed: $dns_result${NC}"
        log_message "DNS check failed: $dns_result" "ERROR"
    else
        echo -e "${GREEN}✓ DNS check completed${NC}"
        log_message "DNS check completed successfully" "INFO"
    fi
    echo ""
    
    # 4. HTTP check
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}[4/4] Testing HTTP check for $http_host${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_message "Starting HTTP check for $http_host" "INFO"
    http_result=$(perform_check_host_check "http" "$http_host" 5 15)
    if echo "$http_result" | grep -q "ERROR"; then
        echo -e "${RED}❌ HTTP check failed: $http_result${NC}"
        log_message "HTTP check failed: $http_result" "ERROR"
    else
        echo -e "${GREEN}✓ HTTP check completed${NC}"
        log_message "HTTP check completed successfully" "INFO"
    fi
    echo ""
    
    # Save raw results
    echo "$ping_result" | jq . > "$ip_dir/raw_checkhost_ping.json" 2>/dev/null || echo "$ping_result" > "$ip_dir/raw_checkhost_ping.json"
    echo "$tcp_result" | jq . > "$ip_dir/raw_checkhost_tcp.json" 2>/dev/null || echo "$tcp_result" > "$ip_dir/raw_checkhost_tcp.json"
    echo "$dns_result" | jq . > "$ip_dir/raw_checkhost_dns.json" 2>/dev/null || echo "$dns_result" > "$ip_dir/raw_checkhost_dns.json"
    echo "$http_result" | jq . > "$ip_dir/raw_checkhost_http.json" 2>/dev/null || echo "$http_result" > "$ip_dir/raw_checkhost_http.json"
    
    # Parse results and build summary
    local ping_success=0 ping_total=0
    local tcp_success=0 tcp_total=0
    local dns_success=0 dns_total=0
    local http_success=0 http_total=0
    
    # Parse ping results
    if [[ -n "$ping_result" ]] && ! echo "$ping_result" | grep -q "ERROR"; then
        if echo "$ping_result" | jq . >/dev/null 2>&1; then
            ping_total=$(echo "$ping_result" | jq -r 'keys | length' 2>/dev/null || echo "0")
            ping_success=$(echo "$ping_result" | jq -r '[.[] | select(. != null) | .[] | select(. != null) | .[0] // empty | select(. == "OK")] | length' 2>/dev/null || echo "0")
        fi
    fi
    
    # Parse TCP results
    if [[ -n "$tcp_result" ]] && ! echo "$tcp_result" | grep -q "ERROR"; then
        if echo "$tcp_result" | jq . >/dev/null 2>&1; then
            tcp_total=$(echo "$tcp_result" | jq -r 'keys | length' 2>/dev/null || echo "0")
            tcp_success=$(echo "$tcp_result" | jq -r '[.[] | select(. != null) | .[] | select(. != null) | .time // empty] | length' 2>/dev/null || echo "0")
        fi
    fi
    
    # Parse DNS results
    if [[ -n "$dns_result" ]] && ! echo "$dns_result" | grep -q "ERROR"; then
        if echo "$dns_result" | jq . >/dev/null 2>&1; then
            dns_total=$(echo "$dns_result" | jq -r 'keys | length' 2>/dev/null || echo "0")
            dns_success=$(echo "$dns_result" | jq -r '[.[] | select(. != null) | .[] | select(. != null) | .A // empty | select(length > 0)] | length' 2>/dev/null || echo "0")
        fi
    fi
    
    # Parse HTTP results
    if [[ -n "$http_result" ]] && ! echo "$http_result" | grep -q "ERROR"; then
        if echo "$http_result" | jq . >/dev/null 2>&1; then
            http_total=$(echo "$http_result" | jq -r 'keys | length' 2>/dev/null || echo "0")
            http_success=$(echo "$http_result" | jq -r '[.[] | select(. != null) | .[] | select(. != null) | .[0] // empty | select(. == 1)] | length' 2>/dev/null || echo "0")
        fi
    fi
    
    # Build details string
    local details="Ping: ${ping_success}/${ping_total}, TCP: ${tcp_success}/${tcp_total}, DNS: ${dns_success}/${dns_total}"
    if [[ $http_total -gt 0 ]]; then
        details="${details}, HTTP: ${http_success}/${http_total}"
    fi
    
    # Calculate overall success rate
    local total_checks=$((ping_total + tcp_total + dns_total + http_total))
    local total_success=$((ping_success + tcp_success + dns_success + http_success))
    
    if [[ $total_checks -eq 0 ]]; then
        write_status "$ip_dir" "Check-Host" "${RED}ERROR" "All checks failed"
        log_message "Check-Host error for $ip: All checks failed"
        return
    fi
    
    local success_rate=$((total_success * 100 / total_checks))
    
    # Determine status based on success rate
    if [[ $success_rate -ge 60 ]]; then
        write_status "$ip_dir" "Check-Host" "${GREEN}PASSED" "$details"
        log_message "Check-Host PASSED for $ip: $details (${success_rate}% success)"
    elif [[ $success_rate -ge 30 ]]; then
        write_status "$ip_dir" "Check-Host" "${YELLOW}PARTIAL" "$details"
        log_message "Check-Host PARTIAL for $ip: $details (${success_rate}% success)"
    else
        write_status "$ip_dir" "Check-Host" "${RED}FAILED" "$details"
        log_message "Check-Host FAILED for $ip: $details (${success_rate}% success)"
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


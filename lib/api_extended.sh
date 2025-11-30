# --- New API Check Functions ---

check_ipapi() {
    local ip="$1" ip_dir="$2"
    log_message "Checking ipapi.co for $ip"
    local resp
    resp=$(curl --max-time 15 -sf "https://ipapi.co/$ip/json/" || true)
    if [[ -z "$resp" ]]; then
        write_status "$ip_dir" "ipapi" "${RED}ERROR" "Request failed"
        log_message "ipapi error for $ip: Request failed"
        return
    fi
    # Save raw API response
    echo "$resp" | jq . > "$ip_dir/raw_ipapi.json" 2>/dev/null || echo "$resp" > "$ip_dir/raw_ipapi.json"
    log_message "ipapi response for $ip: $resp"
    local org asn
    # Validate JSON before parsing
    if echo "$resp" | jq . >/dev/null 2>&1; then
        org=$(jq -r '.org // "unknown"' <<<"$resp" 2>/dev/null || echo "unknown")
        asn=$(jq -r '.asn // "unknown"' <<<"$resp" 2>/dev/null || echo "unknown")
    else
        org="unknown"
        asn="unknown"
    fi
    local details="ASN: $asn, Org: $org"
    # Store for scoring
    SCORE_METRICS["${ip}_asn"]="$asn"
    SCORE_METRICS["${ip}_org"]="$org"
    # Validate JSON before parsing
    if echo "$resp" | jq . >/dev/null 2>&1; then
        local org_check
        org_check=$(jq -r '.org // ""' <<<"$resp" 2>/dev/null || echo "")
        SCORE_METRICS["${ip}_is_datacenter"]=$(echo "$org_check" | grep -qiE "(datacenter|hosting|cloud|server)" && echo "true" || echo "false")
    else
        SCORE_METRICS["${ip}_is_datacenter"]="false"
    fi
    write_status "$ip_dir" "ipapi" "${GREEN}PASSED" "$details"
    log_message "ipapi PASSED for $ip: $details"
}

check_ipregistry() {
    local ip="$1" ip_dir="$2"
    log_message "Checking ipregistry.io for $ip"
    local api_key="${IPREGISTRY_KEY:-}"
    local url
    if [[ -n "$api_key" ]]; then
        url="https://api.ipregistry.co/$ip?key=$api_key"
    else
        url="https://api.ipregistry.co/$ip"
    fi
    local resp
    resp=$(curl --max-time 15 -sf "$url" || true)
    if [[ -z "$resp" ]]; then
        write_status "$ip_dir" "ipregistry" "${RED}ERROR" "Request failed"
        log_message "ipregistry error for $ip: Request failed"
        return
    fi
    # Save raw API response
    echo "$resp" | jq . > "$ip_dir/raw_ipregistry.json" 2>/dev/null || echo "$resp" > "$ip_dir/raw_ipregistry.json"
    log_message "ipregistry response for $ip: $resp"
    local company
    # Validate JSON before parsing
    if echo "$resp" | jq . >/dev/null 2>&1; then
        company=$(jq -r '.company.name // "unknown"' <<<"$resp" 2>/dev/null || echo "unknown")
    else
        company="unknown"
    fi
    local details="Company: $company"
    SCORE_METRICS["${ip}_company"]="$company"
    write_status "$ip_dir" "ipregistry" "${GREEN}PASSED" "$details"
    log_message "ipregistry PASSED for $ip: $details"
}

check_spamhaus() {
    local ip="$1" ip_dir="$2"
    log_message "Checking Spamhaus for $ip" "INFO"
    # Spamhaus DNSBL check (no API key needed for basic check)
    local reversed_ip
    reversed_ip=$(echo "$ip" | awk -F. '{print $4"."$3"."$2"."$1}')
    local result
    result=$(dig +short "${reversed_ip}.zen.spamhaus.org" 2>/dev/null || echo "")
    local details="Not listed"
    local abuse_count=0
    if [[ -n "$result" ]]; then
        # Parse Spamhaus response codes
        local code
        code=$(echo "$result" | awk '{print $1}')
        case "$code" in
            127.0.0.2) details="SBL - Spamhaus SBL Listed" ; abuse_count=50 ;;
            127.0.0.3) details="SBL - Spamhaus CSS Listed" ; abuse_count=40 ;;
            127.0.0.4) details="XBL - CBL Listed" ; abuse_count=45 ;;
            127.0.0.5) details="XBL - Spamhaus DROP/EDROP Listed" ; abuse_count=60 ;;
            127.0.0.6) details="XBL - Spamhaus DROP Listed" ; abuse_count=55 ;;
            127.0.0.7) details="XBL - Spamhaus EDROP Listed" ; abuse_count=50 ;;
            *) details="Listed in Spamhaus: $result" ; abuse_count=30 ;;
        esac
        write_status "$ip_dir" "Spamhaus" "${RED}FAILED" "$details"
        log_message "Spamhaus FAILED for $ip: $details" "WARN"
        SCORE_METRICS["${ip}_spamhaus_listed"]="true"
        SCORE_METRICS["${ip}_abuse_90d"]="$abuse_count"
    else
        write_status "$ip_dir" "Spamhaus" "${GREEN}PASSED" "$details"
        log_message "Spamhaus PASSED for $ip: $details" "INFO"
        SCORE_METRICS["${ip}_spamhaus_listed"]="false"
    fi
}

# Generate comprehensive abuse report
generate_abuse_report() {
    local ip="$1" ip_dir="$2"
    local abuse_json
    abuse_json=$(jq -n \
        --arg ip "$ip" \
        --arg spamhaus "${SCORE_METRICS["${ip}_spamhaus_listed"]:-false}" \
        --arg abuse_count "${SCORE_METRICS["${ip}_abuse_90d"]:-0}" \
        '{
            ip: $ip,
            spamhaus_listed: ($spamhaus == "true"),
            abuse_count_90d: ($abuse_count | tonumber),
            confidence_score: (if ($spamhaus == "true") then 75 else 0 end)
        }')
    echo "$abuse_json" > "$ip_dir/abuse_report.json"
    log_message "Generated abuse report for $ip" "INFO"
}


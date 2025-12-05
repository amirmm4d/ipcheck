# --- Scoring Engine ---

calculate_clean_score() {
    local ip="$1"
    local total_score=100.0
    local weights=(
        "fraud_score:0.30"
        "proxy_score:0.20"
        "vpn_score:0.15"
        "abuse_reports:0.20"
        "bot_activity:0.10"
        "datacenter:0.05"
    )
    
    # Extract metrics from check results
    local fraud_score=0
    local proxy_score=0
    local vpn_score=0
    local abuse_reports=0
    local bot_activity=0
    local is_datacenter=0
    
    # Get AbuseIPDB data
    if [[ -f "$ip_dir/AbuseIPDB" ]]; then
        local abuse_result
        abuse_result=$(<"$ip_dir/AbuseIPDB")
        local abuse_status
        abuse_status=$(echo "$abuse_result" | cut -d'|' -f2)
        if [[ "$abuse_status" =~ FAILED ]]; then
            abuse_reports=50
        fi
    fi
    
    # Check Spamhaus
    if [[ "${SCORE_METRICS["${ip}_spamhaus_listed"]:-}" == "true" ]]; then
        abuse_reports=$((abuse_reports + 30))
    fi
    
    # Check datacenter
    if [[ "${SCORE_METRICS["${ip}_is_datacenter"]:-}" == "true" ]]; then
        is_datacenter=20
    fi
    
    # Calculate weighted score
    local penalty=0
    penalty=$(echo "scale=2; $fraud_score * 0.30 + $proxy_score * 0.20 + $vpn_score * 0.15 + $abuse_reports * 0.20 + $bot_activity * 0.10 + $is_datacenter * 0.05" | bc 2>/dev/null || echo "0")
    total_score=$(echo "scale=2; 100 - $penalty" | bc 2>/dev/null || echo "100")
    
    # Ensure score is between 0 and 100
    if (( $(echo "$total_score < 0" | bc -l 2>/dev/null || echo "0") )); then
        total_score=0
    elif (( $(echo "$total_score > 100" | bc -l 2>/dev/null || echo "0") )); then
        total_score=100
    fi
    
    SCORE_METRICS["${ip}_clean_score"]="$total_score"
    echo "$total_score"
}

generate_score_report() {
    local ip="$1"
    local score
    score=$(calculate_clean_score "$ip")
    
    local score_json
    # Format score as number string for jq
    local score_str
    score_str=$(echo "$score" | awk '{printf "%.2f", $1}')
    score_json=$(jq -n \
        --arg ip "$ip" \
        --arg score "$score_str" \
        --arg fraud "${SCORE_METRICS["${ip}_fraud"]:-unknown}" \
        --arg proxy "${SCORE_METRICS["${ip}_proxy"]:-unknown}" \
        --arg vpn "${SCORE_METRICS["${ip}_vpn"]:-unknown}" \
        --arg abuse "${SCORE_METRICS["${ip}_abuse"]:-unknown}" \
        --arg bot "${SCORE_METRICS["${ip}_bot"]:-unknown}" \
        --arg datacenter "${SCORE_METRICS["${ip}_is_datacenter"]:-false}" \
        --arg asn "${SCORE_METRICS["${ip}_asn"]:-unknown}" \
        '{
            ip: $ip,
            clean_score: ($score | tonumber),
            metrics: {
                fraud_score: $fraud,
                proxy_score: $proxy,
                vpn_score: $vpn,
                recent_abuse_reports: $abuse,
                bot_activity: $bot,
                is_datacenter: ($datacenter == "true"),
                asn: $asn
            }
        }')
    
    echo "$score_json" > "$STATUS_DIR/$(echo "$ip" | tr '.' '_')/ip_score.json"
    log_message "Generated score report for $ip: Clean Score = $score" "INFO"
}


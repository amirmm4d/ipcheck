# --- Suggestion Engine Functions ---

generate_suggestions() {
    local ip="$1" ip_dir="$2"
    log_message "Generating suggestions for $ip" "INFO"
    
    local suggestions=()
    local suggestion_categories=()
    
    # Load all results
    local clean_score=100
    local cdn_detected=false
    local routing_quality="good"
    local port_risk="low"
    local abuse_risk="low"
    local reality_suitable=false
    
    # Get Clean Score
    if [[ -f "$ip_dir/ip_score.json" ]]; then
        clean_score=$(jq -r '.clean_score // 100' "$ip_dir/ip_score.json" 2>/dev/null || echo "100")
    fi
    
    # Get CDN status
    if [[ -f "$ip_dir/cdn_status.json" ]]; then
        cdn_detected=$(jq -r '.cdn_detected // false' "$ip_dir/cdn_status.json" 2>/dev/null || echo "false")
    fi
    
    # Get routing quality
    if [[ -f "$ip_dir/route_report.json" ]]; then
        local packet_loss
        packet_loss=$(jq -r '.packet_loss_percent // 0' "$ip_dir/route_report.json" 2>/dev/null || echo "0")
        if (( $(echo "$packet_loss > 5" | bc -l 2>/dev/null || echo "0") )); then
            routing_quality="poor"
        fi
    fi
    
    # Get port risk
    if [[ -f "$ip_dir/port_scan.json" ]]; then
        port_risk=$(jq -r '.risk_level // "low"' "$ip_dir/port_scan.json" 2>/dev/null || echo "low")
    fi
    
    # Get abuse risk
    if [[ -f "$ip_dir/abuse_report.json" ]]; then
        local spamhaus_listed
        spamhaus_listed=$(jq -r '.spamhaus_listed // false' "$ip_dir/abuse_report.json" 2>/dev/null || echo "false")
        if [[ "$spamhaus_listed" == "true" ]]; then
            abuse_risk="high"
        fi
    fi
    
    # Get Reality suitability
    if [[ -f "$ip_dir/reality_test.json" ]]; then
        reality_suitable=$(jq -r '.suitable_for_reality // false' "$ip_dir/reality_test.json" 2>/dev/null || echo "false")
    fi
    
    # Generate suggestions based on results
    if (( $(echo "$clean_score < 50" | bc -l 2>/dev/null || echo "0") )); then
        suggestions+=("IP has low Clean Score ($clean_score). Consider using a different IP address.")
        suggestion_categories+=("security")
    fi
    
    if [[ "$cdn_detected" == "true" ]]; then
        suggestions+=("CDN detected. This IP may be behind a proxy/CDN, which can affect direct connectivity.")
        suggestion_categories+=("network")
    fi
    
    if [[ "$routing_quality" == "poor" ]]; then
        suggestions+=("Routing quality is poor. Check network configuration and consider alternative routes.")
        suggestion_categories+=("performance")
    fi
    
    if [[ "$port_risk" == "high" ]]; then
        suggestions+=("High port risk detected. Review open ports and firewall configuration.")
        suggestion_categories+=("security")
    fi
    
    if [[ "$abuse_risk" == "high" ]]; then
        suggestions+=("IP is listed in abuse databases. Request removal or use a different IP.")
        suggestion_categories+=("security")
    fi
    
    if [[ "$reality_suitable" == "true" ]]; then
        suggestions+=("IP is suitable for Sing-box Reality configuration.")
        suggestion_categories+=("configuration")
    else
        suggestions+=("IP may have issues with Sing-box Reality. Test TLS and MTU settings.")
        suggestion_categories+=("configuration")
    fi
    
    # Generate suggestions JSON
    local suggestions_array="["
    local first=true
    for i in "${!suggestions[@]}"; do
        if ! $first; then suggestions_array+=","; fi
        first=false
        suggestions_array+=$(jq -n \
            --arg text "${suggestions[$i]}" \
            --arg category "${suggestion_categories[$i]}" \
            '{text: $text, category: $category, priority: "medium"}')
    done
    suggestions_array+="]"
    
    local suggestions_json
    suggestions_json=$(jq -n \
        --arg ip "$ip" \
        --argjson suggestions "$suggestions_array" \
        '{
            ip: $ip,
            suggestions: ($suggestions | fromjson),
            generated_at: (now | todateiso8601)
        }')
    
    echo "$suggestions_json" > "$ip_dir/suggestions.json"
    log_message "Generated ${#suggestions[@]} suggestions for $ip" "INFO"
}


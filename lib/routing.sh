# --- Routing Health Functions ---

test_routing() {
    local ip="$1" ip_dir="$2"
    log_message "Testing routing health for $ip" "INFO"
    
    if ! command -v traceroute &>/dev/null && ! command -v mtr &>/dev/null; then
        write_status "$ip_dir" "Routing_Health" "${YELLOW}SKIPPED" "traceroute/mtr not available"
        log_message "Routing test skipped: tools not available" "WARN"
        return
    fi
    
    local latency_results=()
    local packet_loss=0
    local hop_count=0
    local route_stable=true
    
    # Use mtr if available, otherwise traceroute
    if command -v mtr &>/dev/null; then
        log_message "Using mtr for routing test" "INFO"
        local mtr_output
        mtr_output=$(timeout 30 mtr -r -c 10 "$ip" 2>/dev/null || echo "")
        if [[ -n "$mtr_output" ]]; then
            packet_loss=$(echo "$mtr_output" | awk '/Loss%/{getline; print $3}' | sed 's/%//' || echo "0")
            hop_count=$(echo "$mtr_output" | grep -c "\. " || echo "0")
            local avg_latency
            avg_latency=$(echo "$mtr_output" | awk '/Avg/{getline; print $4}' || echo "0")
            latency_results+=("$avg_latency")
        fi
    elif command -v traceroute &>/dev/null; then
        log_message "Using traceroute for routing test" "INFO"
        local trace_output
        trace_output=$(timeout 30 traceroute -m 15 -q 1 "$ip" 2>/dev/null || echo "")
        if [[ -n "$trace_output" ]]; then
            hop_count=$(echo "$trace_output" | grep -c "  " || echo "0")
            local times
            times=$(echo "$trace_output" | grep -oE '[0-9]+\.[0-9]+ ms' | sed 's/ ms//' || echo "")
            if [[ -n "$times" ]]; then
                local total=0 count=0
                while IFS= read -r time; do
                    total=$(echo "$total + $time" | bc 2>/dev/null || echo "$total")
                    ((count++))
                done <<< "$times"
                if [[ $count -gt 0 ]]; then
                    local avg
                    avg=$(echo "scale=2; $total / $count" | bc 2>/dev/null || echo "0")
                    latency_results+=("$avg")
                fi
            fi
        fi
    fi
    
    # Simple ping test for latency
    local ping_result
    ping_result=$(ping -c 5 -W 2 "$ip" 2>/dev/null | tail -1 || echo "")
    local avg_ping=0
    if [[ -n "$ping_result" ]]; then
        avg_ping=$(echo "$ping_result" | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "0")
    fi
    
    # Generate routing report
    local route_json
    route_json=$(jq -n \
        --arg ip "$ip" \
        --argjson latency "${latency_results[0]:-$avg_ping}" \
        --argjson packet_loss "$packet_loss" \
        --argjson hops "$hop_count" \
        --arg stable "$route_stable" \
        '{
            ip: $ip,
            avg_latency_ms: ($latency | tonumber),
            packet_loss_percent: ($packet_loss | tonumber),
            hop_distance: ($hops | tonumber),
            route_stable: ($stable == "true")
        }')
    
    echo "$route_json" > "$ip_dir/route_report.json"
    ROUTING_RESULTS["$ip"]="$route_json"
    
    local details="Latency: ${latency_results[0]:-$avg_ping}ms, Hops: $hop_count, Loss: ${packet_loss}%"
    if (( $(echo "${packet_loss:-0} > 5" | bc -l 2>/dev/null || echo "0") )) || (( $(echo "${latency_results[0]:-$avg_ping} > 200" | bc -l 2>/dev/null || echo "0") )); then
        write_status "$ip_dir" "Routing_Health" "${RED}POOR" "$details"
        log_message "Routing health POOR for $ip: $details" "WARN"
    else
        write_status "$ip_dir" "Routing_Health" "${GREEN}GOOD" "$details"
        log_message "Routing health GOOD for $ip: $details" "INFO"
    fi
}


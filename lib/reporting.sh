# --- Reporting Functions ---

generate_table_report() {
    local ip="$1" ip_dir="$2" fail_threshold="$3"
    local failed_checks=0

    # Get Clean Score if available
    local clean_score="N/A"
    if [[ -f "$ip_dir/ip_score.json" ]]; then
        # Validate JSON file before parsing
        if jq . "$ip_dir/ip_score.json" >/dev/null 2>&1; then
            clean_score=$(jq -r '.clean_score // "N/A"' "$ip_dir/ip_score.json" 2>/dev/null || echo "N/A")
            if [[ "$clean_score" != "N/A" ]] && [[ "$clean_score" != "null" ]] && command -v bc &>/dev/null; then
                clean_score=$(printf "%.0f" "$clean_score" 2>/dev/null || echo "$clean_score")
            fi
        fi
    else
        # Calculate score on the fly if not generated
        if command -v bc &>/dev/null; then
            clean_score=$(calculate_clean_score "$ip" 2>/dev/null || echo "N/A")
            if [[ "$clean_score" != "N/A" ]]; then
                clean_score=$(printf "%.0f" "$clean_score" 2>/dev/null || echo "$clean_score")
            fi
        fi
    fi

    printf "\n${BLUE}┌─────────────────── IP Reputation Report for %-35s ┐${NC}\n" "$ip"
    if [[ "$clean_score" != "N/A" ]]; then
        printf "${BLUE}│ ${GREEN}Clean Score: ${YELLOW}%s/100${BLUE}%*s │${NC}\n" "$clean_score" $((58 - ${#clean_score})) ""
    fi
    printf "${BLUE}│ %-18s │ %-15s │ %-42s │${NC}\n" "Service" "Status" "Details"
    printf "${BLUE}├────────────────────┼─────────────────┼────────────────────────────────────────────┤${NC}\n"

    for check_file in "$ip_dir"/*; do
        [[ ! -f "$check_file" ]] && continue
        local check_name=$(basename "$check_file")
        # Skip raw data files and JSON reports
        [[ "$check_name" == raw_* ]] && continue
        [[ "$check_name" == *.json ]] && continue
        
        local result status details status_code
        result=$(<"$check_file")
        status_code=$(echo "$result" | cut -d'|' -f1)
        status=$(echo "$result" | cut -d'|' -f2)
        details=$(echo "$result" | cut -d'|' -f3)

        # Only count FAILED (status_code=1) as failed, not ERROR (status_code=3)
        # ERROR means the check couldn't run (network issue, API down, etc.)
        # FAILED means the check ran but found issues
        if ((status_code == 1)); then
            ((failed_checks++))
        fi

        printf "│ %-18s │ %-15s │ %-42s │\n" "$check_name" "${status}${NC}" "$details"
    done

    printf "${BLUE}└────────────────────┴─────────────────┴────────────────────────────────────────────┘${NC}\n\n"

    if ((failed_checks >= fail_threshold)); then
        echo -e "${RED}❌ Overall Status: FAILED. Found $failed_checks failed checks (threshold is $fail_threshold).${NC}"
        return 1
    else
        echo -e "${GREEN}✅ Overall Status: PASSED. Found $failed_checks failed checks (threshold is $fail_threshold).${NC}"
        return 0
    fi
}

# Generate structured data (JSON) for all IPs
generate_data_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local -a all_ips
    mapfile -t all_ips <<<"$all_ips_str"

    local json_output="["
    local first_ip=true
    local overall_exit_code=0

    for ip in "${all_ips[@]}"; do
        if ! $first_ip; then json_output+=","; fi
        first_ip=false

        local ip_dir="$STATUS_DIR/$(echo "$ip" | tr '.' '_')"
        local ip_json
        ip_json=$(jq -n --arg ip "$ip" '{ip: $ip, checks: {}, raw_data: {}}')
        local failed_checks=0

        # Get Clean Score if available
        local clean_score="unknown"
        if [[ -f "$ip_dir/ip_score.json" ]]; then
            # Validate JSON file before parsing
            if jq . "$ip_dir/ip_score.json" >/dev/null 2>&1; then
                clean_score=$(jq -r '.clean_score // "unknown"' "$ip_dir/ip_score.json" 2>/dev/null || echo "unknown")
                # If score is null, set to unknown
                if [[ "$clean_score" == "null" ]]; then
                    clean_score="unknown"
                fi
            fi
        else
            # Calculate score on the fly if not generated
            if command -v bc &>/dev/null; then
                clean_score=$(calculate_clean_score "$ip" 2>/dev/null || echo "unknown")
            fi
        fi

        # Collect raw API data
        local raw_data_json="{}"
        for raw_file in "$ip_dir"/raw_*.json "$ip_dir"/raw_*.txt; do
            [[ ! -f "$raw_file" ]] && continue
            local raw_name=$(basename "$raw_file" | sed 's/^raw_//; s/\.json$//; s/\.txt$//')
            if [[ "$raw_file" == *.json ]]; then
                local raw_content
                raw_content=$(<"$raw_file")
                # Validate JSON before using --argjson
                if echo "$raw_content" | jq . >/dev/null 2>&1; then
                    raw_data_json=$(echo "$raw_data_json" | jq --arg name "$raw_name" --argjson content "$raw_content" '.[$name] = $content' 2>/dev/null || echo "$raw_data_json")
                else
                    # If not valid JSON, treat as string
                    raw_data_json=$(echo "$raw_data_json" | jq --arg name "$raw_name" --arg content "$raw_content" '.[$name] = $content' 2>/dev/null || echo "$raw_data_json")
                fi
            else
                local raw_content
                raw_content=$(<"$raw_file")
                raw_data_json=$(echo "$raw_data_json" | jq --arg name "$raw_name" --arg content "$raw_content" '.[$name] = $content' 2>/dev/null || echo "$raw_data_json")
            fi
        done

        for check_file in "$ip_dir"/*; do
            [[ ! -f "$check_file" ]] && continue
            local check_name=$(basename "$check_file")
            # Skip raw data files and JSON reports
            [[ "$check_name" == raw_* ]] && continue
            [[ "$check_name" == *.json ]] && [[ "$check_name" != ip_score.json ]] && continue
            
            local result status_text details status_code
            result=$(<"$check_file")
            status_code=$(echo "$result" | cut -d'|' -f1)
            status_text=$(echo "$result" | cut -d'|' -f2 | sed "s/$(printf '\033')\\[[0-9;]*m//g") # Strip colors
            details=$(echo "$result" | cut -d'|' -f3)

            # Validate status_code is numeric before arithmetic operation
            # Only count FAILED (status_code=1) as failed, not ERROR (status_code=3)
            if [[ "$status_code" =~ ^[0-9]+$ ]]; then
                if ((status_code == 1)); then
                    ((failed_checks++))
                fi
            fi

            local check_json
            check_json=$(jq -n --arg status "$status_text" --arg details "$details" '{status: $status, details: $details}')
            ip_json=$(echo "$ip_json" | jq --argjson check "$check_json" --arg name "$check_name" '.checks[$name] = $check')
        done

        local overall_status="PASSED"
        # Validate fail_threshold is numeric before comparison
        if [[ "$fail_threshold" =~ ^[0-9]+$ ]] && [[ "$failed_checks" =~ ^[0-9]+$ ]]; then
            if ((failed_checks >= fail_threshold)); then
                overall_status="FAILED"
                overall_exit_code=1
            fi
        fi

        # Add Clean Score and raw data to JSON
        # Use --arg instead of --argint (not available in older jq versions)
        ip_json=$(echo "$ip_json" | jq \
            --arg status "$overall_status" \
            --arg failed "$failed_checks" \
            --arg thresh "$fail_threshold" \
            --arg score "$clean_score" \
            --argjson raw_data "$raw_data_json" \
            '.overall_status = $status | 
             .failed_checks = ($failed | tonumber) | 
             .failure_threshold = ($thresh | tonumber) |
             .clean_score = (if $score == "unknown" or $score == "N/A" then null else ($score | tonumber) end) |
             .raw_data = $raw_data')

        json_output+="$ip_json"
    done

    json_output+="]"
    echo "$json_output" | jq . # Pretty-print JSON
    return $overall_exit_code
}

# Convert JSON to YAML
json_to_yaml() {
    local json_data="$1"
    # Use yq if available, otherwise use a simple converter
    if command -v yq &>/dev/null; then
        echo "$json_data" | yq -P .
    elif command -v python3 &>/dev/null; then
        echo "$json_data" | python3 -c "
import json, sys, yaml
try:
    data = json.load(sys.stdin)
    print(yaml.dump(data, default_flow_style=False, allow_unicode=True))
except ImportError:
    print('# YAML output requires PyYAML. Install: pip install pyyaml', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null || echo "$json_data" | jq -r 'to_entries | .[] | "\(.key): \(.value)"' | sed 's/^/  /'
    else
        # Fallback: simple YAML-like output
        echo "$json_data" | jq -r '
            def to_yaml:
                if type == "object" then
                    to_entries | .[] | "\(.key):\n\(.value | to_yaml | split("\n") | .[] | "  " + .)"
                elif type == "array" then
                    .[] | "- \(to_yaml)"
                else
                    "\(.)"
                end;
            to_yaml
        ' 2>/dev/null || echo "$json_data"
    fi
}

# Convert JSON to CSV
json_to_csv() {
    local json_data="$1"
    echo "$json_data" | jq -r '
        ["IP", "Clean Score", "Overall Status", "Failed Checks", "Failure Threshold"],
        (.[] | [.ip, (.clean_score // "N/A"), .overall_status, .failed_checks, .failure_threshold])
        | @csv
    ' 2>/dev/null || echo "IP,Clean Score,Overall Status,Failed Checks,Failure Threshold"
}

# Convert JSON to XML
json_to_xml() {
    local json_data="$1"
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<ipcheck_results>'
    echo "$json_data" | jq -r '
        .[] | "
  <ip_result>
    <ip>\(.ip)</ip>
    <clean_score>\(.clean_score // "N/A")</clean_score>
    <overall_status>\(.overall_status)</overall_status>
    <failed_checks>\(.failed_checks)</failed_checks>
    <failure_threshold>\(.failure_threshold)</failure_threshold>
    <checks>\(.checks | to_entries | .[] | "
      <check>
        <name>\(.key)</name>
        <status>\(.value.status)</status>
        <details>\(.value.details)</details>
      </check>")</checks>
  </ip_result>"
    ' 2>/dev/null
    echo '</ipcheck_results>'
}

# Generate report in specified format
generate_json_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    echo "$json_data"
    return $exit_code
}

generate_yaml_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    json_to_yaml "$json_data"
    return $exit_code
}

generate_csv_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    json_to_csv "$json_data"
    return $exit_code
}

generate_xml_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    json_to_xml "$json_data"
    return $exit_code
}

generate_yaml_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    json_to_yaml "$json_data"
    return $exit_code
}

generate_csv_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    json_to_csv "$json_data"
    return $exit_code
}

generate_xml_report() {
    local all_ips_str="$1" fail_threshold="$2"
    local json_data
    json_data=$(generate_data_report "$all_ips_str" "$fail_threshold")
    local exit_code=$?
    json_to_xml "$json_data"
    return $exit_code
}


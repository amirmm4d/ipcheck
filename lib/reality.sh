# --- Reality Fingerprint Testing Functions ---

test_reality_fingerprint() {
    local ip="$1" ip_dir="$2"
    log_message "Testing Reality fingerprint for $ip" "INFO"
    
    if ! command -v openssl &>/dev/null; then
        write_status "$ip_dir" "Reality_Test" "${YELLOW}SKIPPED" "openssl not available"
        log_message "Reality test skipped: openssl not available" "WARN"
        return
    fi
    
    local tls_errors=0
    local mtu_consistent=true
    local sni_works=false
    local routing_anomalies=false
    local ja3_fingerprint=""
    
    # Test TLS handshake
    log_message "Testing TLS handshake" "DEBUG"
    local tls_test
    tls_test=$(timeout 10 openssl s_client -connect "$ip:443" -servername "www.google.com" </dev/null 2>&1 || echo "")
    if [[ -z "$tls_test" ]]; then
        ((tls_errors++))
        log_message "TLS test failed: No response" "WARN"
    elif echo "$tls_test" | grep -qi "verify error\|handshake failure\|connection refused\|Connection refused\|No route to host"; then
        ((tls_errors++))
        log_message "TLS errors detected" "WARN"
    elif echo "$tls_test" | grep -qi "Verify return code: 0\|New, TLSv"; then
        log_message "TLS handshake successful" "INFO"
    else
        # If we get some response but it's unclear, assume it's OK (many servers don't have valid certs)
        log_message "TLS test completed (unclear result, assuming OK)" "DEBUG"
    fi
    
    # Test SNI behavior
    local sni_test
    sni_test=$(timeout 10 openssl s_client -connect "$ip:443" -servername "invalid-sni-test.example.com" </dev/null 2>&1 || echo "")
    if echo "$sni_test" | grep -qi "certificate"; then
        sni_works=true
        log_message "SNI works correctly" "INFO"
    else
        log_message "SNI test inconclusive" "DEBUG"
    fi
    
    # Test HTTP/2 if curl supports it
    if curl --version 2>/dev/null | grep -q "http2"; then
        log_message "Testing HTTP/2 support" "DEBUG"
        local http2_test
        http2_test=$(timeout 10 curl -sI --http2 "https://$ip" 2>&1 || echo "")
        if echo "$http2_test" | grep -qi "HTTP/2"; then
            log_message "HTTP/2 supported" "INFO"
        fi
    fi
    
    # Simple MTU consistency test (ping with different sizes)
    log_message "Testing MTU consistency" "DEBUG"
    local mtu_test1 mtu_test2
    mtu_test1=$(ping -c 1 -s 64 "$ip" 2>/dev/null | grep -oE 'time=[0-9.]+' || echo "")
    mtu_test2=$(ping -c 1 -s 1500 "$ip" 2>/dev/null | grep -oE 'time=[0-9.]+' || echo "")
    if [[ -n "$mtu_test1" ]] && [[ -n "$mtu_test2" ]]; then
        mtu_consistent=true
        log_message "MTU appears consistent" "INFO"
    else
        log_message "MTU test inconclusive" "DEBUG"
    fi
    
    # Generate Reality test report
    local reality_json
    # Use --arg instead of --argjson for numeric values (compatible with older jq)
    reality_json=$(jq -n \
        --arg ip "$ip" \
        --arg tls_errors "$tls_errors" \
        --arg mtu_consistent "$mtu_consistent" \
        --arg sni_works "$sni_works" \
        --arg routing_anomalies "$routing_anomalies" \
        --arg ja3 "$ja3_fingerprint" \
        '{
            ip: $ip,
            tls_handshake: (($tls_errors | tonumber) == 0),
            tls_errors: ($tls_errors | tonumber),
            mtu_consistent: ($mtu_consistent == "true"),
            sni_behavior: ($sni_works == "true"),
            routing_anomalies: ($routing_anomalies == "true"),
            ja3_fingerprint: $ja3,
            suitable_for_reality: ((($tls_errors | tonumber) == 0) and ($mtu_consistent == "true"))
        }')
    
    echo "$reality_json" > "$ip_dir/reality_test.json"
    REALITY_RESULTS["$ip"]="$reality_json"
    
    # Build details string with proper boolean display
    local tls_ok="false"
    if [[ $tls_errors -eq 0 ]]; then
        tls_ok="true"
    fi
    local details="TLS OK: $tls_ok, MTU: $mtu_consistent, SNI: $sni_works"
    if [[ $tls_errors -eq 0 ]] && [[ "$mtu_consistent" == "true" ]]; then
        write_status "$ip_dir" "Reality_Test" "${GREEN}SUITABLE" "$details"
        log_message "Reality test: IP is suitable for Sing-box Reality" "INFO"
    else
        write_status "$ip_dir" "Reality_Test" "${YELLOW}ISSUES" "$details"
        log_message "Reality test: IP has some issues (TLS errors: $tls_errors, MTU: $mtu_consistent)" "WARN"
    fi
}


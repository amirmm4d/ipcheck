# --- CDN Detection Functions ---

detect_cdn() {
    local ip="$1" ip_dir="$2"
    log_message "Detecting CDN for $ip" "INFO"
    
    local cdn_detected="none"
    local cdn_provider=""
    local asn_info=""
    local reverse_dns=""
    
    # Get ASN info from ipapi if available
    if [[ -n "${SCORE_METRICS["${ip}_asn"]:-}" ]]; then
        asn_info="${SCORE_METRICS["${ip}_asn"]}"
    else
        # Quick ASN lookup
        local asn_resp
        asn_resp=$(curl --max-time 10 -sf "https://ipapi.co/$ip/json/" 2>/dev/null || true)
        if [[ -n "$asn_resp" ]]; then
            asn_info=$(jq -r '.asn // "unknown"' <<<"$asn_resp")
        fi
    fi
    
    # Reverse DNS lookup
    reverse_dns=$(dig +short -x "$ip" 2>/dev/null | head -1 || echo "")
    
    # Check for Cloudflare
    if [[ "$reverse_dns" =~ cloudflare ]] || [[ "$asn_info" == "13335" ]] || [[ "$asn_info" == "209242" ]]; then
        cdn_detected="cloudflare"
        cdn_provider="Cloudflare"
    # Check for Cloudflare Warp
    elif [[ "$reverse_dns" =~ warp ]] || [[ "$asn_info" == "13335" ]]; then
        cdn_detected="cloudflare_warp"
        cdn_provider="Cloudflare Warp"
    # Check for AWS CloudFront
    elif [[ "$reverse_dns" =~ cloudfront ]] || [[ "$asn_info" =~ ^(16509|14618|20547)$ ]]; then
        cdn_detected="aws_cloudfront"
        cdn_provider="AWS CloudFront"
    # Check for Google Cloud CDN
    elif [[ "$asn_info" =~ ^(15169|36040)$ ]]; then
        cdn_detected="gcp_cdn"
        cdn_provider="Google Cloud CDN"
    # Check for Azure CDN
    elif [[ "$asn_info" == "8075" ]] || [[ "$reverse_dns" =~ azure ]]; then
        cdn_detected="azure_cdn"
        cdn_provider="Azure CDN"
    # Check for Fastly
    elif [[ "$asn_info" == "54113" ]] || [[ "$reverse_dns" =~ fastly ]]; then
        cdn_detected="fastly"
        cdn_provider="Fastly"
    fi
    
    # Generate CDN status JSON
    local cdn_json
    cdn_json=$(jq -n \
        --arg ip "$ip" \
        --arg detected "$cdn_detected" \
        --arg provider "$cdn_provider" \
        --arg asn "$asn_info" \
        --arg rdns "$reverse_dns" \
        '{
            ip: $ip,
            cdn_detected: ($detected != "none"),
            cdn_type: $detected,
            provider: $provider,
            asn: $asn,
            reverse_dns: $rdns
        }')
    
    echo "$cdn_json" > "$ip_dir/cdn_status.json"
    CDN_RESULTS["$ip"]="$cdn_json"
    
    local details="Provider: $cdn_provider, ASN: $asn_info"
    if [[ "$cdn_detected" != "none" ]]; then
        write_status "$ip_dir" "CDN_Detection" "${YELLOW}DETECTED" "$details"
        log_message "CDN detected for $ip: $cdn_provider" "INFO"
    else
        write_status "$ip_dir" "CDN_Detection" "${GREEN}NONE" "$details"
        log_message "No CDN detected for $ip" "INFO"
    fi
}


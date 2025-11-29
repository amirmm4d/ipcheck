# --- Logging Functions ---

log_message() {
    local level="${2:-INFO}"
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ -z "$LOG_DIR" ]]; then
        return
    fi
    
    # Ensure log directory exists
    mkdir -p "$LOG_DIR"
    
    # Rotate logs if needed (keep last 30 days, max 100MB per file)
    rotate_logs
    
    local log_file="$LOG_DIR/ipcheck-$(date +%Y%m%d).log"
    
    if [[ "$LOG_FORMAT" == "json" ]]; then
        local log_entry
        log_entry=$(jq -n \
            --arg timestamp "$timestamp" \
            --arg level "$level" \
            --arg message "$message" \
            '{timestamp: $timestamp, level: $level, message: $message}')
        echo "$log_entry" >>"$log_file"
    else
        echo "[$timestamp] [$level] $message" >>"$log_file"
    fi
}

rotate_logs() {
    if [[ ! -d "$LOG_DIR" ]]; then
        return
    fi
    
    # Remove logs older than 30 days
    find "$LOG_DIR" -name "ipcheck-*.log" -type f -mtime +30 -delete 2>/dev/null || true
    
    # Check file size and rotate if > 100MB
    local log_file="$LOG_DIR/ipcheck-$(date +%Y%m%d).log"
    if [[ -f "$log_file" ]]; then
        local size
        size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo "0")
        if [[ $size -gt 104857600 ]]; then  # 100MB
            mv "$log_file" "${log_file}.$(date +%H%M%S)"
        fi
    fi
}


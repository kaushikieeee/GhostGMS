#!/system/bin/sh

# Security configuration
TOKEN_FILE="/data/ghost/.security_token"
NETWORK_CONFIG="/data/ghost/.network_config"
SECURITY_LOG="/data/ghost/.security_log"
MAX_FAILED_ATTEMPTS=5
LOCKOUT_TIME=300  # 5 minutes
PORT=8080
CERT_DIR="/data/ghost/certs"
CERT_FILE="$CERT_DIR/server.crt"
KEY_FILE="$CERT_DIR/server.key"
IPTABLES_RULES="/data/ghost/iptables.rules"

# Secure logging
log_security_event() {
    local event="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $event" >> "$SECURITY_LOG"
    chmod 600 "$SECURITY_LOG"
}

# Generate self-signed certificate
generate_certificate() {
    mkdir -p "$CERT_DIR"
    chmod 700 "$CERT_DIR"
    
    # Check if openssl is available
    if ! command -v openssl >/dev/null 2>&1; then
        log_security_event "Failed to generate certificate: openssl not available"
        return 1
    fi
    
    # Generate certificate
    if ! openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" -out "$CERT_FILE" \
        -subj "/CN=localhost" 2>/dev/null; then
        log_security_event "Failed to generate certificate: openssl command failed"
        return 1
    fi
    
    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"
    log_security_event "Generated new SSL certificate"
    return 0
}

# Network security functions
setup_network_security() {
    # Create network config if it doesn't exist
    if [ ! -f "$NETWORK_CONFIG" ]; then
        echo "ALLOWED_IPS=127.0.0.1" > "$NETWORK_CONFIG"
        chmod 600 "$NETWORK_CONFIG"
        log_security_event "Initial network security setup"
    fi

    # Generate certificate if needed
    if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        if ! generate_certificate; then
            log_security_event "Failed to setup network security: certificate generation failed"
            return 1
        fi
    fi

    # Set up iptables rules
    if ! iptables -F INPUT 2>/dev/null; then
        log_security_event "Failed to flush iptables rules"
        return 1
    fi
    
    if ! iptables -A INPUT -p tcp --dport $PORT -j DROP 2>/dev/null; then
        log_security_event "Failed to add default drop rule"
        return 1
    fi
    
    if ! iptables -A INPUT -p tcp --dport $PORT -s 127.0.0.1 -j ACCEPT 2>/dev/null; then
        log_security_event "Failed to add localhost accept rule"
        return 1
    fi
    
    # Allow whitelisted IPs
    source "$NETWORK_CONFIG"
    for ip in $ALLOWED_IPS; do
        if validate_ip "$ip"; then
            if ! iptables -A INPUT -p tcp --dport $PORT -s "$ip" -j ACCEPT 2>/dev/null; then
                log_security_event "Failed to add accept rule for IP: $ip"
                return 1
            fi
        fi
    done
    
    # Save iptables rules
    if ! iptables-save > "$IPTABLES_RULES" 2>/dev/null; then
        log_security_event "Failed to save iptables rules"
        return 1
    fi
    chmod 600 "$IPTABLES_RULES"
    
    log_security_event "Network security rules applied"
    return 0
}

# Restore iptables rules on boot
restore_iptables() {
    if [ -f "$IPTABLES_RULES" ]; then
        if ! iptables-restore < "$IPTABLES_RULES" 2>/dev/null; then
            log_security_event "Failed to restore iptables rules"
            return 1
        fi
    fi
    return 0
}

# Validate IP address format
validate_ip() {
    local ip="$1"
    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # Validate each octet
        local IFS='.'
        local -a octets=($ip)
        for octet in "${octets[@]}"; do
            if [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Secure token generation using multiple sources
generate_security_token() {
    # Use multiple sources for better entropy
    local token=$(cat /dev/urandom /proc/sys/kernel/random/uuid /proc/sys/kernel/random/entropy_avail 2>/dev/null | \
                 tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
    echo "$token" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    log_security_event "New security token generated"
    echo "$token"
}

# Check for brute force attempts
check_brute_force() {
    local ip="$1"
    local current_time=$(date +%s)
    local lockout_file="/data/ghost/.lockout_$ip"
    
    if [ -f "$lockout_file" ]; then
        local lockout_time=$(cat "$lockout_file")
        if [ $((current_time - lockout_time)) -lt $LOCKOUT_TIME ]; then
            log_security_event "Blocked brute force attempt from $ip"
            return 1
        fi
        rm "$lockout_file"
    fi
    return 0
}

# Record failed attempt
record_failed_attempt() {
    local ip="$1"
    local attempt_file="/data/ghost/.attempts_$ip"
    local current_time=$(date +%s)
    
    # Clean up old attempts
    if [ -f "$attempt_file" ]; then
        while read -r timestamp; do
            if [ $((current_time - timestamp)) -gt $LOCKOUT_TIME ]; then
                sed -i "/$timestamp/d" "$attempt_file"
            fi
        done < "$attempt_file"
    fi
    
    # Record new attempt
    echo "$current_time" >> "$attempt_file"
    
    # Check if we should lock out
    local attempts=$(wc -l < "$attempt_file")
    if [ "$attempts" -ge "$MAX_FAILED_ATTEMPTS" ]; then
        echo "$current_time" > "/data/ghost/.lockout_$ip"
        log_security_event "Locked out $ip due to too many failed attempts"
    fi
}

# Get the current security token
get_security_token() {
    if [ -f "$TOKEN_FILE" ]; then
        cat "$TOKEN_FILE"
    else
        generate_security_token
    fi
}

# Verify a security token with rate limiting
verify_token() {
    local provided_token="$1"
    local client_ip="$2"
    
    if ! check_brute_force "$client_ip"; then
        echo "Too many failed attempts. Please try again later."
        return 1
    fi

    if [ ! -f "$TOKEN_FILE" ]; then
        log_security_event "Token verification failed: Token file not found"
        record_failed_attempt "$client_ip"
        echo "Token file not found"
        return 1
    fi

    local stored_token=$(cat "$TOKEN_FILE")
    if [ "$provided_token" = "$stored_token" ]; then
        log_security_event "Successful token verification from $client_ip"
        return 0
    else
        log_security_event "Failed token verification from $client_ip"
        record_failed_attempt "$client_ip"
        echo "Invalid token"
        return 1
    fi
}

# Network security functions
get_allowed_ips() {
    if [ -f "$NETWORK_CONFIG" ]; then
        source "$NETWORK_CONFIG"
        echo "$ALLOWED_IPS"
    else
        echo "127.0.0.1"
    fi
}

set_allowed_ips() {
    local ips="$1"
    # Validate each IP
    for ip in $ips; do
        if ! validate_ip "$ip"; then
            echo "Invalid IP address: $ip"
            return 1
        fi
    done
    echo "ALLOWED_IPS=$ips" > "$NETWORK_CONFIG"
    chmod 600 "$NETWORK_CONFIG"
    log_security_event "Updated allowed IPs: $ips"
}

# Command whitelist with strict validation
is_command_allowed() {
    local command="$1"
    local params="$2"
    
    # Define allowed commands and their parameter patterns
    declare -A allowed_patterns=(
        ["get_security_token"]="^$"
        ["verify_token"]="^[a-zA-Z0-9]{64}$"
        ["get_module_version"]="^$"
        ["get_kill_logd"]="^$"
        ["set_kill_logd"]="^[01]$"
        ["get_misc_opt"]="^$"
        ["set_misc_opt"]="^[01]$"
        ["get_allowed_ips"]="^$"
        ["set_allowed_ips"]="^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}( [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})*)?$"
    )
    
    # Check if command is allowed
    if [ -z "${allowed_patterns[$command]}" ]; then
        log_security_event "Blocked unauthorized command: $command"
        return 1
    fi
    
    # Validate parameters if required
    if [ -n "$params" ] && ! [[ "$params" =~ ${allowed_patterns[$command]} ]]; then
        log_security_event "Blocked invalid parameters for $command: $params"
        return 1
    fi
    
    return 0
}

# Secure command execution
execute_secure_command() {
    local command="$1"
    local params="$2"
    local client_ip="$3"
    
    # Check if command is allowed
    if ! is_command_allowed "$command" "$params"; then
        log_security_event "Command execution blocked: $command"
        return 1
    fi
    
    # Check brute force protection
    if ! check_brute_force "$client_ip"; then
        log_security_event "Blocked command execution due to brute force protection: $client_ip"
        return 1
    fi
    
    # Execute command with proper sanitization
    case "$command" in
        "set_kill_logd"|"set_misc_opt")
            # These commands only accept 0 or 1
            if [[ "$params" =~ ^[01]$ ]]; then
                # Use printf to safely handle the parameter
                printf '%s\n' "$params" > "/data/ghost/.${command#set_}"
                chmod 600 "/data/ghost/.${command#set_}"
            else
                log_security_event "Invalid parameter for $command: $params"
                return 1
            fi
            ;;
        "set_allowed_ips")
            # Validate each IP before setting
            for ip in $params; do
                if ! validate_ip "$ip"; then
                    log_security_event "Invalid IP address in set_allowed_ips: $ip"
                    return 1
                fi
            done
            set_allowed_ips "$params"
            ;;
        *)
            # For other commands, use a case statement instead of eval
            case "$command" in
                "get_security_token")
                    get_security_token
                    ;;
                "verify_token")
                    verify_token "$params" "$client_ip"
                    ;;
                "get_module_version")
                    cat "/data/ghost/.module_version" 2>/dev/null || echo "unknown"
                    ;;
                "get_kill_logd")
                    cat "/data/ghost/.kill_logd" 2>/dev/null || echo "0"
                    ;;
                "get_misc_opt")
                    cat "/data/ghost/.misc_opt" 2>/dev/null || echo "0"
                    ;;
                "get_allowed_ips")
                    get_allowed_ips
                    ;;
                *)
                    log_security_event "Unknown command: $command"
                    return 1
                    ;;
            esac
            ;;
    esac
    
    log_security_event "Command executed successfully: $command"
    return 0
}

# Log saving function
save_logs() {
    local dest_dir="/data/media/0/ghostgms/logs"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local log_file="${dest_dir}/ghostgms_${timestamp}.log"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    chmod 777 "$dest_dir"
    
    # Save current logs
    {
        echo "=== GhostGMS Log Dump - $(date) ==="
        echo "System Information:"
        echo "Device: $(getprop ro.product.device)"
        echo "Model: $(getprop ro.product.model)"
        echo "Android Version: $(getprop ro.build.version.release)"
        echo "Build: $(getprop ro.build.id)"
        echo ""
        echo "=== Module Status ==="
        echo "Version: $(cat /data/adb/modules/GhostGMS/module.prop | grep version= | cut -d= -f2)"
        echo ""
        echo "=== GMS Services Status ==="
        pm list packages | grep -E 'com.google.android.gms|com.android.vending' | while read -r pkg; do
            echo "$pkg: $(dumpsys package $pkg | grep -A1 "enabled=")"
        done
        echo ""
        echo "=== System Logs ==="
        logcat -d | grep -E 'GhostGMS|ghost-utils'
    } > "$log_file"
    
    chmod 666 "$log_file"
    echo "$log_file"
}

# Main command handler
case "$1" in
    "get_security_token")
        get_security_token
        ;;
    "verify_token")
        verify_token "$2" "$3"
        ;;
    "get_allowed_ips")
        get_allowed_ips
        ;;
    "set_allowed_ips")
        set_allowed_ips "$2"
        ;;
    "setup_network_security")
        setup_network_security
        ;;
    "restore_iptables")
        restore_iptables
        ;;
    "save_logs")
        save_logs
        ;;
    *)
        if ! is_command_allowed "$1" "$2"; then
            echo "Command not allowed"
            exit 1
        fi
        execute_secure_command "$1" "$2" "$3"
        ;;
esac 
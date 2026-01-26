#!/system/bin/sh
##########################################################################################
# GhostGMS WebUI Server
# Authors: Kaushik, MiguVT
# Version: 3.1
##########################################################################################

MODDIR="/data/adb/modules/GhostGMS"
WEBUI_DIR="$MODDIR/webui"
CONFIG_DIR="$MODDIR/config"
PORT=9999
PID_FILE="$MODDIR/webui.pid"

# Function to parse HTTP request
parse_request() {
    read -r REQUEST_LINE
    echo "$REQUEST_LINE" | awk '{print $1" "$2}' > /tmp/ghostgms_request
}

# Function to send HTTP response
send_response() {
    local STATUS="$1"
    local CONTENT_TYPE="$2"
    local BODY="$3"
    local CONTENT_LENGTH=${#BODY}
    
    echo "HTTP/1.1 $STATUS"
    echo "Content-Type: $CONTENT_TYPE"
    echo "Content-Length: $CONTENT_LENGTH"
    echo "Access-Control-Allow-Origin: *"
    echo "Access-Control-Allow-Methods: GET, POST, OPTIONS"
    echo "Access-Control-Allow-Headers: Content-Type"
    echo "Connection: close"
    echo ""
    echo "$BODY"
}

# Function to handle GET /api/config
handle_get_config() {
    if [ -f "$CONFIG_DIR/user_prefs" ]; then
        # Read config file and convert to JSON
        JSON="{"
        FIRST=1
        while IFS='=' read -r key value; do
            [ -z "$key" ] && continue
            [ "$FIRST" = 0 ] && JSON="${JSON},"
            JSON="${JSON}\"${key}\":\"${value}\""
            FIRST=0
        done < "$CONFIG_DIR/user_prefs"
        JSON="${JSON}}"
        
        send_response "200 OK" "application/json" "$JSON"
    else
        send_response "404 Not Found" "application/json" '{"error":"Config not found"}'
    fi
}

# Function to handle POST /api/config
handle_post_config() {
    # Read POST body
    local BODY=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
    done
    while IFS= read -r -t 1 line; do
        BODY="${BODY}${line}"
    done
    
    # Parse JSON and write to config
    echo "$BODY" | sed 's/[{}"]//g' | tr ',' '\n' | while IFS=':' read -r key value; do
        echo "${key}=${value}"
    done > "$CONFIG_DIR/user_prefs"
    
    chmod 644 "$CONFIG_DIR/user_prefs"
    
    send_response "200 OK" "application/json" '{"success":true,"message":"Config saved"}'
}

# Function to handle POST /api/reboot
handle_reboot() {
    send_response "200 OK" "application/json" '{"success":true,"message":"Rebooting..."}'
    sleep 2
    /system/bin/reboot
}

# Function to serve static files
serve_static() {
    local FILE="$1"
    local FILEPATH="$WEBUI_DIR/$FILE"
    
    if [ -f "$FILEPATH" ]; then
        local CONTENT_TYPE="text/html"
        case "$FILE" in
            *.html) CONTENT_TYPE="text/html" ;;
            *.css) CONTENT_TYPE="text/css" ;;
            *.js) CONTENT_TYPE="application/javascript" ;;
            *.json) CONTENT_TYPE="application/json" ;;
        esac
        
        local BODY=$(cat "$FILEPATH")
        send_response "200 OK" "$CONTENT_TYPE" "$BODY"
    else
        send_response "404 Not Found" "text/html" "<h1>404 Not Found</h1>"
    fi
}

# Main request handler
handle_request() {
    parse_request
    
    if [ -f /tmp/ghostgms_request ]; then
        local REQUEST=$(cat /tmp/ghostgms_request)
        local METHOD=$(echo "$REQUEST" | awk '{print $1}')
        local PATH=$(echo "$REQUEST" | awk '{print $2}')
        
        rm -f /tmp/ghostgms_request
        
        case "$PATH" in
            "/" | "/index.html")
                serve_static "index.html"
                ;;
            "/api/config")
                if [ "$METHOD" = "GET" ]; then
                    handle_get_config
                elif [ "$METHOD" = "POST" ]; then
                    handle_post_config
                fi
                ;;
            "/api/reboot")
                if [ "$METHOD" = "POST" ]; then
                    handle_reboot
                fi
                ;;
            *)
                send_response "404 Not Found" "text/html" "<h1>404 Not Found</h1>"
                ;;
        esac
    fi
}

# Start server using netcat
start_server() {
    echo "Starting GhostGMS WebUI on port $PORT..."
    echo $$ > "$PID_FILE"
    
    while true; do
        nc -l -p $PORT -e /system/bin/sh -c "$(declare -f handle_request); handle_request" 2>/dev/null
        if [ $? -ne 0 ]; then
            # Fallback to busybox nc if available
            busybox nc -l -p $PORT -e /system/bin/sh -c "$(declare -f handle_request); handle_request" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "Failed to start server. Neither nc nor busybox nc available."
                exit 1
            fi
        fi
    done
}

# Stop server
stop_server() {
    if [ -f "$PID_FILE" ]; then
        local PID=$(cat "$PID_FILE")
        kill -9 "$PID" 2>/dev/null
        rm -f "$PID_FILE"
        echo "GhostGMS WebUI stopped"
    fi
}

# Check command
case "$1" in
    start)
        start_server &
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        sleep 1
        start_server &
        ;;
    status)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                echo "GhostGMS WebUI is running (PID: $PID) on port $PORT"
                echo "Access at: http://localhost:$PORT"
            else
                echo "GhostGMS WebUI is not running"
                rm -f "$PID_FILE"
            fi
        else
            echo "GhostGMS WebUI is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

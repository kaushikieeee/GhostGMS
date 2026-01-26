#!/system/bin/sh
##########################################################################################
# GhostGMS WebUI Server (Python-based)
# More reliable alternative using Python's built-in HTTP server
##########################################################################################

MODDIR="/data/adb/modules/GhostGMS"
WEBUI_DIR="$MODDIR/webui"
CONFIG_DIR="$MODDIR/config"
PORT=9999
PID_FILE="$MODDIR/webui.pid"

# Create Python HTTP server with API handlers
cat > "$WEBUI_DIR/server.py" << 'PYEOF'
#!/usr/bin/env python3
import json
import os
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

MODDIR = "/data/adb/modules/GhostGMS"
CONFIG_DIR = f"{MODDIR}/config"
WEBUI_DIR = f"{MODDIR}/webui"

class GhostGMSHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Suppress default logging
        pass
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/config':
            self.handle_get_config()
        elif parsed_path.path == '/' or parsed_path.path == '/index.html':
            self.serve_file('index.html', 'text/html')
        else:
            self.send_error(404)
    
    def do_POST(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/config':
            self.handle_post_config()
        elif parsed_path.path == '/api/reboot':
            self.handle_reboot()
        else:
            self.send_error(404)
    
    def handle_get_config(self):
        config_file = f"{CONFIG_DIR}/user_prefs"
        try:
            config = {}
            if os.path.exists(config_file):
                with open(config_file, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if '=' in line:
                            key, value = line.split('=', 1)
                            config[key] = value
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(config).encode())
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_post_config(self):
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode()
            config = json.loads(body)
            
            config_file = f"{CONFIG_DIR}/user_prefs"
            with open(config_file, 'w') as f:
                for key, value in config.items():
                    f.write(f"{key}={value}\n")
            
            os.chmod(config_file, 0o644)
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({
                'success': True,
                'message': 'Configuration saved successfully'
            }).encode())
        except Exception as e:
            self.send_error(500, str(e))
    
    def handle_reboot(self):
        try:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({
                'success': True,
                'message': 'Rebooting device...'
            }).encode())
            
            # Reboot after sending response
            subprocess.Popen(['/system/bin/sh', '-c', 'sleep 2 && /system/bin/reboot'])
        except Exception as e:
            self.send_error(500, str(e))
    
    def serve_file(self, filename, content_type):
        filepath = f"{WEBUI_DIR}/{filename}"
        try:
            with open(filepath, 'r') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-Type', content_type)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(content.encode())
        except FileNotFoundError:
            self.send_error(404)
        except Exception as e:
            self.send_error(500, str(e))

def run_server(port=9999):
    server_address = ('', port)
    httpd = HTTPServer(server_address, GhostGMSHandler)
    print(f"GhostGMS WebUI running on port {port}")
    print(f"Access at: http://localhost:{port}")
    with open(f"{MODDIR}/webui.pid", 'w') as f:
        f.write(str(os.getpid()))
    httpd.serve_forever()

if __name__ == '__main__':
    run_server(9999)
PYEOF

chmod +x "$WEBUI_DIR/server.py"

# Start/stop/status functions
start_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "Server already running (PID: $PID)"
            return
        fi
    fi
    
    # Try Python3 first, then Python
    if command -v python3 >/dev/null 2>&1; then
        nohup python3 "$WEBUI_DIR/server.py" > "$MODDIR/logs/webui.log" 2>&1 &
        echo "Started GhostGMS WebUI on port $PORT (Python3)"
    elif command -v python >/dev/null 2>&1; then
        nohup python "$WEBUI_DIR/server.py" > "$MODDIR/logs/webui.log" 2>&1 &
        echo "Started GhostGMS WebUI on port $PORT (Python)"
    else
        echo "Error: Python not found. WebUI requires Python to run."
        echo "Install Termux and Python: pkg install python"
        return 1
    fi
    
    echo "Access WebUI at: http://localhost:$PORT"
}

stop_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill -9 "$PID" 2>/dev/null
        rm -f "$PID_FILE"
        echo "GhostGMS WebUI stopped"
    else
        echo "Server not running"
    fi
}

status_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "GhostGMS WebUI is running (PID: $PID)"
            echo "Access at: http://localhost:$PORT"
            return 0
        else
            echo "PID file exists but process not running"
            rm -f "$PID_FILE"
        fi
    fi
    echo "GhostGMS WebUI is not running"
    return 1
}

case "$1" in
    start) start_server ;;
    stop) stop_server ;;
    restart)
        stop_server
        sleep 1
        start_server
        ;;
    status) status_server ;;
    *)
        echo "GhostGMS WebUI Control"
        echo "Usage: $0 {start|stop|restart|status}"
        echo ""
        echo "To access WebUI:"
        echo "1. Install Termux from F-Droid"
        echo "2. Install Python: pkg install python"
        echo "3. Start server: su -c '$0 start'"
        echo "4. Open browser to: http://localhost:$PORT"
        exit 1
        ;;
esac

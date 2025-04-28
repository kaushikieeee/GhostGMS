#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = 3000

class MyRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Default to test.html if requesting root
        if self.path == '/':
            self.path = '/test.html'
        return super().do_GET()

    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

if __name__ == "__main__":
    # Change to the script's directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    with socketserver.TCPServer(("", PORT), MyRequestHandler) as httpd:
        print(f"Server running at http://localhost:{PORT}/")
        print(f"Test page available at http://localhost:{PORT}/test.html")
        httpd.serve_forever() 
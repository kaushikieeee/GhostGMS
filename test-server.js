const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.env.PORT || 3000;

const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.webp': 'image/webp',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
    console.log(`${req.method} ${req.url}`);
    
    // Parse URL to get pathname
    const parsedUrl = url.parse(req.url);
    let pathname = parsedUrl.pathname;
    
    // Normalize pathname and make it absolute
    let filepath = path.join(__dirname, pathname);
    
    // If path is '/', serve test.html
    if (pathname === '/') {
        filepath = path.join(__dirname, 'test.html');
    }
    
    // Get file extension
    const ext = path.extname(filepath);
    
    // Read file
    fs.readFile(filepath, (err, data) => {
        if (err) {
            if (err.code === 'ENOENT') {
                // File not found
                console.error(`File not found: ${filepath}`);
                res.writeHead(404);
                res.end(`File not found: ${pathname}`);
                return;
            }
            
            // Server error
            console.error(`Server error: ${err}`);
            res.writeHead(500);
            res.end(`Server error: ${err.code}`);
            return;
        }
        
        // File exists, set content type and send data
        res.setHeader('Content-Type', MIME_TYPES[ext] || 'text/plain');
        res.writeHead(200);
        res.end(data);
    });
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
    console.log(`Test page available at http://localhost:${PORT}/test.html`);
}); 
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        version = os.getenv("APP_VERSION", "v1.0.0")
        self.wfile.write(f"<h1>Hello from Docker! Version: {version}</h1>".encode())

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()

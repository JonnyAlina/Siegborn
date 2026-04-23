from __future__ import annotations

import http.server
import os
import ssl
import socketserver
import urllib.error
import urllib.request
from functools import partial
from pathlib import Path


PROJECT_ID = 'siegeborn-app-2026'
UPSTREAM_BASE = f'https://{PROJECT_ID}.firebaseapp.com'
BUILD_DIR = Path(__file__).resolve().parents[1] / 'build' / 'web'
PORT = 5500
CERT_DIR = Path(__file__).resolve().parents[1] / 'tool' / 'certs'
CERT_FILE = CERT_DIR / 'localhost-cert.pem'
KEY_FILE = CERT_DIR / 'localhost-key.pem'
PROXIED_PREFIXES = ('/__/auth/', '/__/firebase/init.json')
IGNORED_REQUEST_HEADERS = {
    'accept-encoding',
    'connection',
    'content-length',
    'host',
}
PASSTHROUGH_RESPONSE_HEADERS = {
    'cache-control',
    'content-type',
    'location',
}


class ThreadingHttpServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True


class DevWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, directory: str | None = None, **kwargs):
        super().__init__(*args, directory=directory, **kwargs)

    def do_GET(self) -> None:
        if self.path.startswith(PROXIED_PREFIXES):
            self._proxy_request()
            return
        super().do_GET()

    def do_POST(self) -> None:
        if self.path.startswith(PROXIED_PREFIXES):
            self._proxy_request()
            return
        self.send_error(http.HTTPStatus.NOT_FOUND, 'POST not supported for this path')

    def end_headers(self) -> None:
        if not self.path.startswith(PROXIED_PREFIXES):
            self.send_header('Cache-Control', 'no-store')
        super().end_headers()

    def _proxy_request(self) -> None:
        upstream_url = f'{UPSTREAM_BASE}{self.path}'
        request_headers = {
            key: value
            for key, value in self.headers.items()
            if key.lower() not in IGNORED_REQUEST_HEADERS
        }
        request_headers['Host'] = f'{PROJECT_ID}.firebaseapp.com'

        body = None
        content_length = self.headers.get('Content-Length')
        if content_length:
            body = self.rfile.read(int(content_length))

        request = urllib.request.Request(
            upstream_url,
            data=body,
            headers=request_headers,
            method=self.command,
        )

        try:
            with urllib.request.urlopen(request) as response:
                payload = response.read()
                self.send_response(response.status)
                for key, value in response.headers.items():
                    if key.lower() in PASSTHROUGH_RESPONSE_HEADERS:
                        self.send_header(key, value)
                self.end_headers()
                self.wfile.write(payload)
        except urllib.error.HTTPError as error:
            payload = error.read()
            self.send_response(error.code)
            for key, value in error.headers.items():
                if key.lower() in PASSTHROUGH_RESPONSE_HEADERS:
                    self.send_header(key, value)
            self.end_headers()
            if payload:
                self.wfile.write(payload)


def main() -> None:
    if not CERT_FILE.exists() or not KEY_FILE.exists():
        raise FileNotFoundError(
            'Missing TLS certificate files. Expected '
            f'{CERT_FILE} and {KEY_FILE}.',
        )

    os.chdir(BUILD_DIR)
    handler = partial(DevWebHandler, directory=str(BUILD_DIR))
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain(certfile=str(CERT_FILE), keyfile=str(KEY_FILE))

    with ThreadingHttpServer(('', PORT), handler) as httpd:
        httpd.socket = ssl_context.wrap_socket(httpd.socket, server_side=True)
        print(f'Serving {BUILD_DIR} with Firebase auth proxy on https://localhost:{PORT}')
        httpd.serve_forever()


if __name__ == '__main__':
    main()
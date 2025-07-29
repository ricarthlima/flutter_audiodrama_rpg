import os
import json
import socket
import http.server
import socketserver

PORT = 40000
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
LIST_FILE = os.path.join(ROOT_DIR, "list.json")


def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    except Exception:
        return "localhost"
    finally:
        s.close()


def should_ignore(folder_name):
    return folder_name.startswith(".")


def generate_file_list():
    file_list = []
    for root, dirs, files in os.walk(ROOT_DIR):
        dirs[:] = [d for d in dirs if not should_ignore(d)]
        rel_dir = os.path.relpath(root, ROOT_DIR)
        for file in files:
            if file in [os.path.basename(__file__), "list.json"]:
                continue
            rel_path = os.path.normpath(os.path.join(rel_dir, file))
            if not rel_path.startswith("."):
                file_list.append(rel_path.replace("\\", "/"))
    return file_list


def save_list_json(file_list):
    with open(LIST_FILE, "w", encoding="utf-8") as f:
        json.dump(file_list, f, indent=2, ensure_ascii=False)
    print(f"✅ Arquivo list.json gerado com {len(file_list)} arquivos.")


class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        super().end_headers()

    def log_message(self, format, *args):
        pass  # silencia os logs


if __name__ == "__main__":
    files = generate_file_list()
    save_list_json(files)

    ip = get_local_ip()
    handler = CustomHandler

    with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), handler) as httpd:
        print(f"🌐 Servidor disponível em: http://{ip}:{PORT}")
        print("🌍 Para acesso externo, abra essa porta no roteador/firewall.")
        print("🛑 Pressione Ctrl+C para encerrar.")
        httpd.serve_forever()

import os
import subprocess
import json
import threading
import time
import urllib.request
from datetime import datetime
from ClassWidgets.SDK import CW2Plugin, PluginAPI
from PySide6.QtCore import Slot, QObject, Signal, Property


def get_log_path():
    appdata = os.environ.get('APPDATA')
    if not appdata:
        return None
    log_dir = os.path.join(appdata, "Bloret-Launcher", "For-ClassWidgets2", "log")
    if not os.path.exists(log_dir):
        os.makedirs(log_dir, exist_ok=True)
    return os.path.join(log_dir, "plugin.log")


def log_message(message):
    path = get_log_path()
    if not path:
        return
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        with open(path, "a", encoding="utf-8") as f:
            f.write(f"[{timestamp}] {message}\n")
    except Exception as e:
        print(f"Failed to write log: {e}")


class LauncherBackend(QObject):
    def __init__(self, launcher_path):
        super().__init__()
        self.launcher_path = launcher_path

    @Slot()
    def launch(self):
        log_message(f"Attempting to launch: {self.launcher_path}")
        if os.path.exists(self.launcher_path):
            try:
                subprocess.Popen([self.launcher_path], cwd=os.path.dirname(self.launcher_path))
                log_message("Launch command executed successfully.")
            except Exception as e:
                log_message(f"Launch failed with error: {e}")
        else:
            log_message(f"Launcher executable not found at: {self.launcher_path}")


class ServerStatusBackend(QObject):
    status_changed = Signal()

    def __init__(self):
        super().__init__()
        self._online = False
        self._players_online = 0
        self._players_max = 0
        self._motd = "正在获取状态..."
        self._ip = ""
        
        self._running = True
        self._thread = threading.Thread(target=self._refresh_loop, daemon=True)
        self._thread.start()
        log_message("ServerStatusBackend initialized and thread started.")

    @Property(bool, notify=status_changed)
    def online(self): return self._online

    @Property(int, notify=status_changed)
    def playersOnline(self): return self._players_online

    @Property(int, notify=status_changed)
    def playersMax(self): return self._players_max

    @Property(str, notify=status_changed)
    def motd(self): return self._motd

    def _get_json(self, url):
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=10) as response:
                content = response.read().decode('utf-8')
                return json.loads(content)
        except Exception as e:
            log_message(f"API Fetch error for {url}: {e}")
            return None

    def _refresh_loop(self):
        while self._running:
            try:
                # 1. 获取 IP
                log_message("Requesting dynamic IP from GitCode...")
                ip_data = self._get_json("https://raw.gitcode.com/Bloret/Bloret-Launcher/raw/Windows/IP.json")
                if ip_data:
                    self._ip = ip_data.get("PCFS", "")
                    log_message(f"Successfully obtained IP: {self._ip}")
                else:
                    log_message("Failed to obtain dynamic IP.")
                
                # 2. 获取服务器状态
                if self._ip:
                    url = f"http://{self._ip}:20901/api/getserver?name=Bloret"
                    log_message(f"Requesting server status from {url}...")
                    server_data = self._get_json(url)
                    if server_data and "realTimeStatus" in server_data:
                        status = server_data["realTimeStatus"]
                        self._online = status.get("online", False)
                        self._players_online = status.get("playersOnline", 0)
                        self._players_max = status.get("playersMax", 0)
                        motd_list = status.get("motdClean", ["未知状态"])
                        self._motd = " ".join(motd_list)
                        log_message(f"Status update: Online={self._online}, Players={self._players_online}/{self._players_max}")
                    else:
                        self._online = False
                        self._motd = "查询失败或服务器离线"
                        log_message(f"Server data response was invalid or empty for {url}")
                
                self.status_changed.emit()
            except Exception as e:
                log_message(f"Error in refresh loop: {e}")
            
            time.sleep(60)

    def stop(self):
        self._running = False


class Plugin(CW2Plugin):
    def on_load(self):
        super().on_load()
        log_message("Plugin.on_load() called.")
        
        launcher_exe = os.path.join(str(self.PATH), "launcher", "Bloret-Launcher.exe")
        self.launcher_backend = LauncherBackend(launcher_exe)
        
        self.api.widgets.register(
            widget_id="net.bloret.launcher.widget",
            name="Bloret 启动器",
            qml_path=os.path.join(str(self.PATH), "qml", "Launcher.qml"),
            backend_obj=self.launcher_backend
        )

        self.status_backend = ServerStatusBackend()
        self.api.widgets.register(
            widget_id="net.bloret.server.status",
            name="Bloret 服务器状态",
            qml_path=os.path.join(str(self.PATH), "qml", "ServerStatus.qml"),
            backend_obj=self.status_backend
        )
        
        log_message("All widgets registered.")

    def on_unload(self):
        log_message("Plugin.on_unload() called.")
        if hasattr(self, 'status_backend'):
            self.status_backend.stop()
        print(f"Bloret Launcher unloaded")

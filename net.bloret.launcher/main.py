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
        log_message(f"LAUNCH CLICKED: {self.launcher_path}")
        if os.path.exists(self.launcher_path):
            try:
                subprocess.Popen([self.launcher_path], cwd=os.path.dirname(self.launcher_path))
                log_message("Process started successfully.")
            except Exception as e:
                log_message(f"Process start error: {e}")
        else:
            log_message(f"File not found: {self.launcher_path}")


class ServerStatusBackend(QObject):
    status_changed = Signal()

    def __init__(self):
        super().__init__()
        self._online = False
        self._players_online = 0
        self._players_max = 0
        self._motd = "初始化中..."
        self._ip = ""
        
        self._running = True
        self._thread = threading.Thread(target=self._refresh_loop, daemon=True)
        self._thread.start()

    @Property(bool, notify=status_changed)
    def online(self): 
        # log_message(f"QML read online: {self._online}")
        return self._online

    @Property(int, notify=status_changed)
    def playersOnline(self): return self._players_online

    @Property(int, notify=status_changed)
    def playersMax(self): return self._players_max

    @Property(str, notify=status_changed)
    def motd(self): return self._motd

    def _get_json(self, url):
        headers = { 'User-Agent': 'Mozilla/5.0' }
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=8) as response:
                return json.loads(response.read().decode('utf-8'))
        except Exception as e:
            log_message(f"Fetch ERROR {url}: {e}")
            return None

    def _refresh_loop(self):
        while self._running:
            try:
                ip_data = self._get_json("https://raw.gitcode.com/Bloret/Bloret-Launcher/raw/Windows/IP.json")
                if ip_data:
                    self._ip = ip_data.get("PCFS", "")
                
                if self._ip:
                    url = f"http://{self._ip}:20901/api/getserver?name=Bloret"
                    server_data = self._get_json(url)
                    if server_data and "realTimeStatus" in server_data:
                        status = server_data["realTimeStatus"]
                        self._online = status.get("online", False)
                        self._players_online = status.get("playersOnline", 0)
                        self._players_max = status.get("playersMax", 0)
                        motd_list = status.get("motdClean", ["无公告"])
                        self._motd = " ".join(motd_list)
                        log_message(f"SYNC OK: {self._online}, {self._players_online}/{self._players_max}")
                    else:
                        self._online = False
                        self._motd = "无法获取服务器信息"
                
                self.status_changed.emit()
            except Exception as e:
                log_message(f"Loop ERROR: {e}")
            time.sleep(60)

    def stop(self):
        self._running = False


class Plugin(CW2Plugin):
    def on_load(self):
        super().on_load()
        log_message("Plugin Loading...")
        
        # 路径准备
        launcher_exe = os.path.join(str(self.PATH), "launcher", "Bloret-Launcher.exe")
        self.launcher_backend = LauncherBackend(launcher_exe)
        self.status_backend = ServerStatusBackend()
        
        # 使用位置参数注册，确保 backend_obj 能够被正确识别
        # register(widget_id, name, qml_path, backend_obj=None, ...)
        
        # 1. Launcher
        self.api.widgets.register(
            "net.bloret.launcher.widget",
            "Bloret 启动器",
            os.path.join(str(self.PATH), "qml", "Launcher.qml"),
            self.launcher_backend
        )

        # 2. Server Status
        self.api.widgets.register(
            "net.bloret.server.status",
            "Bloret 服务器状态",
            os.path.join(str(self.PATH), "qml", "ServerStatus.qml"),
            self.status_backend
        )
        
        log_message("Plugin Loaded and Widgets Registered.")

    def on_unload(self):
        if hasattr(self, 'status_backend'):
            self.status_backend.stop()
        log_message("Plugin Unloaded.")

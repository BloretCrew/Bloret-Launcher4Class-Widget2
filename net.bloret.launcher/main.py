import os
import subprocess
import json
import threading
import time
import urllib.request
from ClassWidgets.SDK import CW2Plugin, PluginAPI
from PySide6.QtCore import Slot, QObject, Signal, Property


class LauncherBackend(QObject):
    def __init__(self, launcher_path):
        super().__init__()
        self.launcher_path = launcher_path

    @Slot()
    def launch(self):
        print(f"Launching portable: {self.launcher_path}")
        if os.path.exists(self.launcher_path):
            try:
                subprocess.Popen([self.launcher_path], cwd=os.path.dirname(self.launcher_path))
            except Exception as e:
                print(f"Launch failed: {e}")
        else:
            print(f"Launcher not found at {self.launcher_path}")


class ServerStatusBackend(QObject):
    status_changed = Signal()

    def __init__(self):
        super().__init__()
        self._online = False
        self._players_online = 0
        self._players_max = 0
        self._motd = "正在获取状态..."
        self._ip = ""
        
        # 启动后台线程定时刷新
        self._running = True
        self._thread = threading.Thread(target=self._refresh_loop, daemon=True)
        self._thread.start()

    @Property(bool, notify=status_changed)
    def online(self): return self._online

    @Property(int, notify=status_changed)
    def playersOnline(self): return self._players_online

    @Property(int, notify=status_changed)
    def playersMax(self): return self._players_max

    @Property(str, notify=status_changed)
    def motd(self): return self._motd

    def _get_json(self, url):
        try:
            with urllib.request.urlopen(url, timeout=5) as response:
                return json.loads(response.read().decode('utf-8'))
        except Exception as e:
            print(f"Fetch error ({url}): {e}")
            return None

    def _refresh_loop(self):
        while self._running:
            try:
                # 1. 获取 IP
                if not self._ip:
                    ip_data = self._get_json("https://raw.gitcode.com/Bloret/Bloret-Launcher/raw/Windows/IP.json")
                    if ip_data:
                        self._ip = ip_data.get("PCFS", "")
                
                # 2. 获取服务器状态
                if self._ip:
                    server_data = self._get_json(f"http://{self._ip}:20901/api/getserver?name=Bloret")
                    if server_data and "realTimeStatus" in server_data:
                        status = server_data["realTimeStatus"]
                        self._online = status.get("online", False)
                        self._players_online = status.get("playersOnline", 0)
                        self._players_max = status.get("playersMax", 0)
                        motd_list = status.get("motdClean", ["未知状态"])
                        self._motd = " ".join(motd_list)
                    else:
                        self._online = False
                        self._motd = "服务器离线或无法获取数据"
                
                self.status_changed.emit()
            except Exception as e:
                print(f"Error in refresh loop: {e}")
            
            time.sleep(60) # 每分钟刷新一次

    def stop(self):
        self._running = False


class Plugin(CW2Plugin):
    def on_load(self):
        super().on_load()
        
        # 1. Launcher 便携化路径
        # 文件夹已被 Move-Item 移入 net.bloret.launcher/launcher
        launcher_exe = os.path.join(str(self.PATH), "launcher", "Bloret-Launcher.exe")
        self.launcher_backend = LauncherBackend(launcher_exe)
        
        # 注册启动器小组件
        self.api.widgets.register(
            widget_id="net.bloret.launcher.widget",
            name="Bloret Launcher",
            qml_path=os.path.join(str(self.PATH), "qml", "Launcher.qml"),
            backend_obj=self.launcher_backend
        )

        # 2. 服务器状态小组件
        self.status_backend = ServerStatusBackend()
        self.api.widgets.register(
            widget_id="net.bloret.server.status",
            name="Bloret Server Status",
            qml_path=os.path.join(str(self.PATH), "qml", "ServerStatus.qml"),
            backend_obj=self.status_backend
        )
        
        # 调试设置页面
        self.api.ui.register_settings_page(
            qml_path=os.path.join(str(self.PATH), "qml", "Launcher.qml"),
            title="Bloret Settings",
            icon=os.path.join(str(self.PATH), "icon.png")
        )

    def on_unload(self):
        if hasattr(self, 'status_backend'):
            self.status_backend.stop()
        print(f"Bloret Launcher unloaded")

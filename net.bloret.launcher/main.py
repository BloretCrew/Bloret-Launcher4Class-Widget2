import os
import subprocess
from ClassWidgets.SDK import CW2Plugin, PluginAPI

from PySide6.QtCore import Slot, QObject

class LauncherBackend(QObject):
    def __init__(self, launcher_path):
        super().__init__()
        self.launcher_path = launcher_path

    @Slot()
    def launch(self):
        print(f"Launching: {self.launcher_path}")
        if os.path.exists(self.launcher_path):
            try:
                subprocess.Popen([self.launcher_path], cwd=os.path.dirname(self.launcher_path))
                print("Launch successful")
            except Exception as e:
                print(f"Launch failed: {e}")
        else:
            print("Launcher executable not found")


class Plugin(CW2Plugin):
    def on_load(self):
        super().on_load()
        
        # 定义 Launcher 的绝对路径
        launcher_path = r"g:\Work\git\Bloret-Launcher4Class-Widget2\Bloret-Launcher-Windows\Bloret-Launcher.exe"
        qml_path = os.path.join(str(self.PATH), "qml", "Launcher.qml")
        
        # 创建后端对象
        self.backend = LauncherBackend(launcher_path)
        
        # 调试：注册设置页面，看看是否能显示
        self.api.ui.register_settings_page(
            qml_path=qml_path,
            title="Bloret Settings",
            icon=os.path.join(str(self.PATH), "icon.png")
        )
        
        # 注册小组件
        self.api.widgets.register(
            widget_id="net.bloret.launcher.widget",
            name="Bloret Launcher",
            qml_path=qml_path,
            backend_obj=self.backend
        )
        
        print(f"Bloret Launcher widget registered with path: {qml_path}")

    def on_unload(self):
        print(f"Bloret Launcher unloaded")

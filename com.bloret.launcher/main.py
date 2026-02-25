import os
import subprocess
from ClassWidgets.SDK import CW2Plugin, PluginAPI, QObject


class LauncherBackend(QObject):
    def __init__(self, launcher_path):
        super().__init__()
        self.launcher_path = launcher_path

    # 把这个方法暴露给 QML
    from PySide6.QtCore import Slot
    @Slot()
    def launch(self):
        print(f"Launching: {self.launcher_path}")
        if os.path.exists(self.launcher_path):
            try:
                # 使用 Popen 异步启动，不阻塞主程序
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
        
        # 创建后端对象
        self.backend = LauncherBackend(launcher_path)
        
        # 注册小组件
        self.api.widgets.register(
            widget_id="com.bloret.launcher.widget",
            name="Bloret Launcher",
            qml_path=os.path.join(self.PATH, "qml/Launcher.qml"),
            backend_obj=self.backend
        )
        
        print(f"Bloret Launcher widget registered")

    def on_unload(self):
        print(f"Bloret Launcher unloaded")

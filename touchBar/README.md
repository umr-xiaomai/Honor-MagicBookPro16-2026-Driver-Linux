# touchBar / touchPad (压力触控板模块)

针对 **HONOR MagicBook Pro 16 2026 (XWC-P)** 全域压感触控板的 Linux 适配模块。

## 目录内容

* **`acpi-touchpad-override.img`**：预编译的早期 CPIO 镜像，包含修复后的 `kernel/firmware/acpi/ssdt-touchpad.aml`。
* **`ssdt-touchpad.aml` / `ssdt-touchpad.asl` / `ssdt-touchpad.patch`**：ACPI 表源码与补丁，将引发致命报错的模块级执行语句移至 `_CRS` 方法。
* **`honor-tops0102-edge.bpf.c`**：针对左边缘滑动手势的 HID-BPF 程序，拦截 `0x0E` 报文转换为系统屏幕亮度增减键。
* **`touchpad_control.py`**：Linux 原生压感与振动强度调节工具（支持命令行与图形界面），对应 Windows 电脑管家的触控板设置面板。
* **`install.sh`**：本模块的独立安装脚本。

## 独立安装

```bash
sudo ./install.sh
```

## 调节压感与振感

安装后系统会生成命令 `honor-touchpad`：

```bash
# 打开图形设置面板
honor-touchpad --gui

# 命令行调整按压灵敏度 (low / mid / high)
honor-touchpad --sensitivity high

# 命令行调整按压振感强度 (off / low / mid / high)
honor-touchpad --shock high

# 查看当前状态与设备节点
honor-touchpad --status
```

## Windows 平台使用方法

本工具支持 **Windows / Linux 双平台原生硬件控制**。在 Windows 下可作为免安装、不占后台的轻量设置器直接使用：

* 双击项目根目录的 `运行触控板设置.bat` 即可启动图形控制面板。
* 或在终端中执行：
  ```cmd
  python touchBar/touchpad_control.py --gui
  ```
* 调整设置后会直接通过底层硬件接口与注册表通道应用，实时改变触控板物理按压触发力度与振动力度，无需后台常驻官方电脑管家。


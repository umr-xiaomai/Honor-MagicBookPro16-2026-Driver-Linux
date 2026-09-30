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

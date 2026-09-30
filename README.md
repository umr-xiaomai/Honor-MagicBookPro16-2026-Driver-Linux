# HONOR MagicBook Pro 16 2026 (XWC-P) Linux 驱动与功能适配套件

本仓库针对 **HONOR MagicBook Pro 16 2026 (代号 XWC-P，搭载 Intel Core Ultra / Panther Lake 平台)** 提供全套 Linux 硬件适配、补丁以及全域压感触控板的控制工具。

---

## 解决的核心问题

1. **全域压感触控板（touchBar / touchPad）完全无法识别**：
   - **原因**：BIOS 官方固件中的 `SSDT:I2C_DEVT` 表在 `Device(NFC0)` 处写了一行模块级执行语句 `INT1 = GNUM(0x001A088A)`。在 Linux 内核 ACPICA 加载时报 `AE_AML_INTERNAL` 严重错误并丢弃整张表，导致触控板从设备树中彻底消失。
   - **解决**：通过注入早期 CPIO ACPI 表覆盖 (`acpi-touchpad-override.img`) 修复表加载，无需重编译内核。
2. **触控板压感与振动强度调节（Linux 版电脑管家）**：
   - 提供 `honor-touchpad`（命令行与 GUI 图形界面），向 `/dev/hidraw` 发送对应指令调节按压灵敏度与振感反馈。
3. **边缘滑动手势**：
   - 右边缘上下滑动：硬件 EC 原生拦截并映射为音量加减（开箱即用）。
   - 左边缘上下滑动：通过内核 HID-BPF 将 `0x0E` 报文转换为标准屏幕亮度调节键。
4. **内置键盘卡死/无响应（keyBoard）**：
   - 自动添加 `i8042.dumbkbd=1` 内核启动参数，并配置 `90-honor-keyboard.hwdb` 修正麦克风静音键、摄像头键等 Fn 按键映射。
5. **音频与耳麦自动切换（audioCodec）**：
   - 配置 ALC256 编解码器引脚模型，修复耳机插拔自动静音及麦克风切换。
6. **指纹识别权限（fingerPrint）**：
   - 汇顶 Goodix `27c6:6f94` 传感器 udev 权限规则配置。
7. **电池保养充电上限（batteryCharge）**：
   - 支持将满电限制设为 80% 或 70%，保护电池健康。

---

## 模块结构

```text
MagicBookPro16Driver/
├── .gitignore                      # Git 忽略配置
├── .gitattributes                 # 跨平台换行符与二进制配置 (强制 Linux LF)
├── install.sh                     # 根目录一键自动化安装脚本
├── README.md                      # 项目说明文档
│
├── touchBar/                      # 触控板核心模块
│   ├── acpi-touchpad-override.img # 预编译的早期 CPIO ACPI 覆盖镜像
│   ├── ssdt-touchpad.aml          # 修正后的 ACPI AML 字节码
│   ├── ssdt-touchpad.asl          # ACPI 源码与修补补丁
│   ├── honor-tops0102-edge.bpf.c  # 左边缘亮度手势 HID-BPF 源码
│   ├── touchpad_control.py        # 压感与振动强度设置工具 (CLI & GUI)
│   ├── install.sh                 # 触控板独立安装脚本
│   └── README.md
│
├── keyBoard/                      # 键盘与按键映射模块
│   ├── 90-honor-keyboard.hwdb     # Fn 键 udev 扫描码映射
│   ├── install.sh                 # 键盘独立安装脚本 (配置 i8042.dumbkbd=1)
│   └── README.md
│
├── audioCodec/                    # 声卡与耳麦适配模块
│   ├── alsa-honor.conf            # ALC256 与 SOF 驱动选项
│   ├── install.sh                 # 音频独立安装脚本
│   └── README.md
│
├── fingerPrint/                   # 指纹识别适配模块
│   ├── 70-goodix-fingerprint.rules# Goodix 27c6:6f94 权限规则
│   ├── install.sh                 # 指纹独立安装脚本
│   └── README.md
│
└── batteryCharge/                 # 电池充电保护模块
    ├── honor-battery-limit.sh     # 充电阈值设置脚本 (70% / 80% / 100%)
    ├── honor-battery-limit.service# 开机自启 systemd 服务
    ├── install.sh                 # 电池独立安装脚本
    └── README.md
```

---

## 一键安装步骤

### ⚠️ 前置重要检查（必看）

* **必须在 BIOS/UEFI 中关闭 Secure Boot（安全启动）**：
  * 开机时狂按 `F2` 进入 BIOS。
  * 将 `Secure Boot` 选项设置为 `Disabled`（关闭）。
  * **原因**：Linux 在开启安全启动时会开启内核锁定模式（Lockdown），该模式会**直接静默拦截**从 initrd 加载任何自定义 ACPI 覆盖表，导致触控板补丁完全无法生效。

### 运行一键安装

进入当前仓库目录后，执行：

```bash
sudo ./install.sh
sudo reboot
```

脚本会自动检测你的 Linux 发行版（Ubuntu/Debian、Fedora、Arch Linux、openSUSE），依次安装各设备模块，并重新生成 bootloader 与 initramfs。

---

## 触控板压感与设置

系统重启后，即可使用自带的控制工具：

```bash
# 打开图形控制面板 (类似 Windows 电脑管家)
honor-touchpad --gui

# 或在命令行中调节触发力度 (low / mid / high)
honor-touchpad --sensitivity high

# 调节马达振动力度 (off / low / mid / high)
honor-touchpad --shock high

# 查看当前触控板工作状态
honor-touchpad --status
```

---

## 🪟 Windows 平台使用方法

`touchpad_control.py` 经过特别优化，现已**完整支持 Windows 平台直接运行**：

* **免装电脑管家**：无需在后台常驻体积庞大、包含众多守护进程的官方电脑管家。
* **物理硬件直连**：双击项目根目录的 **`运行触控板设置.bat`**，即可弹出原生设置面板。拖动滑块或选择档位保存后，会立即同步硬件物理触发克数与马达振感。
* **命令行调节**：
  ```cmd
  python touchBar/touchpad_control.py --sensitivity high --shock high
  ```


# HONOR MagicBook Pro 16 2026（XWC-P）Linux 适配工具

面向 HONOR XWC-P，提供硬件诊断、按模块安装、固件 ACPI 修补和触控板设置工具。需要 Bash 和 Python **3.10+**。本仓库包含适配脚本和实验代码，并不包含全部硬件的 Linux 驱动。

当前开发环境是这台机器的 Windows，已只读确认机型 **HONOR XWC-P、BIOS 1.12**，并检查实际驱动和电脑管家 DLL。Linux 安装路径以 **Fedora 44** 为重点，兼顾 Ubuntu/Debian、Arch 和 openSUSE；硬件是否正常仍需在目标 Linux 内验证。具体问题与证据见 [代码与 Windows 驱动分析](docs/driver-audit.md)。

## 先诊断，再按需启用

在实际安装的 Linux 中运行，WSL 不能代替本机 Linux 硬件环境：

```bash
# 普通用户即可运行；--logs 可能需要 sudo 才能读取完整内核日志
bash install.sh --diagnose -- --json
sudo bash install.sh --diagnose -- --json --logs > honor-diagnose.json

# 仅预览，任何模块均不修改系统
bash install.sh --dry-run

# 安装工具和匹配本机的规则，不自动注入 ACPI 或写入硬件参数
sudo bash install.sh
```

默认安装会安装触控板 CLI、限定设备的 udev 权限规则、XWC-P 键盘映射及电池 CLI/服务文件。音频模块只检查。默认不新增启动参数，不启用电池限制，不启用触控板自动应用服务，也不安装未经接入验证的 HID-BPF 程序。已有电池服务的启用状态会保留。

安装器遇到失败会返回非零并停止，之前完成的模块可能已经安装；不会再把失败统一显示为“全部成功”。不自动安装软件包。实际写入要求 root 和匹配的机型，`--dry-run` 无需 root。

```bash
# 单独执行模块；-- 后的参数传给该模块
sudo bash install.sh --module touchBar
bash install.sh --module touchBar -- --help
```

## 触控板完全不识别：固件 ACPI 修补

原代码针对某个 BIOS 的 `I2C_DEVT` 表，将 NFC0 中过早执行的 `INT1 = GNUM(0x001A088A)` 移至 `_CRS`。这只适用于相同结构的固件；当前 BIOS 是否仍有此问题，需要结合 Linux 诊断日志判断。

**不要手动安装仓库内旧的 `.aml` / `.img`**：旧表改变了 OEM Table ID，不能作为原表升级，还可能造成重复命名空间。新的安装器只接受根据实际固件生成并校验的 bundle。

Fedora 44 构建依赖：

```bash
sudo dnf install python3 acpica-tools cpio dracut
```

Ubuntu/Debian：`sudo apt install python3 acpica-tools cpio`。Arch：`sudo pacman -S python acpica cpio`。openSUSE：`sudo zypper install python3 acpica cpio dracut`。GUI 另外需要本发行版的 Tkinter 包，与 ACPI 修补无关。

```bash
# 自动读取当前 Linux 的 HONOR I2C_DEVT 表；构建前需确保输出目录不存在
sudo bash touchBar/build.sh --output-dir /var/tmp/honor-touchpad-acpi

# 查看生成的 ssdt-touchpad.dsl，再安装这个固件专用结果
sudo bash install.sh --module touchBar -- --acpi-dir /var/tmp/honor-touchpad-acpi
```

构建只修改已知的 NFC0 语句位置，保留原表标识并递增 OEM revision；未知结构、编译失败、校验错误或固件不匹配都会停止。`iasl` 若无法推断跨表方法签名，可用多个 `--external-table` 提供当前固件的相关表，见 [触控板说明](touchBar/README.md)。升级 BIOS 后必须重新评估和构建。

| 系统/启动方式 | ACPI 安装路径 | 键盘启动参数 |
| --- | --- | --- |
| Fedora 44 常规 dracut 系统 | dracut `acpi_override`，重建 initramfs，保留 BLS 格式 | grubby |
| Ubuntu / Debian，GRUB | 追加独立早期 CPIO，运行 update-grub | 修改 GRUB 配置后 update-grub |
| Arch，GRUB | 独立早期 CPIO，运行 grub-mkconfig | 修改 GRUB 配置后 grub-mkconfig |
| openSUSE 常规 dracut 系统 | dracut `acpi_override` | grubby 或 grub2-mkconfig |
| 自定义启动链、systemd-boot、UKI、不可变系统 | 需确认实际镜像生成工具；见模块说明，不宣称通用支持 | 需按实际启动管理器配置 |

以上是代码支持的集成路径，**并非这些发行版均已通过本机实测**。ACPI 安装会检查当前内核的表升级支持及 lockdown/Secure Boot 状态。仅 ACPI 覆盖受这些条件限制，普通工具安装不要求关闭 Secure Boot。内核或 BIOS 已修复的问题不必再次打补丁。

## 触控板灵敏度和振感

```bash
honor-touchpad --status
honor-touchpad --gui
```

`--status` 明确显示设备发现结果、保存的偏好和传输能力；保存值不是硬件回读。Linux 仅匹配 **I2C 27c6:0f9a**，不会误选 **USB 27c6:6f94 指纹设备**。

原 Linux 程序发送的 `06 01 ...` 私有报文在仓库中没有协议或抓包依据。默认禁止发送；如需开发实验，必须显式传 `--experimental`，并通过 HID Output Report ID/长度校验。发送成功也不能证明灵敏度或振感已经生效。Linux GUI 不再提供无法实际控制的边缘手势开关。

HID-BPF 源码保留供开发：它依赖未附带的头文件、兼容的内核 kfunc 和真正的 loader，当前安装器不声称已加载亮度手势。

## 其他模块

```bash
# 仅在确有内置键盘无响应时启用控制器兼容参数
sudo bash install.sh --module keyBoard -- --enable-dumbkbd

# 检查/清理旧脚本强制安装的音频参数
sudo bash install.sh --module audioCodec -- --remove-legacy-config

# 检查电池内核接口，再显式启用 80% 上限
honor-battery-limit --status
sudo bash install.sh --module batteryCharge -- --enable --limit 80
```

音频默认依靠发行版内核、SOF 固件和 ALSA UCM；`alc256-asus-mic` 只作为检测到 ALC256 后的显式实验选项。指纹模块仅提供目标 USB 设备的本地会话权限；是否支持识别取决于 libfprint，安装规则不等于获得驱动。电池若没有内核导出的阈值接口，会明确返回“不支持”，不会通过猜测 EC/WMI 命令强行写入。

模块详细说明：[键盘](keyBoard/README.md)、[音频](audioCodec/README.md)、[指纹](fingerPrint/README.md)、[电池](batteryCharge/README.md)。配置更改会尽量备份已有文件，重建启动文件失败会报错；不能保证所有 initramfs 镜像原子回滚。重启前检查模块输出及备份位置。

## Windows

双击 `运行触控板设置.bat`，或运行：

```powershell
python touchBar/touchpad_control.py --status
python touchBar/touchpad_control.py --gui
```

Windows 设置依赖 **HONOR 电脑管家的 MagicTouchPadHelper.dll 和运行中的 MBAMainService**。这些导出函数通过 IPC 请求后台服务，不能保证移除电脑管家后仍可工作；仅写注册表也不代表硬件改变。工具不再把缺少 DLL/服务当作成功。状态检查不发送设置请求。

## 开发验证

```bash
python3 -m unittest discover -s tests -v
bash install.sh --dry-run
```

回归测试使用模拟设备/固件/文件系统，不写本机硬件。GitHub Actions 配置了 Fedora 44、Ubuntu 24.04、Debian 13、Arch 和 openSUSE 的容器静态检查及无硬件测试；容器检查无法验证启动链、触控板手感或指纹识别。真实 Linux 验证应保存安装前后的诊断报告，并在重启后检查 ACPI Table Upgrade、I2C-HID 枚举和输入事件。

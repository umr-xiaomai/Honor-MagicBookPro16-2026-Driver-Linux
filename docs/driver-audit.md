# 代码与 Windows 驱动分析

检查日期：2026-11-16。工作区运行在 Windows；未切换系统、加载驱动、调用设置 DLL 或修改注册表。这里区分代码能证明的问题、Windows 本机证据和仍需 Linux 验证的行为。

## 已确认的代码问题

| 原实现 | 后果 | 重构处理 |
| --- | --- | --- |
| 所有 `.sh` 文件 Git mode 为 `100644`，README 使用 `sudo ./install.sh` | Linux clone 后直接执行会遇到权限错误 | 设置可执行位，同时示例使用 bash |
| SSDT 把 `I2C_DEVT` 改成 `I2CDEVC`，OEM revision 仍为 `0x1000` | 不满足内核表升级匹配；可能追加新表并冲突，而非替换问题表 | 从当前固件生成、保留标识、revision +1、校验 checksum/SHA256 |
| 用一个固定 AML/CPIO 覆盖全部 BIOS | 设备资源/方法可能与现有固件不兼容 | 未知固件结构拒绝构建，安装检查实际固件匹配 |
| Fedora 用单条 `initrd` 塞两个路径，kernel-install 把第三参数当文件 | BLS 语法/更新钩子不正确 | Fedora 使用 dracut 自带的早期 ACPI 覆盖机制 |
| Arch 用 sed 替换不存在的 GRUB 变量 | sed 成功但没有写入配置 | 使用明确的配置块及正确生成器 |
| 根安装器大量 `|| true` 后宣布全部成功 | 用户无法从退出码知道安装失败 | 传播失败，停止后续模块 |
| hidraw 只按 `27C6` 子串匹配 | 可能把 Goodix 指纹或其他设备当触控板 | 校验 I2C bus、完整 VID/PID，多设备需显式选择 |
| Linux 私有报文无协议依据，写失败也保存设置、返回 0 | 失败伪装成生效，并覆盖偏好 | 默认阻止未验证协议；实验模式检查描述符及写入，失败非零且不保存 |
| root 自动应用用户 home 中配置 | 用户与 root 配置路径不同，可能自动发送默认值 | 移除已知旧自动应用服务，显式配置/应用 |
| HID-BPF 编译缺少头文件、没有附加步骤 | 编译失败被忽略，实际从未加载 | 不自动编译，不声称手势已启用 |
| 音频强制 ASUS quirk 及未经核实的 SOF 参数 | 型号名不能证明 quirk 适用，可能破坏音频 | 默认诊断；可清理旧配置，实验模型需检测及显式启用 |
| 指纹 `0666`、假定 plugdev 存在 | 所有用户可访问敏感设备，权限规则不提供驱动 | 精确 USB device 匹配、logind uaccess、移除驱动承诺 |
| 电池假定 BAT0、任意字符串写入、不支持仍成功 | 多电池/不同名称失效，输入错误不透明 | 枚举接口、参数校验、协调 start/end、回读与不支持退出码 |

内核 ACPI 表升级规则可核对 [Linux drivers/acpi/tables.c](https://github.com/torvalds/linux/blob/master/drivers/acpi/tables.c)：signature、OEM ID、OEM Table ID 必须相同，新 OEM revision 必须更大；锁定模式会拒绝覆盖。早期覆盖说明见 [Linux 文档](https://docs.kernel.org/admin-guide/acpi/initrd_table_override.html)。dracut 的 `acpi_override` / `acpi_table_dir` 见 [dracut.conf](https://github.com/dracutdevs/dracut/blob/master/man/dracut.conf.5.asc)。

## 当前 Windows 的实际设备

通过 Win32_ComputerSystem / Win32_BIOS、PnP 属性、Win32_PnPSignedDriver 读取。省略实例路径中的序列号。

| 项目 | 本机结果 | 能说明什么 |
| --- | --- | --- |
| DMI | HONOR XWC-P | 与仓库目标机型匹配 |
| BIOS | 1.12，日期 2026-09-30 | 旧 ACPI dump 是否适用仍不能据此确定 |
| 触控板 ACPI ID | `ACPI\TOPS010`，兼容 `PNP0C50` | 当前固件可在 Windows 枚举标准 I2C-HID，名称不等于源码注释 TOPS0102 |
| I2C-HID | `hidi2c.inf` / `hidi2c` | 标准微软 HID-over-I2C 栈 |
| 触控板 collection | `HID\TOPS010&COL03`，Usage Page 0x0d / Usage 0x05 | 标准触控板 collection，微软 input.inf 10.0.26100.8972 |
| 其他 HID collections | 鼠标、Consumer Control、Input Configuration、三组 Vendor collections | 私有功能需要匹配对应 collection/报告，不能按 vendor 任意写 |
| 指纹 | USB `27c6:6f94`，Goodix Moc，3.4.151.1012 / oem2.inf | 与触控板是不同设备；Windows 使用 Goodix 用户态生物识别组件 |
| 音频 | `VEN_10EC&DEV_0256`，subsystem `1EE7:2100`，Realtek 6.0.9963.1 | ALC256 身份成立，但 ASUS 机型 quirk 的适用性不成立 |
| 数字麦克风/DSP | Intel Smart Sound，20.43.12622.0 | 需要 Linux 对应 Intel/SOF 驱动、固件和 UCM，不能从两行 modprobe 参数获得完整支持 |

Goodix oem2.inf 显示 UMDF/WinUSB、GoodixMocWbdi.dll 与 engine/sensor/storage adapters。Linux 的 udev 只影响权限，不能替代这套实现。本次核对 [libfprint 开发版支持列表](https://fprint.freedesktop.org/supported-devices.html) 未找到 `27c6:6f94`；发行版是否带补丁或后续新增支持，应以实际 libfprint 版本与 fprintd 结果为准。

## MagicTouchPadHelper.dll 的真实调用链

只读检查本机 `C:\Program Files\HONOR\PCManager\MagicTouchPadHelper.dll`（48,216 bytes，PE x86-64）。SHA256：`93409c493cd48523059c511566193c9cbfccdcf99f77543914c32135e99b8cd1`。

导出表确有 `ChangeSensitivityOpt`、`ChangeShockOpt`、`ChangeEdgeGestureAdjusBrightnessOpt` 等。导入表包含 `Util.dll`、`IPCMessage.dll` 和 C++ 运行库。反汇编可见：

```text
ChangeSensitivityOpt (RVA 0x4fd0)
  -> internal method (RVA 0x1920)
  -> group 0x02400000, message 0x02400002, integer setting
  -> common sender (RVA 0x1c70)
  -> IPCMessageClient::PostIPCMessage

ChangeShockOpt uses message 0x02400003.
```

这段封装没有直接 HID 传输逻辑，调用的 IPC 结果也没有作为可用的硬件确认返回。Python 应将这些封装设为 `restype=None`，并将结果描述为“请求已发送”。本机后台服务 `MBAMainService` 正在运行，对应 `HONOR\BasicService\PCManagerMainService.exe`。

因此，旧代码声称 DLL “直连硬件、免后台”没有依据；仅写注册表、DLL 正常返回或 JSON 保存成功都不能证明硬件改变。当前官方注册表部分偏好使用 REG_SZ，例如 sensitivity 为字符串 `"1"`；新工具兼容 REG_SZ/DWORD，避免把字符串 `"0"` 当作 true。

**不能从这些 IPC 消息推出 Linux 的 HID 报文格式。** 真正无电脑管家依赖的 Linux 控制，需要进一步分析服务端到设备的传输、HID report descriptor 和实际抓包，再实现经过确认的 Output/Feature Report。原代码的 8 字节 `06 01 ...` 在这些证据中没有来源。

## 跨发行版与验证范围

发行版差异主要在 initramfs 生成器、启动管理器、内核配置、SOF/ALSA/libfprint 版本，而不是一个发行版名称判断即可覆盖。Fedora 的 BLS 和 GRUB 默认配置、Debian 的 update-grub、Arch 的 grub-mkconfig、openSUSE 的 grub2/dracut 应分别处理。上游 GRUB 不保证自动读取 `/etc/default/grub.d`，因此通用路径必须让设置进入其实际读取的配置。

已增加模拟固件、描述符、配置损坏、Windows IPC 后端、电池 sysfs 与安装器失败传播的回归测试；ShellCheck/Bash 语法可在当前 Windows+Git Bash 验证。CI 配置覆盖五种发行版容器。**当前会话没有运行任何 Linux 内核或重启验证**，不能据此宣布 Fedora 44 或其他发行版的实际触控板、声音、休眠恢复已修好。

Linux 侧应首先保存 `sudo bash install.sh --diagnose -- --json --logs` 的结果。若触控板已枚举，不应套用 ACPI 补丁；若确有同一 NFC0 错误，才构建当前固件专用 bundle。补丁后检查 `Table Upgrade: override` 日志、I2C-HID/hidraw/input 枚举，并分别验证点击、滚动、耳麦切换与休眠恢复。

# 触控板工具与固件适配

默认只安装 `honor-touchpad` 和针对 I2C HID `27c6:0f9a` 的 udev `uaccess` 规则，不修改 ACPI、不启动自动发送硬件命令的服务，也不宣称已启用边缘手势。

```bash
bash touchBar/install.sh --dry-run
sudo bash touchBar/install.sh
honor-touchpad --status
honor-touchpad --gui
```

`--status` 显示设备发现结果和本地保存的偏好；保存的偏好不代表已从硬件读回。Linux 私有 HID 协议缺少本仓库可重复验证的协议资料，发送命令需要显式使用 `--experimental`。GUI 及 Windows 设置行为见 `honor-touchpad --help` 与项目主文档。Python 图形界面另需发行版的 Tkinter 包（Fedora：`python3-tkinter`，Debian/Ubuntu：`python3-tk`）。

## 触控板完全未枚举：按当前 BIOS 构建 ACPI 补丁

仓库旧版 `ssdt-touchpad.asl/.aml` 和 `acpi-touchpad-override.img` 只保留作问题分析参考，安装器不会使用它们。旧补丁把 OEM Table ID 从 `I2C_DEVT` 改成了 `I2CDEVC`，而 ACPI 表覆盖要求保持表标识且提高 OEM Revision。把其他 BIOS 的完整 SSDT 注入当前系统还可能覆盖已有固件修复。

新版构建从正在运行的 Linux 读取 `HONOR / I2C_DEVT` SSDT，仅识别 NFC0 中已知的模块级 `INT1 = GNUM (0x001A088A)` 语句，将它移到该设备的 `_CRS` 方法。若布局不同、已经修复或编译失败，构建直接停止。保留 OEM 表标识、增加 OEM Revision，并生成绑定原始及补丁表 SHA-256 的清单。

Fedora 44 的操作示例：

```bash
sudo dnf install python3 acpica-tools cpio
sudo bash touchBar/build.sh --output-dir /var/tmp/honor-acpi-build

# 先检查差异；仅应移动该语句并提高 OEM Revision。
diff -u /var/tmp/honor-acpi-build/original.dsl /var/tmp/honor-acpi-build/ssdt-touchpad.dsl
sudo bash touchBar/install.sh --acpi-dir /var/tmp/honor-acpi-build
```

Ubuntu/Debian 对应依赖为 `python3 acpica-tools cpio`；Arch 为 `python acpica cpio`。构建脚本不覆盖已有输出目录。若 `iasl` 报外部方法参数无法解析，可重复使用 `--external-table FILE` 提供同次启动导出的 DSDT/SSDT，不能使用其他 BIOS 的表凑数。

安装前会检查 HONOR XWC-P 机型、与当前固件表完全一致的原始哈希、AML 校验和及表标识/版本、运行内核 ACPI 表升级配置、Secure Boot 和内核 lockdown。仅在这些检查通过后写入启动配置。检查通过表示满足加载条件，仍需重启验证实际设备表现。

## 启动集成

| 环境 | 方式 |
| --- | --- |
| Fedora / openSUSE 等使用 dracut 的普通 initramfs 系统 | 写入专用 `acpi_table_dir` 和 `acpi_override="yes"`，运行 `dracut --regenerate-all --force`，由 dracut 打包未压缩的早期 CPIO；不改 BLS 条目。 |
| Debian / Ubuntu 的 GRUB 系统 | 在保留已有早期 initrd 列表的前提下添加本补丁，运行 `update-grub`。 |
| Arch 等已有 GRUB 的系统 | 同上，运行 `grub-mkconfig -o /boot/grub/grub.cfg`。 |
| 其他启动配置、独立 UKI / ukify、systemd-boot 不使用上述 initramfs 流程 | 不提供完整自动集成，需针对实际镜像生成流程配置，不能只复制文件到 `/boot`。 |

`acpi_table_dir` 是 dracut 的全局选项。安装器会检查 `/etc/dracut.conf`、`/etc/dracut.conf.d` 和 `/usr/lib/dracut/dracut.conf.d` 的有效配置；发现其他配置已设置该目录时，会在写入前停止，以免隐藏已有 ACPI 修复。此时需要手动把校验通过的 AML 合并到已有表目录，并沿用原来的 dracut 配置重建；不要直接覆盖已有目录设置。

已有目标文件在修改前会生成带 `.honor-backup.时间.进程号` 后缀的备份。启动配置更新失败会恢复本次修改前的活动配置、AML/独立 CPIO 文件并返回非零退出码。多内核镜像重建不具备整体事务回滚：失败前部分镜像可能已更新；应在恢复后的配置下重新生成镜像并确认成功，再重启。安装完成不会自动重启。

重启后确认内核日志中的 ACPI upgrade/override 信息与触控板枚举结果：

```bash
sudo journalctl -k -b | rg -i 'ACPI.*(upgrad|overrid)|I2C_DEVT|TOPS0102|i2c.hid'
honor-touchpad --status
```

BIOS 更新后不要继续沿用旧表；需要先撤销旧覆盖，再从新固件重新诊断和构建。

成功加载补丁后，sysfs 显示的可能已经是覆盖表。同一包可以重复安装，前提是当前表与包内补丁哈希完全一致，且构建时记录的机型、BIOS 厂商/版本/日期也与当前系统一致；离线构建、缺少这些记录或 BIOS 已变化的包不能走这条路径。重新构建时，应先撤销覆盖并重启，再从原始固件开始。自动选择按发行版常见流程判断；使用自定义 dracut 流程时可显式加 `--boot-method dracut`。独立 UKI 和 rpm-ostree 系统需要单独配置，不在自动安装范围内。

## 撤销本模块

dracut 路径：删除 `/etc/dracut.conf.d/90-honor-touchpad-acpi.conf`，再运行 `sudo dracut --regenerate-all --force`；确认重建成功后，可删除 `/usr/local/share/honor-touchpad/acpi/ssdt-touchpad.aml`。

GRUB 路径：恢复 `/etc/default/grub` 的安装前备份，或移除 `# HONOR touchpad early ACPI override` 至对应 End 标记之间的配置块，重新运行 `update-grub` 或 `grub-mkconfig`。确认生成的配置不再引用补丁后，再删除 `/boot/acpi-touchpad-override.img`。旧版本安装器写入的其他引用必须一并清理。

工具及权限规则可独立删除：`/usr/local/bin/honor-touchpad`、`/etc/udev/rules.d/70-honor-touchpad.rules`。随后运行 `sudo udevadm control --reload-rules`。用户配置保留在自己的配置目录中。

## 边缘手势状态

`honor-tops0102-edge.bpf.c` 目前只是实验源码。仓库没有包含它依赖的 `vmlinux.h`、`hid_bpf.h`、`hid_bpf_helpers.h`，也没有加载器和经验证的内核 API 版本范围。旧安装器忽略编译错误，而且从未挂载 BPF 程序，因此“安装后左边缘亮度手势可用”的承诺没有实现依据。新版安装器不编译或加载它；右边缘手势是否由 EC 原生提供也需要在具体硬件上验证。

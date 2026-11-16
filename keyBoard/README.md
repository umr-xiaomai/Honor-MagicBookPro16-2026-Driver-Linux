# 内置键盘与 Fn 键

本模块只匹配 DMI 厂商 `HONOR`、产品 `XWC-P`。默认安装 Fn 键 hwdb，不再自动给所有 MagicBook 加启动参数。扫描码来自原仓库，仍需用 `evtest` 在实际固件上确认；映射本身不能修复控制器或内核驱动。

在仓库根目录运行：

```bash
bash keyBoard/install.sh --dry-run
sudo bash keyBoard/install.sh
```

只有确实遇到内置 PS/2 键盘失灵时，才尝试控制器兼容参数：

```bash
sudo bash keyBoard/install.sh --enable-dumbkbd
```

Fedora 优先使用 `grubby --update-kernel=ALL`；Ubuntu/Debian 使用 `update-grub`；Arch/openSUSE 使用检测到的 GRUB 生成器。通用 GRUB 方式在 `/etc/default/grub` 中写入有起止标记的兼容参数块，保留已有参数，不依赖发行版的 `grub.d` 扩展。生成失败会恢复原配置并返回错误；若菜单已被部分更新，应先成功重新生成再重启。systemd-boot、UKI 等其他启动方式需自行配置内核参数。参数在重启后生效。

撤销 Fn 映射：删除 `/etc/udev/hwdb.d/90-honor-keyboard.hwdb`，运行 `sudo systemd-hwdb update` 并重启。撤销兼容参数：Fedora 用 `sudo grubby --update-kernel=ALL --remove-args=i8042.dumbkbd=1`；GRUB 配置方式删除 `/etc/default/grub` 中从 `# BEGIN HONOR XWC-P KEYBOARD WORKAROUND` 到对应 `# END` 的块，再重新生成 GRUB。旧脚本直接写入该文件的参数也需手动移除。

# Goodix 指纹设备权限

本模块只为实际检测到的 USB `27c6:6f94` 安装 udev 权限规则。规则限制到 USB 设备节点，保留 root 权限，并通过 `uaccess` 授权当前本地登录会话；不再授予所有用户读写权限，也不依赖发行版特有的 `plugdev` 组。

```bash
bash fingerPrint/install.sh --dry-run
sudo bash fingerPrint/install.sh
```

**权限规则不提供指纹驱动。** 能否录入仍取决于当前发行版的 libfprint 是否支持该设备及其固件。安装 fprintd 后，以普通登录用户检查：

```bash
fprintd-list "$USER"
fprintd-enroll
```

若报告 `No devices available`，需继续检查 libfprint 驱动支持；重复修改权限或安装 PAM 配置不会补齐驱动。本仓库不自动更改登录认证设置。

卸载规则：删除 `/etc/udev/rules.d/70-goodix-fingerprint.rules`，运行 `sudo udevadm control --reload-rules` 后重启。

# 音频检查与可选耳麦模型

默认只读取 `/proc/asound/card*/codec#*`，不写入音频配置。Panther Lake 平台是否可用还取决于 Linux 内核、固件、SOF 和 ALSA UCM 配置；本仓库没有实现这些驱动。

```bash
bash audioCodec/install.sh
```

原脚本无条件套用 ASUS 的 ALC256 型号，并向 SOF 模块写入未验证的 `dmic_num=2`。它不能证明麦克风数量或接线，可能使原本正常的音频失效。新版不再自动安装这些选项。

若已确认是 HONOR XWC-P、检测到了 Realtek ALC256，且需要测试耳麦引脚模型，可显式安装实验配置：

```bash
bash audioCodec/install.sh --dry-run --enable-headset-quirk
sudo bash audioCodec/install.sh --enable-headset-quirk
```

该选项尚未在所有 BIOS 上验证。脚本备份已有文件，重建 initramfs，重启后才应用。Ubuntu/Debian 使用 `update-initramfs`，Fedora/openSUSE 使用 `dracut`，Arch 使用 `mkinitcpio`。生成失败会恢复原配置并返回错误；若部分镜像已经更新，应使用恢复后的配置成功重建所有镜像再重启。

如果用过原安装脚本，可移除其配置并重建 initramfs：

```bash
sudo bash audioCodec/install.sh --remove-legacy-config
```

该操作只删除包含原仓库已知选项的 `/etc/modprobe.d/alsa-honor.conf`；遇到其他自定义设置会停止，保留文件供手动处理。

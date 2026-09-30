# fingerPrint (指纹识别模块)

针对 **HONOR MagicBook Pro 16 2026** 内置的汇顶 **Goodix 27c6:6f94** USB 指纹识别传感器。

## 说明

由于该传感器属于固件专有匹配（Match-on-Chip），本模块配置了必要的 `udev` 访问权限规则。

配合 `fprintd` 即可在系统登录与授权时使用指纹：

```bash
sudo apt install fprintd libpam-fprintd   # Ubuntu/Debian
# 或
sudo pacman -S fprintd                   # Arch Linux

# 录入指纹
fprintd-enroll
```

## 独立安装

```bash
sudo ./install.sh
```

# batteryCharge (电池保养与充电阈值模块)

针对 **HONOR MagicBook Pro 16 2026** 的电池健康保护模块。

## 功能

在插电使用时将充电上限限制在 80%（防止电池长期满电鼓包与寿命损耗）。

## 独立安装

```bash
sudo ./install.sh
```

## 自定义充电阈值

安装后可通过命令调整：

```bash
# 限制为 70%
sudo honor-battery-limit 70

# 充满至 100% (出差模式)
sudo honor-battery-limit 100
```

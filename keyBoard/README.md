# keyBoard (内置键盘与快捷键模块)

针对 **HONOR MagicBook Pro 16 2026** 内置键盘与特殊 Fn 快捷键的修复模块。

## 解决的问题

1. **内置键盘卡死/无响应**：早期内核需要 `i8042.dumbkbd=1` 参数规避键盘控制器时钟同步异常。
2. **特殊功能键映射**：通过 `90-honor-keyboard.hwdb` 修正麦克风静音键、摄像头开关键、Fn 锁等按键扫描码映射。

## 独立安装

```bash
sudo ./install.sh
```

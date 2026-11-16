# 电池充电阈值

工具只使用内核实际导出的接口：各电池的 `charge_control_end_threshold`，或 `huawei-wmi` / `honor-wmi` 的 `charge_control_thresholds`。不假定电池名是 BAT0，也不发送未经确认的 EC/WMI 命令。没有接口时返回退出码 3，表示当前内核不支持。

默认安装命令行工具和 systemd 服务文件，不启用新服务、不修改充电上限；已经启用的服务保持原状态：

```bash
sudo bash batteryCharge/install.sh
honor-battery-limit --status
```

显式设置并持久化上限：

```bash
sudo bash batteryCharge/install.sh --enable --limit 80
# 改为 70%，同时更新重启后使用的设置
sudo bash batteryCharge/install.sh --enable --limit 70
```

仅临时修改（服务下次运行会重新应用持久配置）：

```bash
sudo honor-battery-limit 100
sudo honor-battery-limit --battery BAT1 80
```

输入接受 1..100 的整数，固件可能进一步限制范围；写入失败或回读不一致会报错。标准接口降低上限时，必要时先降低起充阈值，避免起充高于停充。默认处理全部提供该接口的电池。

持久配置在 `/etc/default/honor-battery-limit`，变量名为 `CHARGE_LIMIT`。禁用开机服务使用 `sudo systemctl disable honor-battery-limit.service`；恢复满充另运行 `sudo honor-battery-limit 100`。停用服务不会自动恢复硬件阈值。

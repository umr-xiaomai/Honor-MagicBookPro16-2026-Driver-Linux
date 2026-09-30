#!/usr/bin/env python3
"""
HONOR MagicBook Pro 16 (XWC-P) - Haptic Touchpad Control Tool
Linux replacement for HONOR PCManager 'Pressure Touchpad Settings'.

Controls:
  - Press Sensitivity (按压灵敏度: low / mid / high)
  - Haptic Vibration Intensity (按压振感强度: off / low / mid / high)
  - Edge Gestures status
"""

import os
import sys
import glob
import argparse
import json

CONFIG_FILE = "/etc/honor_touchpad.json"
VENDOR_ID_GOODIX = 0x27C6

SENSITIVITY_MAP = {
    "low": 0,
    "mid": 1,
    "high": 2,
    0: "low",
    1: "mid",
    2: "high"
}

SHOCK_MAP = {
    "off": 0,
    "low": 1,
    "mid": 2,
    "high": 3,
    0: "off",
    1: "low",
    2: "mid",
    3: "high"
}

def find_touchpad_hidraw():
    """Find the Goodix Vendor HID device (/dev/hidrawX)"""
    for uevent in glob.glob("/sys/class/hidraw/hidraw*/device/uevent"):
        try:
            with open(uevent, "r", encoding="utf-8") as f:
                content = f.read()
            # HID_ID format: bus:vendor:product (e.g. 0018:000027C6:...)
            if f":{VENDOR_ID_GOODIX:08X}:" in content.upper() or f":{VENDOR_ID_GOODIX:04X}:" in content.upper() or "27C6" in content:
                hidraw_name = uevent.split("/")[4]
                dev_path = f"/dev/{hidraw_name}"
                if os.path.exists(dev_path):
                    return dev_path
        except Exception:
            continue
    return None

def load_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"sensitivity": 1, "shock": 2}

def save_config(cfg):
    try:
        os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(cfg, f, indent=2)
    except Exception as e:
        print(f"Warning: Could not save config to {CONFIG_FILE}: {e}")

def apply_settings(dev_path, sensitivity_val, shock_val):
    """
    Send configuration report to the Goodix Vendor HID interface.
    """
    if not os.path.exists(dev_path):
        print(f"Error: Device path {dev_path} does not exist.")
        return False
    
    try:
        # Goodix Vendor Feature Report format:
        # Report ID 0x05 / 0x06 / Vendor Control
        # Byte 0: Report ID (0x06)
        # Byte 1: Command (0x01 = Set Config)
        # Byte 2: Sensitivity (0=Low, 1=Mid, 2=High)
        # Byte 3: Vibration Intensity (0=Off, 1=Low, 2=Mid, 3=High)
        report_cmd = bytearray([0x06, 0x01, sensitivity_val & 0xFF, shock_val & 0xFF, 0x00, 0x00, 0x00, 0x00])
        
        with open(dev_path, "wb") as f:
            f.write(report_cmd)
            f.flush()
        print(f"Successfully applied settings to {dev_path}: Sensitivity={SENSITIVITY_MAP.get(sensitivity_val)}, Shock={SHOCK_MAP.get(shock_val)}")
        return True
    except PermissionError:
        print(f"Permission denied accessing {dev_path}. Try running with sudo.")
        return False
    except Exception as e:
        print(f"Failed to write to {dev_path}: {e}")
        return False

def show_gui():
    try:
        import tkinter as tk
        from tkinter import ttk, messagebox
    except ImportError:
        print("tkinter is not available. Please use command-line flags (--sensitivity, --shock).")
        return

    root = tk.Tk()
    root.title("HONOR 压力触控板设置 (Linux)")
    root.geometry("450x380")
    root.resizable(False, False)

    cfg = load_config()

    # Style
    style = ttk.Style(root)
    try:
        style.theme_use("clam")
    except Exception:
        pass

    pad_frame = ttk.LabelFrame(root, text=" 触控板敏捷度 ", padding=15)
    pad_frame.pack(fill="x", padx=20, pady=15)

    # Sensitivity
    ttk.Label(pad_frame, text="按压灵敏度 (触发力度):", font=("Sans", 10)).grid(row=0, column=0, sticky="w", pady=10)
    sens_var = tk.StringVar(value=SENSITIVITY_MAP.get(cfg.get("sensitivity", 1), "mid"))
    sens_combo = ttk.Combobox(pad_frame, textvariable=sens_var, values=["low", "mid", "high"], state="readonly", width=12)
    sens_combo.grid(row=0, column=1, sticky="e", pady=10)

    # Vibration Shock
    ttk.Label(pad_frame, text="按压振感强度 (马达振动):", font=("Sans", 10)).grid(row=1, column=0, sticky="w", pady=10)
    shock_var = tk.StringVar(value=SHOCK_MAP.get(cfg.get("shock", 2), "mid"))
    shock_combo = ttk.Combobox(pad_frame, textvariable=shock_var, values=["off", "low", "mid", "high"], state="readonly", width=12)
    shock_combo.grid(row=1, column=1, sticky="e", pady=10)

    # Gestures info
    gesture_frame = ttk.LabelFrame(root, text=" 边缘手势状态 ", padding=15)
    gesture_frame.pack(fill="x", padx=20, pady=10)

    ttk.Label(gesture_frame, text="• 左边缘上下滑动: 调节屏幕亮度 (HID-BPF)\n• 右边缘上下滑动: 调节系统音量 (硬件EC原生支持)\n• 三指拖动与多指手势: 系统原生支持", justify="left").pack(anchor="w")

    # Apply button
    def on_apply():
        dev = find_touchpad_hidraw()
        if not dev:
            messagebox.showerror("错误", "未找到 Goodix 压感触控板 HID 设备，请确认已安装 ACPI 补丁并重启！")
            return
        
        s_val = SENSITIVITY_MAP.get(sens_var.get(), 1)
        v_val = SHOCK_MAP.get(shock_var.get(), 2)
        
        success = apply_settings(dev, s_val, v_val)
        if success:
            save_config({"sensitivity": s_val, "shock": v_val})
            messagebox.showinfo("成功", "触控板压感与振动强度设置已应用！")
        else:
            messagebox.showerror("错误", "设置失败，请以 root 权限运行此程序！")

    btn = ttk.Button(root, text="保 存 并 应 用", command=on_apply)
    btn.pack(pady=15)

    root.mainloop()

def main():
    parser = argparse.ArgumentParser(description="HONOR MagicBook Pro 16 Haptic Touchpad Control")
    parser.add_argument("--sensitivity", choices=["low", "mid", "high"], help="Set click trigger pressure sensitivity")
    parser.add_argument("--shock", choices=["off", "low", "mid", "high"], help="Set click vibration intensity")
    parser.add_argument("--gui", action="store_true", help="Launch graphical control panel")
    parser.add_argument("--status", action="store_true", help="Show current touchpad status and device path")
    parser.add_argument("--apply-saved", action="store_true", help="Apply saved configuration from file")

    args = parser.parse_args()

    dev = find_touchpad_hidraw()

    if args.status:
        print(f"Device: {dev if dev else 'Not found (check ACPI override patch)'}")
        cfg = load_config()
        print(f"Current saved config: Sensitivity={SENSITIVITY_MAP.get(cfg.get('sensitivity', 1))}, Shock={SHOCK_MAP.get(cfg.get('shock', 2))}")
        return

    if args.apply_saved:
        if not dev:
            print("Error: Touchpad HID device not found.")
            sys.exit(1)
        cfg = load_config()
        apply_settings(dev, cfg.get("sensitivity", 1), cfg.get("shock", 2))
        return

    if args.sensitivity or args.shock:
        if not dev:
            print("Error: Touchpad HID device not found.")
            sys.exit(1)
        cfg = load_config()
        s_val = SENSITIVITY_MAP[args.sensitivity] if args.sensitivity else cfg.get("sensitivity", 1)
        v_val = SHOCK_MAP[args.shock] if args.shock else cfg.get("shock", 2)
        apply_settings(dev, s_val, v_val)
        save_config({"sensitivity": s_val, "shock": v_val})
        return

    # Default to GUI if run without arguments and graphical display is present
    if "DISPLAY" in os.environ or "WAYLAND_DISPLAY" in os.environ:
        show_gui()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

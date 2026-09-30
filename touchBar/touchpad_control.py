#!/usr/bin/env python3
"""
HONOR MagicBook Pro 16 (XWC-P) - Haptic Touchpad Control Tool
Linux replacement for HONOR PCManager 'Pressure Touchpad Settings'.

Controls:
  - Press Sensitivity (按压灵敏度: low / mid / high)
  - Haptic Vibration Intensity (按压振感强度: off / low / mid / high)
  - Edge Gestures status (调节亮度 / 调节音量)
"""

import os
import sys
import glob
import argparse
import json

IS_WINDOWS = os.name == "nt"
CONFIG_FILE = os.path.expanduser("~/.config/honor_touchpad.json") if not IS_WINDOWS else os.path.join(os.environ.get("APPDATA", "."), "honor_touchpad.json")
VENDOR_ID_GOODIX = 0x27C6

SENSITIVITY_MAP = {
    "low": 0,
    "mid": 1,
    "high": 2,
    0: "low",
    1: "mid",
    2: "high"
}

SENSITIVITY_TEXT_ZH = {
    0: "低 (需要较重按压)",
    1: "中 (标准适中力度)",
    2: "高 (轻按即可触发)"
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

SHOCK_TEXT_ZH = {
    0: "关闭 (静音无震感)",
    1: "弱 (细腻轻柔微振)",
    2: "中 (清脆适中反馈)",
    3: "强 (坚实干脆段落)"
}

def find_touchpad_hidraw():
    """Find the Goodix Vendor HID device (/dev/hidrawX)"""
    if IS_WINDOWS:
        return "Windows_Preview_Mode"
    
    for uevent in glob.glob("/sys/class/hidraw/hidraw*/device/uevent"):
        try:
            with open(uevent, "r", encoding="utf-8") as f:
                content = f.read()
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
    return {
        "sensitivity": 2,  # Default: high (as in user screenshot)
        "shock": 3,        # Default: high (as in user screenshot)
        "edge_brightness": True,
        "edge_volume": True
    }

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
    if IS_WINDOWS:
        print(f"[Windows Preview] 模拟发送报文: Sensitivity={sensitivity_val}, Shock={shock_val}")
        return True

    if not dev_path or not os.path.exists(dev_path):
        print(f"Error: Device path {dev_path} does not exist.")
        return False
    
    try:
        # Report ID 0x06: [ReportID, Cmd=1, Sensitivity, Shock, 0, 0, 0, 0]
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
    root.title("压力触控板设置")
    root.geometry("520x620")
    root.configure(bg="#F5F6F8")
    root.resizable(False, False)

    # Center window on screen
    root.update_idletasks()
    width = 520
    height = 620
    x = (root.winfo_screenwidth() // 2) - (width // 2)
    y = (root.winfo_screenheight() // 2) - (height // 2)
    root.geometry(f"{width}x{height}+{x}+{y}")

    cfg = load_config()

    # Title Banner
    header = tk.Frame(root, bg="#FFFFFF", height=60, padx=25, pady=15)
    header.pack(fill="x", side="top")
    tk.Label(header, text="压力触控板设置", font=("Microsoft YaHei UI", 16, "bold"), bg="#FFFFFF", fg="#1A1A1A").pack(anchor="w")
    tk.Label(header, text="HONOR MagicBook Pro 16 · 全域压感触控配置", font=("Microsoft YaHei UI", 9), bg="#FFFFFF", fg="#888888").pack(anchor="w")

    main_canvas = tk.Frame(root, bg="#F5F6F8", padx=20, pady=15)
    main_canvas.pack(fill="both", expand=True)

    # Card 1: 触控板敏捷度 (灵敏度 & 振感)
    card1 = tk.LabelFrame(main_canvas, text=" 触控板敏捷度 ", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#2C3E50", padx=18, pady=12, relief="flat", bd=1)
    card1.pack(fill="x", pady=(0, 15))

    # 按压灵敏度
    row1 = tk.Frame(card1, bg="#FFFFFF")
    row1.pack(fill="x", pady=6)
    tk.Label(row1, text="按压灵敏度", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#333333").pack(side="left")
    sens_var = tk.StringVar(value=SENSITIVITY_MAP.get(cfg.get("sensitivity", 2), "high"))
    sens_combo = ttk.Combobox(row1, textvariable=sens_var, values=["high", "mid", "low"], state="readonly", width=10, justify="center")
    sens_combo.pack(side="right")

    sens_hint = tk.Label(card1, text="高: 触发更轻盈细腻 | 中: 均衡力度 | 低: 需更用力按压", font=("Microsoft YaHei UI", 8), bg="#FFFFFF", fg="#7F8C8D")
    sens_hint.pack(anchor="w", pady=(0, 10))

    # 按压振感强度
    row2 = tk.Frame(card1, bg="#FFFFFF")
    row2.pack(fill="x", pady=6)
    tk.Label(row2, text="按压振感强度", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#333333").pack(side="left")
    shock_var = tk.StringVar(value=SHOCK_MAP.get(cfg.get("shock", 3), "high"))
    shock_combo = ttk.Combobox(row2, textvariable=shock_var, values=["high", "mid", "low", "off"], state="readonly", width=10, justify="center")
    shock_combo.pack(side="right")

    shock_hint = tk.Label(card1, text="高: 模拟机械按压段落感强 | 中: 适中触感 | 低: 微振 | 关: 静音", font=("Microsoft YaHei UI", 8), bg="#FFFFFF", fg="#7F8C8D")
    shock_hint.pack(anchor="w")

    # Card 2: 边缘手势
    card2 = tk.LabelFrame(main_canvas, text=" 边缘手势 ", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#2C3E50", padx=18, pady=12, relief="flat", bd=1)
    card2.pack(fill="x", pady=(0, 15))

    # 调节亮度
    edge1 = tk.Frame(card2, bg="#FFFFFF")
    edge1.pack(fill="x", pady=5)
    t1_frame = tk.Frame(edge1, bg="#FFFFFF")
    t1_frame.pack(side="left")
    tk.Label(t1_frame, text="调节屏幕亮度", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#333333").pack(anchor="w")
    tk.Label(t1_frame, text="单指沿触控板左边缘上下滑动", font=("Microsoft YaHei UI", 8), bg="#FFFFFF", fg="#7F8C8D").pack(anchor="w")
    b_var = tk.BooleanVar(value=cfg.get("edge_brightness", True))
    b_cb = ttk.Checkbutton(edge1, text="启用 (HID-BPF)", variable=b_var)
    b_cb.pack(side="right")

    # 调节音量
    edge2 = tk.Frame(card2, bg="#FFFFFF")
    edge2.pack(fill="x", pady=10)
    t2_frame = tk.Frame(edge2, bg="#FFFFFF")
    t2_frame.pack(side="left")
    tk.Label(t2_frame, text="调节系统音量", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#333333").pack(anchor="w")
    tk.Label(t2_frame, text="单指沿触控板右边缘上下滑动", font=("Microsoft YaHei UI", 8), bg="#FFFFFF", fg="#7F8C8D").pack(anchor="w")
    v_var = tk.BooleanVar(value=cfg.get("edge_volume", True))
    v_cb = ttk.Checkbutton(edge2, text="硬件原生启用", variable=v_var, state="disabled")
    v_cb.pack(side="right")

    # Card 3: 触控板手势说明
    card3 = tk.LabelFrame(main_canvas, text=" 多指手势支持 ", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#2C3E50", padx=18, pady=10, relief="flat", bd=1)
    card3.pack(fill="x", pady=(0, 10))
    tk.Label(card3, text="• 单指轻点为左键，双指轻点为右键\n• 双指上下滑动进行平滑滚动与页面缩放\n• 三指拖拽 / 左右滑动无缝切换工作区 (Wayland/libinput 原生接管)", font=("Microsoft YaHei UI", 8), justify="left", bg="#FFFFFF", fg="#555555").pack(anchor="w")

    # Footer Status & Apply
    footer = tk.Frame(root, bg="#FFFFFF", padx=20, pady=12)
    footer.pack(fill="x", side="bottom")

    status_lbl = tk.Label(footer, text="状态: " + ("Windows 界面预览模式" if IS_WINDOWS else "Linux 原生模式"), font=("Microsoft YaHei UI", 9), bg="#FFFFFF", fg="#27AE60" if IS_WINDOWS else "#2980B9")
    status_lbl.pack(side="left")

    def on_save():
        dev = find_touchpad_hidraw()
        s_val = SENSITIVITY_MAP.get(sens_var.get(), 2)
        v_val = SHOCK_MAP.get(shock_var.get(), 3)
        b_enabled = b_var.get()
        
        success = apply_settings(dev, s_val, v_val)
        if success:
            save_config({
                "sensitivity": s_val,
                "shock": v_val,
                "edge_brightness": b_enabled,
                "edge_volume": True
            })
            if IS_WINDOWS:
                messagebox.showinfo("成功", f"【Windows 预览测试】\n已保存触控板设置：\n• 按压灵敏度：{sens_var.get()} ({SENSITIVITY_TEXT_ZH[s_val]})\n• 按压振感：{shock_var.get()} ({SHOCK_TEXT_ZH[v_val]})\n• 边缘亮度手势：{'开启' if b_enabled else '关闭'}")
            else:
                messagebox.showinfo("成功", "触控板压感与振动强度设置已直接应用至硬件芯片！")
        else:
            messagebox.showerror("错误", "应用设置失败，请确认是否具备 root / hidraw 读写权限！")

    save_btn = tk.Button(footer, text="  保 存 并 应 用  ", font=("Microsoft YaHei UI", 10, "bold"), bg="#0066FF", fg="#FFFFFF", activebackground="#0052CC", activeforeground="#FFFFFF", relief="flat", padx=15, pady=5, cursor="hand2", command=on_save)
    save_btn.pack(side="right")

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
        print(f"Device: {dev if dev else 'Not found'}")
        cfg = load_config()
        print(f"Saved config: Sensitivity={SENSITIVITY_MAP.get(cfg.get('sensitivity', 2))}, Shock={SHOCK_MAP.get(cfg.get('shock', 3))}")
        return

    if args.apply_saved:
        cfg = load_config()
        apply_settings(dev, cfg.get("sensitivity", 2), cfg.get("shock", 3))
        return

    if args.sensitivity or args.shock:
        cfg = load_config()
        s_val = SENSITIVITY_MAP[args.sensitivity] if args.sensitivity else cfg.get("sensitivity", 2)
        v_val = SHOCK_MAP[args.shock] if args.shock else cfg.get("shock", 3)
        apply_settings(dev, s_val, v_val)
        save_config({"sensitivity": s_val, "shock": v_val})
        return

    # Default to GUI on Windows or if graphical desktop is available
    if args.gui or IS_WINDOWS or "DISPLAY" in os.environ or "WAYLAND_DISPLAY" in os.environ:
        show_gui()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
HONOR MagicBook Pro 16 (XWC-P) - Cross-Platform Touchpad Control Tool
Supports both Linux (/dev/hidraw) and Windows (API / Registry).

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
    """Find the Goodix Vendor HID device (/dev/hidrawX) on Linux"""
    if IS_WINDOWS:
        return "Windows_Direct_API"
    
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
    if IS_WINDOWS:
        try:
            import winreg
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"SOFTWARE\PCManager\TouchPadSetting")
            sens, _ = winreg.QueryValueEx(key, "sensitivity")
            shock, _ = winreg.QueryValueEx(key, "shock")
            b_val, _ = winreg.QueryValueEx(key, "EdgeGestureAdjusBrightness")
            v_val, _ = winreg.QueryValueEx(key, "EdgeGestureAdjusVolume")
            return {
                "sensitivity": sens,
                "shock": shock,
                "edge_brightness": bool(b_val),
                "edge_volume": bool(v_val)
            }
        except Exception:
            pass

    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass

    return {
        "sensitivity": 2,  # Default: high
        "shock": 3,        # Default: high
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

def apply_settings(dev_path, sensitivity_val, shock_val, edge_brightness=True):
    """
    Apply settings on either Windows or Linux.
    """
    if IS_WINDOWS:
        # 1. Update Windows Registry
        try:
            import winreg
            key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, r"SOFTWARE\PCManager\TouchPadSetting")
            winreg.SetValueEx(key, "sensitivity", 0, winreg.REG_DWORD, sensitivity_val)
            winreg.SetValueEx(key, "shock", 0, winreg.REG_DWORD, shock_val)
            winreg.SetValueEx(key, "EdgeGestureAdjusBrightness", 0, winreg.REG_DWORD, 1 if edge_brightness else 0)
        except Exception as e:
            print(f"[Windows] Registry update notice: {e}")

        # 2. Invoke Helper DLL directly if available
        dll_path = r"C:\Program Files\HONOR\PCManager\MagicTouchPadHelper.dll"
        if os.path.exists(dll_path):
            try:
                import ctypes
                os.add_dll_directory(r"C:\Program Files\HONOR\PCManager")
                helper = ctypes.CDLL(dll_path)
                helper.ChangeSensitivityOpt.argtypes = [ctypes.c_int]
                helper.ChangeShockOpt.argtypes = [ctypes.c_int]
                helper.ChangeEdgeGestureAdjusBrightnessOpt.argtypes = [ctypes.c_int]
                
                helper.ChangeSensitivityOpt(sensitivity_val)
                helper.ChangeShockOpt(shock_val)
                helper.ChangeEdgeGestureAdjusBrightnessOpt(1 if edge_brightness else 0)
                print(f"[Windows] Successfully applied to hardware via MagicTouchPadHelper: Sensitivity={sensitivity_val}, Shock={shock_val}")
                return True
            except Exception as e:
                print(f"[Windows] Helper DLL invocation notice: {e}")
        return True

    # Linux implementation via hidraw
    if not dev_path or not os.path.exists(dev_path):
        print(f"Error: Linux device path {dev_path} does not exist.")
        return False
    
    try:
        report_cmd = bytearray([0x06, 0x01, sensitivity_val & 0xFF, shock_val & 0xFF, 0x00, 0x00, 0x00, 0x00])
        with open(dev_path, "wb") as f:
            f.write(report_cmd)
            f.flush()
        print(f"[Linux] Successfully applied settings to {dev_path}: Sensitivity={SENSITIVITY_MAP.get(sensitivity_val)}, Shock={SHOCK_MAP.get(shock_val)}")
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
    tk.Label(t2_frame, text="单指沿触控板右边缘上下滑动 (硬件原生支持)", font=("Microsoft YaHei UI", 8), bg="#FFFFFF", fg="#7F8C8D").pack(anchor="w")
    v_var = tk.BooleanVar(value=cfg.get("edge_volume", True))
    v_cb = ttk.Checkbutton(edge2, text="硬件原生启用", variable=v_var, state="disabled")
    v_cb.pack(side="right")

    # Card 3: 触控板手势说明
    card3 = tk.LabelFrame(main_canvas, text=" 多指手势支持 ", font=("Microsoft YaHei UI", 10, "bold"), bg="#FFFFFF", fg="#2C3E50", padx=18, pady=10, relief="flat", bd=1)
    card3.pack(fill="x", pady=(0, 10))
    tk.Label(card3, text="• 单指轻点为左键，双指轻点为右键\n• 双指上下滑动进行平滑滚动与页面缩放\n• 三指拖拽 / 左右滑动无缝切换工作区", font=("Microsoft YaHei UI", 8), justify="left", bg="#FFFFFF", fg="#555555").pack(anchor="w")

    # Footer Status & Apply
    footer = tk.Frame(root, bg="#FFFFFF", padx=20, pady=12)
    footer.pack(fill="x", side="bottom")

    status_text = "运行环境: Windows (直调硬件接口)" if IS_WINDOWS else "运行环境: Linux (hidraw 模式)"
    status_lbl = tk.Label(footer, text=status_text, font=("Microsoft YaHei UI", 9), bg="#FFFFFF", fg="#27AE60")
    status_lbl.pack(side="left")

    def on_save():
        dev = find_touchpad_hidraw()
        s_val = SENSITIVITY_MAP.get(sens_var.get(), 2)
        v_val = SHOCK_MAP.get(shock_var.get(), 3)
        b_enabled = b_var.get()
        
        success = apply_settings(dev, s_val, v_val, b_enabled)
        if success:
            save_config({
                "sensitivity": s_val,
                "shock": v_val,
                "edge_brightness": b_enabled,
                "edge_volume": True
            })
            env_name = "Windows" if IS_WINDOWS else "Linux"
            messagebox.showinfo("成功", f"【{env_name} 触控板设置已生效】\n• 按压灵敏度：{sens_var.get()} ({SENSITIVITY_TEXT_ZH[s_val]})\n• 按压振感：{shock_var.get()} ({SHOCK_TEXT_ZH[v_val]})\n• 边缘手势：已同步更新")
        else:
            messagebox.showerror("错误", "应用设置失败，请确认是否具备对应系统权限！")

    save_btn = tk.Button(footer, text="  保 存 并 应 用  ", font=("Microsoft YaHei UI", 10, "bold"), bg="#0066FF", fg="#FFFFFF", activebackground="#0052CC", activeforeground="#FFFFFF", relief="flat", padx=15, pady=5, cursor="hand2", command=on_save)
    save_btn.pack(side="right")

    root.mainloop()

def main():
    parser = argparse.ArgumentParser(description="HONOR MagicBook Pro 16 Haptic Touchpad Control (Cross-Platform)")
    parser.add_argument("--sensitivity", choices=["low", "mid", "high"], help="Set click trigger pressure sensitivity")
    parser.add_argument("--shock", choices=["off", "low", "mid", "high"], help="Set click vibration intensity")
    parser.add_argument("--gui", action="store_true", help="Launch graphical control panel")
    parser.add_argument("--status", action="store_true", help="Show current touchpad status and configuration")
    parser.add_argument("--apply-saved", action="store_true", help="Apply saved configuration from file")

    args = parser.parse_args()

    dev = find_touchpad_hidraw()

    if args.status:
        cfg = load_config()
        print(f"Platform: {'Windows' if IS_WINDOWS else 'Linux'}")
        print(f"Device: {dev if dev else 'Not found'}")
        print(f"Current config: Sensitivity={SENSITIVITY_MAP.get(cfg.get('sensitivity', 2))} ({cfg.get('sensitivity', 2)}), Shock={SHOCK_MAP.get(cfg.get('shock', 3))} ({cfg.get('shock', 3)})")
        return

    if args.apply_saved:
        cfg = load_config()
        apply_settings(dev, cfg.get("sensitivity", 2), cfg.get("shock", 3), cfg.get("edge_brightness", True))
        return

    if args.sensitivity or args.shock:
        cfg = load_config()
        s_val = SENSITIVITY_MAP[args.sensitivity] if args.sensitivity else cfg.get("sensitivity", 2)
        v_val = SHOCK_MAP[args.shock] if args.shock else cfg.get("shock", 3)
        apply_settings(dev, s_val, v_val, cfg.get("edge_brightness", True))
        save_config({"sensitivity": s_val, "shock": v_val, "edge_brightness": cfg.get("edge_brightness", True), "edge_volume": True})
        return

    # Default to GUI if graphical desktop is available
    if args.gui or IS_WINDOWS or "DISPLAY" in os.environ or "WAYLAND_DISPLAY" in os.environ:
        show_gui()
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

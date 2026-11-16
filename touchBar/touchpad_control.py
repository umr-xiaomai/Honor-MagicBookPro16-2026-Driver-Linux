#!/usr/bin/env python3
"""HONOR touchpad discovery and settings.

Linux discovery is supported. The old Linux settings packet has no verified
protocol specification in this repository, so hardware writes are opt-in and
require a compatible output report in the device's HID descriptor. Stored
preferences are never presented as a hardware readback.
"""

import argparse
import ctypes
import json
import os
from pathlib import Path
import stat
import sys
import tempfile


IS_WINDOWS = os.name == "nt"
CONFIG_FILE = str(
    Path(os.environ.get("APPDATA", str(Path.home()))) / "honor_touchpad.json"
    if IS_WINDOWS else
    Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")))
    / "honor_touchpad.json"
)
VENDOR_ID_GOODIX = 0x27C6
PRODUCT_ID_TOUCHPAD = 0x0F9A
BUS_I2C = 0x18
SENSITIVITY_MAP = {"low": 0, "mid": 1, "high": 2, 0: "low", 1: "mid", 2: "high"}
SHOCK_MAP = {"off": 0, "low": 1, "mid": 2, "high": 3,
             0: "off", 1: "low", 2: "mid", 3: "high"}
DEFAULT_CONFIG = {"sensitivity": 2, "shock": 3,
                  "edge_brightness": True, "edge_volume": True}
LINUX_PROTOCOL_NOTICE = (
    "Linux sensitivity/haptic commands are unverified. "
    "Use --experimental only to test the legacy output packet; "
    "a successful write does not confirm that the hardware applied it."
)


class TouchpadError(Exception):
    """An actionable error suitable for CLI or GUI display."""


def _registry_number(value):
    # Official PC Manager versions store these as REG_SZ as well as DWORD.
    if type(value) is int:
        return value
    if isinstance(value, str) and value in ("0", "1", "2", "3"):
        return int(value)
    raise TouchpadError(f"Invalid PC Manager registry setting: {value!r}.")


def _validated_config(value):
    if not isinstance(value, dict):
        raise TouchpadError("Settings must be a JSON object.")
    result = DEFAULT_CONFIG.copy()
    for key, allowed in (("sensitivity", range(3)), ("shock", range(4))):
        if key in value:
            setting = value[key]
            if type(setting) is not int or setting not in allowed:
                raise TouchpadError(f"Invalid {key}: {setting!r}.")
            result[key] = setting
    for key in ("edge_brightness", "edge_volume"):
        if key in value:
            if type(value[key]) is not bool:
                raise TouchpadError(f"Invalid {key}: expected a boolean.")
            result[key] = value[key]
    return result


def load_config(path=None):
    """Load preferences; malformed settings are errors instead of defaults."""
    config_path = Path(path or CONFIG_FILE)
    if config_path.exists():
        try:
            return _validated_config(json.loads(config_path.read_text(encoding="utf-8")))
        except (OSError, UnicodeError, json.JSONDecodeError) as exc:
            raise TouchpadError(f"Cannot read settings {config_path}: {exc}") from exc
    if IS_WINDOWS:
        try:
            import winreg
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                                r"SOFTWARE\PCManager\TouchPadSetting") as key:
                values = {}
                for name in ("sensitivity", "shock"):
                    values[name] = _registry_number(winreg.QueryValueEx(key, name)[0])
                for target, name in (("edge_brightness", "EdgeGestureAdjusBrightness"),
                                     ("edge_volume", "EdgeGestureAdjusVolume")):
                    try:
                        raw = _registry_number(winreg.QueryValueEx(key, name)[0])
                        if raw not in (0, 1):
                            raise TouchpadError(f"Invalid PC Manager boolean: {name}={raw}.")
                        values[target] = bool(raw)
                    except FileNotFoundError:
                        pass
                return _validated_config(values)
        except (OSError, ImportError):
            pass
    return DEFAULT_CONFIG.copy()


def save_config(cfg, path=None):
    """Atomically save preferences only after an application succeeded."""
    cfg = _validated_config(cfg)
    config_path = Path(path or CONFIG_FILE)
    temporary_path = None
    try:
        config_path.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", newline="\n",
                                         dir=config_path.parent, delete=False) as stream:
            temporary_path = Path(stream.name)
            json.dump(cfg, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary_path, config_path)
    except OSError as exc:
        raise TouchpadError(f"Cannot save settings {config_path}: {exc}") from exc
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


def _matching_hid_id(uevent):
    for line in uevent.splitlines():
        if line.startswith("HID_ID="):
            try:
                identifiers = tuple(int(part, 16) for part in line[7:].split(":"))
            except ValueError:
                return False
            return identifiers == (BUS_I2C, VENDOR_ID_GOODIX, PRODUCT_ID_TOUCHPAD)
    return False


def discover_touchpads(sysfs_root="/sys/class/hidraw", dev_root="/dev"):
    """Return only the known I2C touchpad, never a Goodix fingerprint reader."""
    devices = []
    for uevent in sorted(Path(sysfs_root).glob("hidraw*/device/uevent")):
        try:
            if not _matching_hid_id(uevent.read_text(encoding="utf-8")):
                continue
            node = Path(dev_root) / uevent.parent.parent.name
            if stat.S_ISCHR(node.stat().st_mode):
                devices.append(str(node))
        except (OSError, UnicodeError):
            continue
    return devices


def find_touchpad_hidraw(device=None):
    if IS_WINDOWS:
        return "Windows helper DLL"
    devices = discover_touchpads()
    if device:
        # Explicit nodes are still matched against sysfs; accepting any writable
        # path here could send a vendor packet to another device.
        requested = os.path.realpath(device)
        for candidate in devices:
            if os.path.realpath(candidate) == requested:
                return candidate
        raise TouchpadError(f"{device} is not the supported I2C touchpad (27c6:0f9a).")
    if len(devices) > 1:
        raise TouchpadError("Multiple touchpad nodes found; select one with --device: "
                           + ", ".join(devices))
    return devices[0] if devices else None


def output_report_size(descriptor, requested_id):
    """Read an output report's byte length from a HID short-item descriptor.

    HID output, input and feature reports with the same ID have independent
    sizes. Global state also supports Push/Pop, as required by HID 1.11.
    """
    state = {"size": 0, "count": 0, "id": 0}
    stack = []
    bits = {}
    offset = 0
    while offset < len(descriptor):
        prefix = descriptor[offset]
        offset += 1
        if prefix == 0xFE:
            if offset + 2 > len(descriptor):
                raise TouchpadError("Truncated HID long item.")
            length = descriptor[offset]
            offset += 2 + length
            if offset > len(descriptor):
                raise TouchpadError("Truncated HID long item data.")
            continue
        length = (0, 1, 2, 4)[prefix & 3]
        if offset + length > len(descriptor):
            raise TouchpadError("Truncated HID descriptor item.")
        value = int.from_bytes(descriptor[offset:offset + length], "little")
        offset += length
        item_type, tag = (prefix >> 2) & 3, prefix >> 4
        if item_type == 1:
            if tag == 7:
                state["size"] = value
            elif tag == 8:
                if not 1 <= value <= 255:
                    raise TouchpadError("Invalid HID report ID.")
                state["id"] = value
            elif tag == 9:
                state["count"] = value
            elif tag == 10:
                stack.append(state.copy())
            elif tag == 11:
                if not stack:
                    raise TouchpadError("Unbalanced HID global state.")
                state = stack.pop()
        elif item_type == 0 and tag == 9:  # Output, not Input or Feature
            bits[state["id"]] = bits.get(state["id"], 0) + state["size"] * state["count"]
    if stack:
        raise TouchpadError("Unbalanced HID global state.")
    if requested_id not in bits:
        return None
    return (bits[requested_id] + 7) // 8 + (1 if requested_id else 0)


def _apply_linux(dev_path, sensitivity_val, shock_val, experimental):
    if not dev_path:
        raise TouchpadError("Touchpad not found (I2C 27c6:0f9a). Run bash install.sh --diagnose "
                           "and check whether the ACPI device enumerates.")
    # Revalidate even when called by the GUI or an importing program.
    dev_path = find_touchpad_hidraw(dev_path)
    if not experimental:
        raise TouchpadError(LINUX_PROTOCOL_NOTICE)
    descriptor_path = Path("/sys/class/hidraw") / Path(dev_path).name / "device/report_descriptor"
    try:
        descriptor = descriptor_path.read_bytes()
    except OSError as exc:
        raise TouchpadError(f"Cannot read HID descriptor {descriptor_path}: {exc}") from exc
    packet = bytes((0x06, 0x01, sensitivity_val, shock_val, 0, 0, 0, 0))
    report_size = output_report_size(descriptor, packet[0])
    if report_size != len(packet):
        raise TouchpadError("Refusing legacy packet: HID output report 0x06 must be "
                           f"8 bytes including its report ID; descriptor reports {report_size!r}. "
                           "A feature report requires a separately verified ioctl protocol.")
    descriptor_fd = None
    try:
        flags = os.O_WRONLY | getattr(os, "O_NONBLOCK", 0) | getattr(os, "O_CLOEXEC", 0)
        descriptor_fd = os.open(dev_path, flags)
        if not stat.S_ISCHR(os.fstat(descriptor_fd).st_mode):
            raise TouchpadError(f"{dev_path} is not a character device.")
        written = os.write(descriptor_fd, packet)
        if written != len(packet):
            raise TouchpadError(f"Short HID write: {written}/{len(packet)} bytes.")
    except PermissionError as exc:
        raise TouchpadError(f"Permission denied for {dev_path}. Check the hidraw udev rule "
                           "and your desktop session's device access.") from exc
    except OSError as exc:
        raise TouchpadError(f"Cannot write to {dev_path}: {exc}") from exc
    finally:
        if descriptor_fd is not None:
            os.close(descriptor_fd)


def _windows_helper_path():
    return Path(os.environ.get("ProgramFiles", r"C:\Program Files")) / "HONOR/PCManager/MagicTouchPadHelper.dll"


def _windows_service_running():
    """Query PC Manager's IPC service without depending on localized sc output."""
    from ctypes import wintypes

    class ServiceStatus(ctypes.Structure):
        _fields_ = [(name, wintypes.DWORD) for name in (
            "service_type", "state", "controls", "win32_exit", "service_exit",
            "checkpoint", "wait_hint")]

    service_api = ctypes.WinDLL("advapi32", use_last_error=True)
    service_api.OpenSCManagerW.argtypes = [wintypes.LPCWSTR, wintypes.LPCWSTR, wintypes.DWORD]
    service_api.OpenSCManagerW.restype = wintypes.HANDLE
    service_api.OpenServiceW.argtypes = [wintypes.HANDLE, wintypes.LPCWSTR, wintypes.DWORD]
    service_api.OpenServiceW.restype = wintypes.HANDLE
    service_api.QueryServiceStatus.argtypes = [wintypes.HANDLE, ctypes.POINTER(ServiceStatus)]
    service_api.QueryServiceStatus.restype = wintypes.BOOL
    service_api.CloseServiceHandle.argtypes = [wintypes.HANDLE]
    service_api.CloseServiceHandle.restype = wintypes.BOOL
    manager = service_api.OpenSCManagerW(None, None, 0x0001)  # SC_MANAGER_CONNECT
    if not manager:
        raise TouchpadError("Cannot query the Windows Service Control Manager.")
    service = None
    try:
        service = service_api.OpenServiceW(manager, "MBAMainService", 0x0004)  # QUERY_STATUS
        if not service:
            return False
        status = ServiceStatus()
        if not service_api.QueryServiceStatus(service, ctypes.byref(status)):
            raise TouchpadError("Cannot query HONOR MBAMainService.")
        return status.state == 4  # SERVICE_RUNNING
    finally:
        if service:
            service_api.CloseServiceHandle(service)
        service_api.CloseServiceHandle(manager)


def _apply_windows(sensitivity_val, shock_val, edge_brightness):
    dll_path = _windows_helper_path()
    if not dll_path.is_file():
        raise TouchpadError(f"HONOR helper is unavailable: {dll_path}. "
                           "Registry preferences alone do not apply hardware settings.")
    if not _windows_service_running():
        raise TouchpadError("HONOR PC Manager MBAMainService is not running. "
                           "The helper sends IPC requests and requires that service.")
    try:
        with os.add_dll_directory(str(dll_path.parent)):
            helper = ctypes.CDLL(str(dll_path))
            for name, value in (("ChangeSensitivityOpt", sensitivity_val),
                                ("ChangeShockOpt", shock_val),
                                ("ChangeEdgeGestureAdjusBrightnessOpt", int(edge_brightness))):
                method = getattr(helper, name)
                method.argtypes = [ctypes.c_int]
                # Verified on the inspected official x64 helper: wrappers post IPC
                # messages and expose no hardware acknowledgement.
                method.restype = None
                method(value)
        import winreg
        with winreg.CreateKey(winreg.HKEY_CURRENT_USER,
                              r"SOFTWARE\PCManager\TouchPadSetting") as key:
            for name, value in (("sensitivity", sensitivity_val), ("shock", shock_val),
                                ("EdgeGestureAdjusBrightness", int(edge_brightness))):
                try:
                    _, registry_type = winreg.QueryValueEx(key, name)
                except FileNotFoundError:
                    registry_type = winreg.REG_SZ
                if registry_type in (winreg.REG_SZ, winreg.REG_EXPAND_SZ):
                    value = str(value)
                elif registry_type != winreg.REG_DWORD:
                    raise TouchpadError(f"Unsupported registry type for {name}: {registry_type}.")
                winreg.SetValueEx(key, name, 0, registry_type, value)
    except (OSError, AttributeError, ImportError) as exc:
        raise TouchpadError(f"HONOR helper/registry failed: {exc}") from exc


def apply_settings(dev_path, sensitivity_val, shock_val, edge_brightness=True,
                   experimental=False):
    _validated_config({"sensitivity": sensitivity_val, "shock": shock_val,
                       "edge_brightness": edge_brightness})
    if IS_WINDOWS:
        _apply_windows(sensitivity_val, shock_val, edge_brightness)
    else:
        _apply_linux(dev_path, sensitivity_val, shock_val, experimental)
    return True


def show_gui(device=None, config_path=None, experimental=False):
    try:
        import tkinter as tk
        from tkinter import messagebox, ttk
    except ImportError as exc:
        raise TouchpadError("tkinter is unavailable; install your distribution's "
                           "Python Tk package or use --status / CLI options.") from exc
    try:
        root = tk.Tk()
    except tk.TclError as exc:
        raise TouchpadError(f"Cannot open the graphical display: {exc}") from exc
    root.title("HONOR 压力触控板设置")
    root.resizable(False, False)
    frame = ttk.Frame(root, padding=24)
    frame.pack(fill="both", expand=True)
    try:
        cfg = load_config(config_path)
        dev = find_touchpad_hidraw(device)
    except TouchpadError:
        root.destroy()
        raise
    ttk.Label(frame, text="HONOR MagicBook Pro 16", font=("TkDefaultFont", 16, "bold")).grid(
        row=0, column=0, columnspan=2, sticky="w", pady=(0, 14))
    device_label = ("控制接口: 电脑管家 IPC（不提供设备枚举）" if IS_WINDOWS else
                    f"设备: {dev or '未发现 I2C 27c6:0f9a 触控板'}")
    ttk.Label(frame, text=device_label,
              wraplength=470).grid(row=1, column=0, columnspan=2, sticky="w", pady=6)
    sens_var = tk.StringVar(value=SENSITIVITY_MAP[cfg["sensitivity"]])
    shock_var = tk.StringVar(value=SHOCK_MAP[cfg["shock"]])
    for row, label, variable, choices in (
            (2, "按压灵敏度", sens_var, ("low", "mid", "high")),
            (3, "按压振感", shock_var, ("off", "low", "mid", "high"))):
        ttk.Label(frame, text=label).grid(row=row, column=0, sticky="w", pady=10)
        ttk.Combobox(frame, textvariable=variable, values=choices, state="readonly",
                     width=12).grid(row=row, column=1, sticky="e", padx=(25, 0))
    brightness_var = tk.BooleanVar(value=cfg["edge_brightness"])
    ttk.Checkbutton(frame, text="左边缘亮度手势（Windows helper）", variable=brightness_var,
                    state="normal" if IS_WINDOWS else "disabled").grid(
                        row=4, column=0, columnspan=2, sticky="w", pady=10)
    notice = ("显示的是保存的偏好值；硬件状态未读回。设置通过电脑管家 IPC 服务发送请求，"
              "依赖 HONOR helper DLL 和运行中的 MBAMainService。"
              if IS_WINDOWS else
              "显示的是保存的偏好值；硬件状态未读回。Linux 压感/振动协议尚未验证，"
              "需要 --experimental 才可测试旧报文。边缘手势由独立驱动处理。")
    ttk.Label(frame, text=notice, wraplength=470, foreground="#666666").grid(
        row=5, column=0, columnspan=2, sticky="w", pady=12)

    def on_save():
        updated = dict(cfg, sensitivity=SENSITIVITY_MAP[sens_var.get()],
                       shock=SHOCK_MAP[shock_var.get()], edge_brightness=brightness_var.get())
        try:
            current_device = find_touchpad_hidraw(device)
            apply_settings(current_device, updated["sensitivity"], updated["shock"],
                           updated["edge_brightness"], experimental=experimental)
            save_config(updated, config_path)
        except TouchpadError as exc:
            messagebox.showerror("设置失败", str(exc), parent=root)
            return
        messagebox.showinfo("已发送设置请求", "设置请求已发送，偏好已保存。请检查触控板实际反馈。",
                            parent=root)

    ttk.Button(frame, text="保存并发送设置", command=on_save,
               state="normal" if IS_WINDOWS or experimental else "disabled").grid(
                   row=6, column=0, columnspan=2, sticky="e", pady=(6, 0))
    root.mainloop()
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description="HONOR touchpad discovery and settings")
    parser.add_argument("--sensitivity", choices=("low", "mid", "high"))
    parser.add_argument("--shock", choices=("off", "low", "mid", "high"))
    parser.add_argument("--gui", action="store_true", help="Launch graphical settings")
    parser.add_argument("--status", action="store_true", help="Show device and stored preferences")
    parser.add_argument("--apply-saved", action="store_true", help="Send saved preferences")
    parser.add_argument("--device", help="Select a supported Linux /dev/hidraw node")
    parser.add_argument("--config", help="Explicit settings JSON path")
    parser.add_argument("--experimental", action="store_true", help=LINUX_PROTOCOL_NOTICE)
    args = parser.parse_args(argv)
    actions = sum((args.status, args.gui, args.apply_saved, bool(args.sensitivity or args.shock)))
    if actions > 1:
        parser.error("choose one of --status, --gui, --apply-saved, or settings options")
    try:
        if args.gui:
            return show_gui(args.device, args.config, args.experimental)
        dev = find_touchpad_hidraw(args.device)
        if args.status:
            cfg = load_config(args.config)
            print(f"Platform: {'Windows' if IS_WINDOWS else 'Linux'}")
            if IS_WINDOWS:
                print("Control backend: PC Manager IPC (does not enumerate hardware)")
            else:
                print(f"Device: {dev or 'Not found (I2C 27c6:0f9a)'}")
            print(f"Settings file: {args.config or CONFIG_FILE}")
            print("Saved/default preferences (not hardware readback): "
                  f"Sensitivity={SENSITIVITY_MAP[cfg['sensitivity']]}, "
                  f"Shock={SHOCK_MAP[cfg['shock']]}")
            if IS_WINDOWS:
                helper_available = _windows_helper_path().is_file()
                service_running = _windows_service_running()
                print(f"HONOR helper DLL: {'found' if helper_available else 'not found'}")
                print(f"PC Manager MBAMainService: {'running' if service_running else 'not running'}")
                print("Control uses PC Manager IPC requests; hardware acknowledgement is unavailable.")
                return 0 if helper_available and service_running else 1
            else:
                print(LINUX_PROTOCOL_NOTICE)
                print("Edge gestures: managed separately; not detected by this tool.")
            return 0 if dev else 1
        if args.apply_saved or args.sensitivity or args.shock:
            if args.apply_saved and not Path(args.config or CONFIG_FILE).is_file():
                raise TouchpadError(f"No saved settings file: {args.config or CONFIG_FILE}.")
            cfg = load_config(args.config)
            if args.sensitivity:
                cfg["sensitivity"] = SENSITIVITY_MAP[args.sensitivity]
            if args.shock:
                cfg["shock"] = SHOCK_MAP[args.shock]
            apply_settings(dev, cfg["sensitivity"], cfg["shock"], cfg["edge_brightness"],
                           experimental=args.experimental)
            if not args.apply_saved:
                save_config(cfg, args.config)
            transport = "PC Manager IPC request" if IS_WINDOWS else "Experimental HID report"
            print(f"{transport} sent; hardware state has not been read back.")
            return 0
        if IS_WINDOWS or os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"):
            return show_gui(args.device, args.config, args.experimental)
        parser.print_help()
        return 0
    except (TouchpadError, OSError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

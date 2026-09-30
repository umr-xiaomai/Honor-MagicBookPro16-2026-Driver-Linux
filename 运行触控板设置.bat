@echo off
title HONOR 压力触控板设置 (预览与调节)
cd /d "%~dp0\touchBar"
python touchpad_control.py --gui
pause

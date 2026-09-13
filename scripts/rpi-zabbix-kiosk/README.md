# Raspberry Pi Zabbix Kiosk Controller

## Status: Archived. This project was built for specific physical hardware and is retained for portfolio demonstration of Wayland and Linux kernel input manipulation.

## Purpose

This project provides an automated kiosk environment for a Raspberry Pi displaying a Zabbix monitoring dashboard. It includes scripts to manage Wayland display states (`wlr-randr`) and remotely inject hardware keystrokes (F11 for fullscreen) via the Linux `/dev/input` subsystem.

## Architecture

*   **Target OS:** Raspberry Pi OS (Wayland)
*   **Browser:** Chromium (Kiosk Mode)
*   **Input Injection:** Python 3 (`struct` module mapping to Linux kernel input events)
*   **Remote Execution:** SSH with key-based authentication

## Prerequisites

1.  Target machine must be running a Wayland compositor.
2.  Python 3 must be installed.
3.  User must have SSH access and passwordless `sudo` privileges for the python injection script.
4.  Identify your correct keyboard event handler: `ls -l /dev/input/by-id/`

---

## 1. System Configuration

**SSH Key Authentication**

To allow the remote trigger to work without prompting for a password, configure SSH keys:

```bash
mkdir -p ~/.ssh 
cat /tmp/id_ed25519.pub >> ~/.ssh/authorized_keys 
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
```

**Hardware Button Mapping (Optional)**

To map a physical GPIO button to F11, add the following to `/boot/firmware/config.txt`:

```ini
dtoverlay=gpio-key,gpio=21,keycode=87,label="VIRTUAL_F11"
```

---

## 2. Core Scripts

Create a directory to store the automation scripts, for example: `/opt/kiosk/` or `/home/pi/scripts/`.

### Python Input Injector (`f11_injector.py`)

This script writes directly to the Linux input subsystem to simulate a physical F11 key press. Requires `sudo`.

```python
#!/usr/bin/env python3
import struct
import time
import sys

KEY_F11 = 87
EV_KEY = 0x01
EV_SYN = 0x00

if len(sys.argv) < 2:
    print("Usage: sudo python3 f11_injector.py /dev/input/eventX")
    sys.exit(1)

device_path = sys.argv[1]

def write_event(f, ev_type, code, value):
    # Formats for 64-bit Linux. Use 'IIHHi' for 32-bit systems.
    data = struct.pack('llHHi', 0, 0, ev_type, code, value)
    f.write(data)

try:
    with open(device_path, 'wb') as f:
        write_event(f, EV_KEY, KEY_F11, 1) # Press
        write_event(f, EV_SYN, 0, 0)
        time.sleep(0.1)
        write_event(f, EV_KEY, KEY_F11, 0) # Release
        write_event(f, EV_SYN, 0, 0)
    print(f"Successfully injected F11 into {device_path}")
except PermissionError:
    print("Error: Root privileges required.")
except FileNotFoundError:
    print(f"Error: Device {device_path} not found. Check /dev/input/by-id/")
```

### Wayland Display Toggle (`hdmi_toggle.sh`)

This script checks the status of the HDMI outputs and toggles them. If turning them on, it waits and injects the F11 key to ensure the dashboard goes fullscreen.

```bash
#!/bin/bash
export XDG_RUNTIME_DIR=/run/user/1000
export WAYLAND_DISPLAY=wayland-1

STATUS=$(wlr-randr | grep -A2 "HDMI-A-2" | grep "Enabled:" | head -n1 | awk '{print $2}')

if [ "$STATUS" = "yes" ]; then
    wlr-randr --output HDMI-A-1 --off --output HDMI-A-2 --off
    echo "Displays turned OFF"
else
    wlr-randr --output HDMI-A-1 --on --output HDMI-A-2 --on --pos 0,1080
    echo "Displays turned ON"
    sleep 5
    # Adjust the script path and event handler as needed
    sudo python3 /opt/kiosk/f11_injector.py /dev/input/by-path/platform-button@15-event
fi
```

---

## 3. Autostart & Remote Triggers

### Kiosk Autostart (`~/.config/autostart/screens.sh`)

This script launches Chromium in kiosk mode upon system boot.

```bash
#! /bin/sh
sleep 5
chromium-browser --noerrdialogs --disable-infobars --new-window --start-fullscreen --force-device-scale-factor=0.5 "http://<ZABBIX_IP>/zabbix.php?action=dashboard.view&dashboardid=<ID>" &> /dev/null
```

### Windows Remote Trigger (`remote_trigger.bat`)

A simple batch script to execute the display toggle from a Windows workstation.

```bat
@echo off
set RPI_IP=192.168.1.X
set RPI_USER=pi

echo Triggering display toggle on %RPI_IP%...
ssh -o StrictHostKeyChecking=no %RPI_USER%@%RPI_IP% "/opt/kiosk/hdmi_toggle.sh"
```

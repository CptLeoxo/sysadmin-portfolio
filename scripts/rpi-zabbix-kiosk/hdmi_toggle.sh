#!/bin/bash
# Toggles HDMI outputs on a Wayland session

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
    # Trigger fullscreen mode via virtual input
    sudo python3 /opt/kiosk/f11_injector.py /dev/input/by-path/platform-button@15-event
fi

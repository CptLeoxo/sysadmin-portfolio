#!/usr/bin/env python3
"""
Injects an F11 keystroke directly into the Linux input subsystem.
Requires root privileges to write to /dev/input/.
"""
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
    # llHHi -> long (time sec), long (time usec), unsigned short (type), unsigned short (code), int (value)
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

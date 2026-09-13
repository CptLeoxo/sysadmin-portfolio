# Zabbix Proxy Setup on Raspberry Pi 

This document provides a step-by-step guide for installing and configuring Zabbix Proxy on a Raspberry Pi device.

## 0. Hardware Preparation
If you are using an Argon case for your Raspberry Pi:
> **Warning:** Ensure the jumper pins are set to **2-3**, not 1-2! This configuration ensures the RPi automatically boots up when connected to a power supply.

---

## 1. OS Installation and Verification
If you have an RPi 4 or newer, you can install the OS directly via the Network Install Manager. Alternatively, use a USB drive and the Raspberry Pi Imager.
This guide uses **Debian 12 Bookworm**, as it is currently the most stable OS with full Zabbix compatibility.

*(Run all following commands as root, e.g., using `sudo -i`)*

### Verify OS and Architecture
Check the system version to ensure you download the correct packages from the Zabbix repository:
```bash
cat /etc/os-release
uname -m
```

### Update the System
```bash
apt-get update && apt-get full-upgrade -y && apt-get autoremove
```

---

## 2. VPN Setup (OpenVPN)
If your device needs to communicate via a VPN:

### Install and Verify
```bash
apt-get install openvpn -y
openvpn --version
```

### Transfer Configuration
Transfer your `.ovpn` file to the Raspberry Pi (e.g., via SCP if devices are on the same network):
```bash
# On your local machine:
scp rpiproxy.ovpn <USERNAME>@<RPI_IP>:/tmp/
```

### Configure the Client
Move the configuration to the appropriate directory:
```bash
mkdir -p /etc/openvpn/client
cp /tmp/rpiproxy.ovpn /etc/openvpn/client/your-config.conf
```
*Note: Ensure the configuration file uses the `.conf` extension.*

**If your VPN requires a password:**
1. Create a text file containing the password in `/etc/openvpn/client/`.
2. Add this line to your `your-config.conf` file:
   `askpass /etc/openvpn/client/<password_file.txt>`

### Enable and Start the Service
```bash
systemctl enable openvpn-client@your-config
systemctl start openvpn-client@your-config
systemctl status openvpn-client@your-config
```
*(The status should show as `active (running)` and `enabled`)*

---

## 3. Zabbix Proxy Installation & Configuration

### Add Zabbix 7.0 Repository
Download the appropriate package for your OS from [repo.zabbix.com](https://repo.zabbix.com/zabbix/7.0/):
```bash
wget https://repo.zabbix.com/zabbix/7.0/<os>/pool/main/z/zabbix-release/zabbix-release_7.<info>.deb 
dpkg -i zabbix-release_7.<info>.deb
apt-get update
```

### Install Proxy and SQLite
Zabbix Proxy requires a database. SQLite3 is the most suitable option for a Raspberry Pi:
```bash
apt-get install zabbix-proxy-sqlite3 sqlite3 -y
```

### Edit Configuration
```bash
nano /etc/zabbix/zabbix_proxy.conf
```
Modify or uncomment the key parameters according to your infrastructure:
```ini
ProxyMode=0
Server=<Zabbix_Server_IP>:10051
ListenPort=10051
Hostname=<Your_Proxy_Hostname>
DBName=/tmp/zabbix_proxy.db
StatsAllowedIP=127.0.0.1,<Zabbix_Network_Subnet>
```

### Start Zabbix Proxy Service
```bash
systemctl enable zabbix-proxy 
systemctl start zabbix-proxy
systemctl status zabbix-proxy
```

---

## 4. Zabbix Agent 2 Installation
To monitor the Proxy itself, install the Zabbix agent:
```bash
apt-get install zabbix-agent2
nano /etc/zabbix/zabbix-agent2.conf  # Configure according to your CheatSheet
systemctl status zabbix-agent2
```

---

## 5. Additional System Settings (VNC & NTP)

### VNC Server (Optional)
If you are using a GUI and want to enable VNC:
1. Run `raspi-config`
2. Navigate to `Interfaces` -> `VNC` -> `Yes`
3. Disable the autologin feature for the default user to ensure VNC works correctly:
   ```bash
   nano /etc/lightdm/lightdm.conf
   # Ensure the following parameter is commented out:
   # autologin-user=pi
   ```

### NTP (Time Synchronization)
Check the synchronization status:
```bash
timedatectl status
# or
ntpq -p
```
If the service is not running, configure your regional NTP servers (e.g., CZ servers):
```bash
nano /etc/systemd/timesyncd.conf
# Add the following lines:
# [Time]
# NTP=tik.cesnet.cz tak.cesnet.cz

systemctl restart systemd-timesyncd
timedatectl show-timesync --all  # To verify
```

---

## 6. Adding the Proxy to Zabbix Server (Web UI)

### Create Proxy Entry
1. Check your groups: `Administration` -> `Proxy groups` and `Data collection` -> `Host groups`.
2. Add the proxy: `Administration` → `Proxies` -> `Create proxy`.
3. The `Proxy name` **must** match the `Hostname` specified in your proxy configuration file. Add the address and group, then save.

### Add Host for Proxy Monitoring
1. Go to `Monitoring` -> `Hosts` -> `Create host`.
2. Set the parameters:
   * **Hostname**: Must match the configuration.
   * **Templates**: e.g., `Linux by Zabbix agent active`, `Zabbix proxy health by Zabbix agent active`.
   * **Interfaces**: Proxy device IP, port 10050.
   * **Monitored by**: Select the newly created proxy itself (or Server, if adding to an internal Zabbix).

---

## 💡 Best Practices & Final Thoughts

**A question from the original draft:**
*Is it better to store the database in `/var/lib/zabbix/zabbix_proxy.db` (persistent storage) instead of `/tmp/zabbix_proxy.db`?*

**Infrastructure perspective answer:**
It depends entirely on the storage medium used by your Raspberry Pi's OS:
1. **If using an SD Card (Standard Scenario):** The `/tmp/` directory is often mounted as a RAM disk (`tmpfs`). Zabbix Proxy generates a massive amount of IO operations (writes). If the database is located directly on the SD card in `/var/lib/`, the physical wear and tear will destroy the card very quickly. Losing data in `/tmp/` during a reboot is an acceptable trade-off to extend hardware lifespan.
2. **If using an external USB SSD:** In this case, it is safe and highly recommended to use the standard persistent path (e.g., `/var/lib/zabbix/`). This ensures you do not lose unsent historical data if the proxy reboots.
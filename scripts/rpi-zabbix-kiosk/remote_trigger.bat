@echo off
:: Remote trigger for RPi Zabbix Dashboard
set RPI_IP=192.168.1.X
set RPI_USER=pi

echo Triggering display toggle on %RPI_IP%...
ssh -o StrictHostKeyChecking=no %RPI_USER%@%RPI_IP% "/opt/kiosk/hdmi_toggle.sh"

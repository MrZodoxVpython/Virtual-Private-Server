#!/bin/bash
echo "Starting VPN Data Restore..."

# Unduh file backup terbaru dari Google Drive
rclone copy gdrive:/Backup-VPN/backup-vpn.tar.gz /root/ --progress

# Ekstrak isi file
tar -xzf /root/backup-vpn.tar.gz -C /root/

# Pulihkan file ke lokasi aslinya
cp -r /root/backup-vpn/xray /etc/
cp -r /root/backup-vpn/v2ray /etc/ 2>/dev/null
cp -f /root/backup-vpn/passwd /etc/
cp -f /root/backup-vpn/shadow /etc/
cp -f /root/backup-vpn/group /etc/
cp -f /root/backup-vpn/gshadow /etc/
cp -r /root/backup-vpn/cron.d /etc/
cp -r /root/backup-vpn/ssh /etc/
cp -r /root/backup-vpn/system /etc/systemd/

# Restart layanan
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart xray
systemctl restart ssh

echo "✅ Restore selesai!"

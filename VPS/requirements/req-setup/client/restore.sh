#!/bin/bash
echo "Starting VPN Data Restore..."

# Unduh file backup terbaru dari Google Drive
rclone copy GDRIVE:/Backup-VPN/backup-vpn.tar.gz /root/ --progress

# Ekstrak isi file
tar -xzf /root/backup-vpn.tar.gz -C /root/

# Pulihkan file ke lokasi aslinya
cp -r /root/backup-vpn/etc/xray /etc/
cp -r /root/backup-vpn/etc/v2ray /etc/ 2>/dev/null
cp -f /root/backup-vpn/etc/passwd /etc/
cp -r /root/backup-vpn/etc/cron.d /etc/
cp -r /root/backup-vpn/etc/ssh /etc/
cp -r /root/backup-vpn/etc/system /etc/systemd/

cp -f /root/backup-vpn/etc/shadow /etc/
cp -f /root/backup-vpn/etc/group /etc/
cp -f /root/backup-vpn/etc/gshadow /etc/

# Restart layanan
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart xray
systemctl restart ssh

echo "✅ Restore selesai!"

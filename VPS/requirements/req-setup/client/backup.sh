#!/bin/bash

echo "Starting VPN Data Backup..."

BACKUP_DIR="/root/backup-vpn"
BACKUP_FILE="/root/backup-vpn.tar.gz"
DATE=$(date +%Y-%m-%d)

# Buat direktori sementara
mkdir -p $BACKUP_DIR

# Backup konfigurasi dan akun penting
cp -r /etc/xray $BACKUP_DIR/
cp -r /etc/v2ray $BACKUP_DIR/ 2>/dev/null
cp -r /etc/passwd /etc/shadow /etc/group /etc/gshadow $BACKUP_DIR/
cp -r /etc/cron.d $BACKUP_DIR/
cp -r /etc/ssh $BACKUP_DIR/
cp -r /etc/systemd/system $BACKUP_DIR/

# Buat file .tar.gz backup
tar -czf $BACKUP_FILE -C /root backup-vpn

# Upload ke Google Drive dengan remote yang benar
rclone copy $BACKUP_FILE GDRIVE:/Backup-VPN/ --progress

if [ $? -eq 0 ]; then
  echo "✅ Backup selesai!"
  echo "🗂 Disimpan sebagai: $BACKUP_FILE"
  echo "☁️ Upload ke Google Drive: GDRIVE:/Backup-VPN/$(basename $BACKUP_FILE)"
else
  echo "❌ Upload ke Google Drive gagal!"
fi

# Bersihkan direktori sementara
rm -rf $BACKUP_DIR

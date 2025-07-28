#!/bin/bash

# 🛑 Harus dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Harus dijalankan sebagai root!"
  exit 1
fi

# 📁 Lokasi file lokal & script restore
BACKUP_FILE="/var/www/html/Website-Tokomard-Panel/admin/backup-vpn.tar.gz"
RESTORE_SCRIPT="/var/www/html/Website-Tokomard-Panel/admin/auto-restore-vpn.sh"

echo "=== 🔁 MENU RESTORE BACKUP VPN ==="
echo "1. 📂 Restore dari file lokal"
echo "2. ☁ Restore dari Google Drive (via token JSON)"
read -p "Pilih opsi (1/2): " mode

if [[ "$mode" == "1" ]]; then
  if [[ -f "$BACKUP_FILE" ]]; then
    echo "✅ File ditemukan, mulai proses restore..."
    tar -xzf "$BACKUP_FILE" -C /root
    cp -r /root/backup-vpn/* / --no-preserve=ownership
    echo "✅ Restore dari file lokal berhasil!"
  else
    echo "❌ File backup $BACKUP_FILE tidak ditemukan!"
    exit 1
  fi

elif [[ "$mode" == "2" ]]; then
  echo "📛 Masukkan nama folder VPS di Google Drive (contoh: SGDO-2DEV)"
  read -p "→ Nama VPS: " VPS_NAME

  echo "🔑 Paste token JSON (satu baris, mulai dari { hingga })"
  read -p "→ Token JSON: " token

  TOKEN_FILE="/tmp/token.json"
  echo "$token" > "$TOKEN_FILE"

  if ! jq .access_token "$TOKEN_FILE" &>/dev/null; then
    echo "❌ Token JSON tidak valid!"
    exit 1
  fi

  echo "🔧 Membuat konfigurasi rclone..."
  mkdir -p /root/.config/rclone
  cat > /root/.config/rclone/rclone.conf <<EOF
[GDRIVE]
type = drive
scope = drive
token = $token
team_drive =
EOF

  echo "☁ Mengunduh file backup dari Google Drive folder: $VPS_NAME..."
  if rclone --config="/root/.config/rclone/rclone.conf" copy "GDRIVE:/TOKOMARD/Backup-VPS/$VPS_NAME/backup-vpn.tar.gz" /root/; then
    echo "🗜 Mengekstrak dan merestore..."
    tar -xzf /root/backup-vpn.tar.gz -C /root
    cp -r /root/backup-vpn/* / --no-preserve=ownership
    echo "✅ Restore dari GDrive berhasil!"

    echo "🔁 Restart layanan xray dan ssh..."
    systemctl restart xray && echo "✅ xray berhasil direstart" || echo "❌ Gagal restart xray"
    systemctl restart ssh && echo "✅ ssh berhasil direstart" || echo "❌ Gagal restart ssh"
  else
    echo "❌ Gagal mengunduh dari Google Drive."
    exit 1
  fi

else
  echo "❌ Pilihan tidak valid!"
  exit 1
fi

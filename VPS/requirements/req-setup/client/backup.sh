#!/bin/bash

RCLONE_CONF="/root/.config/rclone/rclone.conf"
TOKEN_FILE="/etc/xray/token.json"
BACKUP_DIR="/root/backup-vpn/etc"
BACKUP_PARENT="/root/backup-vpn"
BACKUP_FILE="/root/backup-vpn.tar.gz"

# ✅ Pastikan folder /etc/xray ada
mkdir -p /etc/xray

# ✅ Input nama VPS
read -p "📛 Masukkan nama VPS (contoh: SGDO-2DEV): " VPS_NAME

# ✅ Cek apakah token sudah disimpan
if [ -f "$TOKEN_FILE" ]; then
    echo "🔄 Menggunakan token JSON yang sudah disimpan..."
    TOKEN_JSON=$(<"$TOKEN_FILE")
else
    echo
    echo "🔑 Masukkan isi lengkap TOKEN JSON (satu baris, pastikan dimulai dengan { dan diakhiri dengan }):"
    read -r TOKEN_JSON

    # ✅ Validasi token JSON
    if ! echo "$TOKEN_JSON" | jq .access_token &>/dev/null; then
        echo "❌ Token JSON tidak valid!"
        exit 1
    fi

    # ✅ Simpan token ke file
    echo "$TOKEN_JSON" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo "✅ Token JSON disimpan di $TOKEN_FILE"
fi

# ✅ Cek dan install rclone jika belum ada
if ! command -v rclone &>/dev/null; then
    echo "📥 Menginstall rclone..."
    curl https://rclone.org/install.sh | bash || { echo "❌ Gagal menginstal rclone!"; exit 1; }
fi

# ✅ Buat konfigurasi rclone
mkdir -p "$(dirname "$RCLONE_CONF")"
cat > "$RCLONE_CONF" <<EOF
[GDRIVE]
type = drive
scope = drive
token = $TOKEN_JSON
team_drive =
EOF

echo "📛 Nama VPS: $VPS_NAME"

# ✅ Persiapan folder backup
mkdir -p "$BACKUP_DIR"
cp -r /etc/xray "$BACKUP_DIR/" 2>/dev/null || echo "⚠ /etc/xray tidak ditemukan"
cp -r /etc/v2ray "$BACKUP_DIR/" 2>/dev/null || echo "⚠ /etc/v2ray tidak ditemukan"
cp -r /etc/passwd /etc/shadow /etc/group /etc/gshadow "$BACKUP_DIR/" 2>/dev/null
cp -r /etc/cron.d "$BACKUP_DIR/" 2>/dev/null
cp -r /etc/ssh "$BACKUP_DIR/" 2>/dev/null
cp -r /etc/systemd/system "$BACKUP_DIR/" 2>/dev/null

# ✅ Buat file tar.gz
echo "🗜 Membuat arsip backup..."
tar -czf "$BACKUP_FILE" -C /root backup-vpn

# ✅ Hak akses agar bisa didownload web panel
chown www-data:www-data "$BACKUP_FILE"
chmod 755 "$BACKUP_FILE"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ File backup gagal dibuat."
    ls -lah "$BACKUP_PARENT"
    exit 1
fi

# ✅ Upload ke Google Drive
GDRIVE_FOLDER="TOKOMARD/Backup-VPS/$VPS_NAME"
echo "☁ Mengupload ke Google Drive: $GDRIVE_FOLDER"

if ! rclone --config="$RCLONE_CONF" copy "$BACKUP_FILE" "GDRIVE:$GDRIVE_FOLDER" --progress; then
    echo "❌ Upload ke Google Drive gagal!"
else
    echo "✅ Upload ke Google Drive berhasil ke $GDRIVE_FOLDER!"
fi

# ✅ Bersihkan
rm -rf "$BACKUP_DIR"
rm -f "$BACKUP_FILE"
rm -rf "$BACKUP_PARENT"

echo "✅ Backup berhasil! File tersedia untuk diunduh di web drive."

#!/bin/bash

# Bersihkan file lama
rm -f xolpanel.sh

# Update & upgrade sistem
apt update -y && apt upgrade -y

# Instalasi dependensi utama
apt install -y python3 python3-pip git unzip wget

# Download xolpanel
echo "Mengunduh xolpanel.zip..."
wget -q https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xolpanel.zip

# Verifikasi apakah file berhasil diunduh
if [ ! -f xolpanel.zip ]; then
    echo "Gagal mengunduh xolpanel.zip! Periksa koneksi internet atau URL."
    exit 1
fi

# Ekstrak xolpanel
unzip -o xolpanel.zip > /dev/null 2>&1
if [ ! -d xolpanel ]; then
    echo "Gagal mengekstrak xolpanel.zip!"
    exit 1
fi

# Instalasi requirements Python
pip3 install -r xolpanel/requirements.txt
pip3 install pillow

# Input konfigurasi dari pengguna
echo "=== XolPanel Registration ==="
read -e -p "[*] Input your Bot Token       : " bottoken
read -e -p "[*] Input Your Telegram ID     : " tokomard
read -e -p "[*] Input Your Subdomain       : " domain

# Simpan ke file konfigurasi
cat > /root/xolpanel/var.txt <<EOF
BOT_TOKEN="$bottoken"
ADMIN="$tokomard"
DOMAIN="$domain"
EOF

clear
echo "Konfigurasi berhasil disimpan!"
echo -e "==============================="
echo "Bot Token     : $bottoken"
echo "Telegram ID   : $tokomard"
echo "Subdomain     : $domain"
echo -e "==============================="
echo "Setting selesai. Menunggu 10 detik..."
sleep 10

# Buat systemd service
cat > /etc/systemd/system/xolpanel.service << EOF
[Unit]
Description=Simple XolPanel - @XolPanel
After=network.target

[Service]
WorkingDirectory=/root/xolpanel
ExecStart=/usr/bin/python3 -m xolpanel
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan mulai service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xolpanel
systemctl start xolpanel
systemctl status xolpanel

# Verifikasi apakah service berjalan
if systemctl is-active --quiet xolpanel; then
    echo "✅ XolPanel berhasil dijalankan!"
else
    echo "❌ Gagal menjalankan XolPanel. Silakan cek log dengan: journalctl -u xolpanel -f"
fi

# Informasi akhir
clear
echo -e "==============================================="
echo "        ✅ CREATED BY BENJAMIN-TOKOMARD-DEV"
echo "✅ Instalasi selesai, ketik /menu pada bot Telegram Anda"
echo -e "==============================================="

# Prompt untuk reboot
read -n 1 -s -r -p "Tekan sembarang tombol untuk Reboot"
clear
reboot

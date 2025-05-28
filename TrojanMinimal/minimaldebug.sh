#!/bin/bash

echo -e "\n========== TROJAN XRAY DEBUG TOOL ==========\n"

# 1. Cek status layanan Xray
echo "[1] Mengecek status layanan Xray..."
if systemctl is-active --quiet xray; then
    echo "✅ Xray sedang berjalan."
else
    echo "❌ Xray TIDAK berjalan."
    systemctl status xray --no-pager
fi

# 2. Cek port yang digunakan (443 dan 80)
echo -e "\n[2] Mengecek port Trojan (443 & 80)..."
ss -tuln | grep -E ':443|:80' || echo "❌ Port 443/80 tidak terbuka!"

# 3. Cek apakah proses Xray sedang listening
echo -e "\n[3] Cek apakah Xray aktif di port dengan PID..."
ss -tnlp | grep xray || echo "❌ Xray tidak terlihat mendengarkan pada port manapun."

# 4. Cek file konfigurasi utama
echo -e "\n[4] Validasi konfigurasi utama Xray (/etc/xray/config.json)..."
CONFIG1="/etc/xray/config.json"
if [ -f "$CONFIG1" ]; then
    jq empty "$CONFIG1" && echo "✅ Konfigurasi $CONFIG1 valid." || echo "❌ Konfigurasi $CONFIG1 tidak valid!"
else
    echo "❌ File $CONFIG1 tidak ditemukan!"
fi

# 5. Cek konfigurasi yang digunakan oleh systemd
echo -e "\n[5] Validasi konfigurasi systemd Xray (/usr/local/etc/xray/config.json)..."
CONFIG2="/usr/local/etc/xray/config.json"
if [ -f "$CONFIG2" ]; then
    jq empty "$CONFIG2" && echo "✅ Konfigurasi $CONFIG2 valid." || echo "❌ Konfigurasi $CONFIG2 tidak valid!"
else
    echo "❌ File $CONFIG2 tidak ditemukan!"
fi

# 6. Cek sertifikat TLS
echo -e "\n[6] Mengecek sertifikat TLS..."
CERT="/etc/xray/xray.crt"
KEY="/etc/xray/xray.key"
if [ -f "$CERT" ] && [ -f "$KEY" ]; then
    echo "✅ Sertifikat ditemukan: $CERT dan $KEY"
    openssl x509 -in $CERT -noout -text | grep 'Not After'
else
    echo "❌ Sertifikat TLS tidak ditemukan!"
fi

# 7. Validasi permission sertifikat dan direktori
echo -e "\n[7] Validasi permission xray.key dan direktori..."
ls -l $KEY 2>/dev/null
ls -ld /etc/xray 2>/dev/null

# 8. Cek apakah domain mengarah ke VPS
echo -e "\n[8] Cek apakah domain mengarah ke IP VPS..."
DOMAIN=$(jq -r '..|objects|select(has("serverName"))|.serverName' "$CONFIG2" | head -n1)
MYIP=$(curl -s ifconfig.me)
DOMAINIP=$(dig +short "$DOMAIN" | tail -n1)

echo "Domain yang digunakan: $DOMAIN"
echo "IP VPS: $MYIP"
echo "IP domain: $DOMAINIP"
if [ "$MYIP" == "$DOMAINIP" ]; then
    echo "✅ Domain mengarah ke IP VPS"
else
    echo "❌ Domain TIDAK mengarah ke IP VPS"
fi

# 9. Cek akun Trojan aktif
echo -e "\n[9] Cek akun Trojan yang aktif..."
CLIENTS_FILE="/etc/xray/trojan-clients.json"
if [ -f "$CLIENTS_FILE" ]; then
    echo "Daftar akun:"
    jq -r '.[] | "\(.email) - Exp: \(.expired)"' "$CLIENTS_FILE"
else
    echo "❌ File akun tidak ditemukan di $CLIENTS_FILE"
fi

# 10. Cek log error terbaru
echo -e "\n[10] Cek log error Xray..."
ERROR_LOG="/var/log/xray/error.log"
if [ -f "$ERROR_LOG" ]; then
    tail -n 20 "$ERROR_LOG"
else
    echo "❌ Log error tidak ditemukan di $ERROR_LOG"
fi

# 11. Cek konfigurasi systemd
echo -e "\n[11] Cek konfigurasi systemd service Xray..."
SYSTEMD_SERVICE="/etc/systemd/system/xray.service"
if [ -f "$SYSTEMD_SERVICE" ]; then
    grep -E '^User=|ExecStart=' "$SYSTEMD_SERVICE"
else
    echo "❌ File unit systemd tidak ditemukan!"
fi

# 12. Tampilkan log systemd terbaru (termasuk kegagalan)
echo -e "\n[12] Log systemd terbaru untuk Xray..."
journalctl -u xray -b --no-pager | tail -n 30
#echo -e "Manual tes in client devices"
#curl -v --resolve benjamin.tokomard.store:443:157.230.44.135 https://benjamin.tokomard.store/trojan-ws
echo -e "\n✅ Debugging selesai. Silakan periksa hasil di atas.\n"

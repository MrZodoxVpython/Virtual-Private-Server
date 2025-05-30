#!/bin/bash
#+==============+
# BENJAMINWICKMAN
# MRZODOXVPYTHON
# TOKOMARD-DEVVV
#+==============+

fix_and_retry() {
    local step=$1
    local fix_func=$2

    echo -ne "\n🛠 Apakah Anda ingin mencoba memperbaiki masalah ini? (y/n): "
    read -r confirm
    if [[ $confirm == "y" ]]; then
        $fix_func
        echo -e "\n🔁 Menjalankan ulang langkah #$step untuk memastikan perbaikan..."
        eval "step_$step"
    fi
}

step_1() {
    echo "[1] Mengecek status layanan Xray..."
    if systemctl is-active --quiet xray; then
        echo "✅ Xray sedang berjalan."
    else
        echo "❌ Xray TIDAK berjalan."
        systemctl status xray --no-pager
        fix_and_retry 1 "fix_step_1"
    fi
}
fix_step_1() {
    echo "🔧 Mencoba menjalankan ulang layanan Xray..."

    # Pastikan direktori log ada
    if [ ! -d /var/log/xray ]; then
        echo "Membuat direktori /var/log/xray..."
        mkdir -p /var/log/xray
    fi

    # Pastikan file access.log ada
    if [ ! -f /var/log/xray/access.log ]; then
        echo "Membuat file /var/log/xray/access.log..."
        touch /var/log/xray/access.log
    fi

    # Dapatkan user yang digunakan oleh service xray dari systemd
    XRAY_USER=$(grep '^User=' /etc/systemd/system/xray.service | cut -d= -f2)
    if [ -z "$XRAY_USER" ]; then
        XRAY_USER="nobody"
        echo "User Xray tidak ditemukan, default ke 'nobody'"
    else
        echo "User Xray ditemukan: $XRAY_USER"
    fi

    # Ubah kepemilikan ke user dan grup service xray
    echo "Mengubah kepemilikan /var/log/xray ke $XRAY_USER:$XRAY_USER ..."
    chown -R "$XRAY_USER":"$XRAY_USER" /var/log/xray

    # Set permission yang tepat
    chmod 755 /var/log/xray
    chmod 644 /var/log/xray/access.log

    # Restart layanan xray
    systemctl restart xray
}

step_2() {
    echo -e "\n[2] Mengecek port Trojan (443 & 80)..."
    if ss -tuln | grep -E ':443|:80'; then
        echo "✅ Port 443/80 terbuka."
    else
        echo "❌ Port 443/80 tidak terbuka!"
    fi
}

step_3() {
    echo -e "\n[3] Cek apakah Xray aktif di port dengan PID..."
    ss -tnlp | grep xray || echo "❌ Xray tidak terlihat mendengarkan pada port manapun."
}

step_4() {
    echo -e "\n[4] Validasi konfigurasi utama Xray (/etc/xray/config.json)..."
    CONFIG1="/etc/xray/config.json"
    if [ -f "$CONFIG1" ]; then
        jq empty "$CONFIG1" && echo "✅ Konfigurasi $CONFIG1 valid." || {
            echo "❌ Konfigurasi $CONFIG1 tidak valid!"
            fix_and_retry 4 "fix_step_4"
        }
    else
        echo "❌ File $CONFIG1 tidak ditemukan!"
    fi
}
fix_step_4() {
    echo "Silakan perbaiki file JSON secara manual (karena otomatisasi berisiko)."
    nano /etc/xray/config.json
}

step_5() {
    echo -e "\n[5] Validasi konfigurasi systemd Xray (/usr/local/etc/xray/config.json)..."
    CONFIG2="/usr/local/etc/xray/config.json"
    if [ -f "$CONFIG2" ]; then
        jq empty "$CONFIG2" && echo "✅ Konfigurasi $CONFIG2 valid." || {
            echo "❌ Konfigurasi $CONFIG2 tidak valid!"
            fix_and_retry 5 "fix_step_5"
        }
    else
        echo "❌ File $CONFIG2 tidak ditemukan!"
    fi
}
fix_step_5() {
    echo "Silakan perbaiki file JSON secara manual (karena otomatisasi berisiko)."
    nano /usr/local/etc/xray/config.json
}

step_6() {
    echo -e "\n[6] Mengecek sertifikat TLS..."
    CERT="/etc/xray/xray.crt"
    KEY="/etc/xray/xray.key"
    if [ -f "$CERT" ] && [ -f "$KEY" ]; then
        echo "✅ Sertifikat ditemukan: $CERT dan $KEY"
        openssl x509 -in $CERT -noout -text | grep 'Not After'
    else
        echo "❌ Sertifikat TLS tidak ditemukan!"
        fix_and_retry 6 "fix_step_6"
    fi
}
fix_step_6() {
    echo "🔐 Sertifikat hilang. Apakah Anda ingin mencoba membuat ulang dengan acme.sh atau certbot."
    echo "Silakan instal ulang SSL Anda."
}

step_7() {
    echo -e "\n[7] Validasi permission xray.key dan direktori..."
    ls -l /etc/xray/xray.key 2>/dev/null
    ls -ld /etc/xray 2>/dev/null
}

step_8() {
    echo -e "\n[8] Cek apakah domain mengarah ke IP VPS..."
    CONFIG2="/usr/local/etc/xray/config.json"
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
        fix_and_retry 8 "fix_step_8"
    fi
}
fix_step_8() {
    echo "🔁 Periksa DNS dan pastikan domain diarahkan ke IP VPS Anda."
    echo "Silakan update record A dari domain Anda."
}

step_9() {
    echo -e "\n[9] Cek akun Trojan yang aktif..."
    CLIENTS_FILE="/etc/xray/trojan-clients.json"
    if [ -f "$CLIENTS_FILE" ]; then
        echo "Daftar akun:"
        jq -r '.[] | "\(.email) - Exp: \(.expired)"' "$CLIENTS_FILE"
    else
        echo "❌ File akun tidak ditemukan di $CLIENTS_FILE"
    fi
}

step_10() {
    echo -e "\n[10] Cek log error Xray..."
    ERROR_LOG="/var/log/xray/error.log"
    if [ -f "$ERROR_LOG" ]; then
        tail -n 20 "$ERROR_LOG"
    else
        echo "❌ Log error tidak ditemukan di $ERROR_LOG"
    fi
}

step_11() {
    echo -e "\n[11] Cek konfigurasi systemd service Xray..."
    SYSTEMD_SERVICE="/etc/systemd/system/xray.service"
    if [ -f "$SYSTEMD_SERVICE" ]; then
        grep -E '^User=|ExecStart=' "$SYSTEMD_SERVICE"
    else
        echo "❌ File unit systemd tidak ditemukan!"
    fi
}

step_12() {
    echo -e "\n[12] Log systemd terbaru untuk Xray..."
    journalctl -u xray -b --no-pager | tail -n 30
}

# =======================
# Main execution
# =======================
echo -e "\n========== TROJAN XRAY DEBUG TOOL ==========\n"

for i in {1..12}; do
    eval "step_$i"
done

echo -e "\n✅ Debugging selesai. Silakan periksa hasil di atas.\n"


#!/bin/bash

# ============================================
# Nama   : install-trojan-divps.sh
# Fungsi : Setup layanan Trojan WS TLS & non-TLS
# OS     : Debian/Ubuntu
# Dev    : BenjaminWickman | MrZodoxVpython
# ============================================

domain="yourdomain.com"
email="admin@$domain"
trojan_password="trojanpassword123"
cert_dir="/etc/xray"
xray_conf="/etc/xray/config.json"
xray_url="https://github.com/XTLS/Xray-install/raw/main/install-release.sh"

# === Cek Root ===
if [[ $EUID -ne 0 ]]; then
  echo "Script harus dijalankan sebagai root."
  exit 1
fi

# === Update dan install dependensi ===
apt update && apt install -y socat curl cron unzip tar iptables

# === Install Xray Core ===
bash <(curl -Ls $xray_url)

# === Set domain manual ===
read -rp "Masukkan domain yang telah diarahkan ke VPS ini (A record): " domain

# === Install acme.sh dan generate sertifikat ===
apt install -y socat
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256 --force \
  --key-file $cert_dir/xray.key \
  --fullchain-file $cert_dir/xray.crt

# === Konfigurasi Xray untuk Trojan WS TLS & Non-TLS ===
cat > $xray_conf <<EOF
{
  "log": {
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$trojan_password",
            "email": "default@tls"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "$cert_dir/xray.crt",
              "keyFile": "$cert_dir/xray.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/trojan-ws"
        }
      }
    },
    {
      "port": 80,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$trojan_password",
            "email": "default@none"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/trojan-ws"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# === Aktifkan Firewall untuk port yang dibutuhkan ===
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
netfilter-persistent save

# === Enable dan restart Xray ===
systemctl daemon-reload
systemctl enable xray
systemctl restart xray

# === Informasi Akun Trojan ===
clear
echo "===================================="
echo "Trojan VPN berhasil diinstal!"
echo "Domain       : $domain"
echo "Port TLS     : 443"
echo "Port Non-TLS : 80"
echo "Path         : /trojan-ws"
echo "Password     : $trojan_password"
echo "===================================="
echo "Format URL TLS:"
echo "trojan://${trojan_password}@${domain}:443?type=ws&security=tls&path=/trojan-ws#TrojanTLS"
echo ""
echo "Format URL Non-TLS:"
echo "trojan://${trojan_password}@${domain}:80?type=ws&security=none&path=/trojan-ws#TrojanNoTLS"
echo "===================================="

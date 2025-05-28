#!/bin/bash

# === Konfigurasi Awal ===
domain="yourdomain.com"            # Ganti dengan domain kamu
export CF_Token="your-cloudflare-api-token"  # Ganti dengan token Cloudflare
cert_dir="/etc/xray"
clients_file="/etc/xray/trojan-clients.json"
config_file="/etc/xray/config.json"
default_password="defaultpass123"
default_email="default@wildcard"
expired_default="2099-12-31"

# === Cek Root ===
if [[ $EUID -ne 0 ]]; then
  echo "Script ini harus dijalankan sebagai root!"
  exit 1
fi

# === Update dan Install Dependensi ===
apt update -y && apt install curl socat cron unzip tar iptables jq -y

# === Install Xray Core ===
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# === Install acme.sh ===
curl https://get.acme.sh | sh
source ~/.bashrc
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# === Request SSL Wildcard via DNS Cloudflare ===
~/.acme.sh/acme.sh --issue --dns dns_cf -d "$domain" -d "*.$domain" -k ec-256 \
  --key-file "$cert_dir/xray.key" \
  --fullchain-file "$cert_dir/xray.crt" --force

# === Buat trojan-clients.json ===
mkdir -p /etc/xray
cat > "$clients_file" <<EOF
[
  {
    "password": "$default_password",
    "email": "$default_email",
    "expired": "$expired_default"
  }
]
EOF

# === Buat config.json Xray ===
clients_json=$(jq -c '.' "$clients_file")
cat > "$config_file" <<EOF
{
  "log": { "loglevel": "info" },
  "inbounds": [
    {
      "port": 443,
      "protocol": "trojan",
      "settings": {
        "clients": $clients_json
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
        "wsSettings": { "path": "/trojan-ws" }
      }
    },
    {
      "port": 80,
      "protocol": "trojan",
      "settings": {
        "clients": $clients_json
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "/trojan-ws" }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
EOF

# === Script Pengecekan Akun Expired ===
cat > /usr/local/bin/check-trojan-expired.sh <<'EOF'
#!/bin/bash
clients_file="/etc/xray/trojan-clients.json"
config_file="/etc/xray/config.json"
today=$(date +%F)
changed=false
temp_clients=()

for row in $(jq -c '.[]' "$clients_file"); do
    expired=$(echo "$row" | jq -r '.expired')
    if [[ "$expired" < "$today" ]]; then
        echo "Menghapus expired: $(echo "$row" | jq -r '.email') ($expired)"
        changed=true
    else
        temp_clients+=("$row")
    fi
done

if \$changed; then
    updated_clients=$(printf "%s\n" "${temp_clients[@]}" | jq -s '.')
    jq --argjson clients "$updated_clients" '
      .inbounds[0].settings.clients = $clients |
      .inbounds[1].settings.clients = $clients
    ' "$config_file" > /tmp/config-new.json && mv /tmp/config-new.json "$config_file"
    printf "%s\n" "${temp_clients[@]}" | jq -s '.' > "$clients_file"
    systemctl restart xray
fi
EOF

chmod +x /usr/local/bin/check-trojan-expired.sh

# === Tambahkan Cron Job Harian ===
echo "0 0 * * * root /usr/local/bin/check-trojan-expired.sh" > /etc/cron.d/trojan_expired

# === Atur Firewall dan Restart ===
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
netfilter-persistent save
systemctl daemon-reload
systemctl enable xray
systemctl restart xray

# === Output Informasi ===
clear
echo "===================================="
echo "Trojan VPN berhasil diinstal!"
echo "Domain       : $domain"
echo "Port TLS     : 443"
echo "Port Non-TLS : 80"
echo "Path         : /trojan-ws"
echo "Password     : $default_password"
echo "Expired      : $expired_default"
echo "===================================="
echo "URL TLS:"
echo "trojan://$default_password@$domain:443?type=ws&security=tls&path=/trojan-ws#TrojanTLS"
echo ""
echo "URL Non-TLS:"
echo "trojan://$default_password@$domain:80?type=ws&security=none&path=/trojan-ws#TrojanNoTLS"
echo "===================================="

# === Tambah Akun Manual Jika Diinginkan ===
read -p "Ingin menambahkan akun Trojan baru sekarang? (y/n): " jawab
if [[ "$jawab" == "y" || "$jawab" == "Y" ]]; then
  read -p "Masukkan email/nama akun: " email
  read -p "Masukkan password (biarkan kosong untuk random): " password
  if [[ -z "$password" ]]; then
    password=$(openssl rand -hex 6)
  fi
  read -p "Masa aktif akun (hari): " days
  expired=$(date -d "+$days days" +%F)

  new_client=$(jq -n \
    --arg email "$email" \
    --arg password "$password" \
    --arg expired "$expired" \
    '{email: $email, password: $password, expired: $expired}')

  tmp_clients=$(mktemp)
  jq ". + [\$new_client]" "$clients_file" > "$tmp_clients" && mv "$tmp_clients" "$clients_file"

  updated_clients=$(jq -c '.' "$clients_file")
  jq --argjson clients "$updated_clients" '
    .inbounds[0].settings.clients = $clients |
    .inbounds[1].settings.clients = $clients
  ' "$config_file" > /tmp/config-new.json && mv /tmp/config-new.json "$config_file"

  systemctl restart xray

  echo ""
  echo "✅ Akun berhasil ditambahkan!"
  echo "Email/Nama : $email"
  echo "Password   : $password"
  echo "Expired    : $expired"
  echo ""
  echo "Link TLS:"
  echo "trojan://$password@$domain:443?type=ws&security=tls&path=/trojan-ws#$email"
  echo "Link Non-TLS:"
  echo "trojan://$password@$domain:80?type=ws&security=none&path=/trojan-ws#$email"
  echo ""
fi

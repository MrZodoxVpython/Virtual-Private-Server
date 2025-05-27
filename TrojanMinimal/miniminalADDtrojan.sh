#!/bin/bash

clients_file="/etc/xray/trojan-clients.json"
config_file="/etc/xray/config.json"
domain="yourdomain.com"

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
jq ". + [$new_client]" "$clients_file" > "$tmp_clients" && mv "$tmp_clients" "$clients_file"

updated_clients=$(jq -c '.' "$clients_file")
jq --argjson clients "$updated_clients" '
  .inbounds[0].settings.clients = $clients |
  .inbounds[1].settings.clients = $clients
' "$config_file" > /tmp/config-new.json && mv /tmp/config-new.json "$config_file"

systemctl restart xray

echo "✅ Akun berhasil ditambahkan!"
echo "Email/Nama : $email"
echo "Password   : $password"
echo "Expired    : $expired"
echo ""
echo "Link TLS:"
echo "trojan://$password@$domain:443?type=ws&security=tls&path=/trojan-ws#$email"
echo "Link Non-TLS:"
echo "trojan://$password@$domain:80?type=ws&security=none&path=/trojan-ws#$email"

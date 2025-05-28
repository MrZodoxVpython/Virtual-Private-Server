#!/bin/bash

clients_file="/etc/xray/trojan-clients.json"
config_file="/etc/xray/config.json"

if [[ ! -f "$clients_file" ]]; then
  echo "File clients tidak ditemukan: $clients_file"
  exit 1
fi

# Tampilkan daftar akun
echo "Daftar akun Trojan:"
jq -r 'to_entries | .[] | "\(.key + 1). \(.value.email) (Expired: \(.value.expired))"' "$clients_file"

read -p "Masukkan nomor atau nama user/email akun yang ingin diperpanjang: " input

total=$(jq length "$clients_file")

# Fungsi untuk menemukan index akun dari input
get_index() {
  local inp="$1"
  if [[ "$inp" =~ ^[0-9]+$ ]]; then
    # Input angka
    if (( inp >= 1 && inp <= total )); then
      echo $((inp - 1))
      return 0
    else
      return 1
    fi
  else
    # Input string, cari cocok email (case insensitive)
    idx=$(jq -r --arg user "$inp" 'to_entries | map(select(.value.email|ascii_downcase == ($user|ascii_downcase))) | .[0].key' "$clients_file")
    if [[ "$idx" =~ ^[0-9]+$ ]]; then
      echo "$idx"
      return 0
    else
      return 1
    fi
  fi
}

index=$(get_index "$input")
if [[ $? -ne 0 ]]; then
  echo "User/nomor akun tidak ditemukan!"
  exit 1
fi

old_expired=$(jq -r ".[$index].expired" "$clients_file")
old_email=$(jq -r ".[$index].email" "$clients_file")

echo "Masa expired sekarang: $old_expired"
read -p "Masukkan tambahan masa aktif (hari): " tambahan

if ! [[ "$tambahan" =~ ^[0-9]+$ ]]; then
  echo "Input hari tidak valid!"
  exit 1
fi

today=$(date +%F)
if [[ "$old_expired" < "$today" ]]; then
  base_date="$today"
else
  base_date="$old_expired"
fi

new_expired=$(date -d "$base_date + $tambahan days" +%F)

tmpfile=$(mktemp)
jq --arg new_expired "$new_expired" --argjson idx "$index" \
  '.[ $idx ].expired = $new_expired' "$clients_file" > "$tmpfile" && mv "$tmpfile" "$clients_file"

updated_clients=$(jq -c '.' "$clients_file")
jq --argjson clients "$updated_clients" '
  .inbounds[0].settings.clients = $clients |
  .inbounds[1].settings.clients = $clients
' "$config_file" > /tmp/config-new.json && mv /tmp/config-new.json "$config_file"

systemctl restart xray

echo "✅ Masa aktif akun \"$old_email\" berhasil diperpanjang!"
echo "Tanggal expired baru: $new_expired"

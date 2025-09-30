#!/usr/bin/env bash
set -euo pipefail

CONFIG="/etc/xray/config.json"
SERVICE_NAME="xray"

clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          ⇱ Renew Vmess ⇲"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$CONFIG" || true)
if [[ "$NUMBER_OF_CLIENTS" -eq 0 ]]; then
    echo "You have no existing clients!"
    echo
    read -n1 -s -r -p "Press any key to back on menu"
    m-vmess
    exit 0
fi

grep -E "^### " "$CONFIG" | awk '{print $2, $3}' | sort -u | column -t
echo
echo -e "\033[31mTap Enter to go back\033[0m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -rp "Input Username : " user
if [[ -z "$user" ]]; then
    m-vmess
    exit 0
fi

# cek semua baris user
cek_user_lines=$(awk -v u="$user" '$1=="###" && $2==u {print $0}' "$CONFIG")
if [[ -z "$cek_user_lines" ]]; then
    echo "User not found!"
    read -n1 -s -r -p "Press any key to back on menu"
    m-vmess
    exit 1
fi

# ambil tanggal expired pertama (anggap semua sama)
current_exp=$(echo "$cek_user_lines" | head -n1 | awk '{print $3}')
if ! date -d "$current_exp" >/dev/null 2>&1; then
    echo "Tanggal kadaluarsa tidak valid: $current_exp"
    exit 1
fi

read -rp "Expired (days): " masaaktif
if ! [[ "$masaaktif" =~ ^[0-9]+$ ]] || [[ "$masaaktif" -le 0 ]]; then
    echo "Masukkan angka hari yang valid (>0)."
    exit 1
fi

today=$(date +%Y-%m-%d)
if [[ $(date -d "$current_exp" +%s) -gt $(date -d "$today" +%s) ]]; then
    new_exp=$(date -d "$current_exp + $masaaktif days" +%Y-%m-%d)
else
    new_exp=$(date -d "$today + $masaaktif days" +%Y-%m-%d)
fi

# backup
cp -a "$CONFIG" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

# ganti semua baris user
tmpfile=$(mktemp)
awk -v u="$user" -v ne="$new_exp" '
  {
    if ($1=="###" && $2==u) {
      print "### " u " " ne
    } else {
      print $0
    }
  }
' "$CONFIG" > "$tmpfile"

mv "$tmpfile" "$CONFIG"

systemctl restart "$SERVICE_NAME" >/dev/null 2>&1 || true

clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " VMESS Account Was Successfully Renewed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo " Client Name : $user"
echo " Expired On  : $new_exp"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
read -n1 -s -r -p "Press any key to back on menu"
m-vmess

#!/bin/bash
#===================++++===================#
# AUTHOR    : BENJAMIN.WICKMAN
# TELEGRAM  : MrZodoxVpython
# DISCORD   : benjaminwickman
# INSTA     : benjamin.wickman
# SUPPORTER : TOKOMARD
#===================++++===================#
# Warna output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Cek permission IP
MYIP=$(wget -qO- ipv4.icanhazip.com)
IZIN=$(curl -s https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini | grep -w "$MYIP")
if [[ -z "$IZIN" ]]; then
    echo -e "${RED}Permission Denied!${NC}"
    exit 0
fi

echo -e "${GREEN}Permission Accepted...${NC}"
clear

# Waktu sekarang dikurangi 10 dan 1 menit (format YYYY/MM/DD HH:MM:SS tanpa mikrodetik)
time_10min_ago=$(date -d '10 minutes ago' '+%Y/%m/%d %H:%M:%S')
time_1min_ago=$(date -d '1 minutes ago' '+%Y/%m/%d %H:%M:%S')

echo "-----------------------------------------"
echo "----------=[ User VLESS Aktif ]=----------"
echo "-----------------------------------------"

vless_users=()

# Ambil list user VLESS dari config.json (tag #& username)
while IFS= read -r user; do
    if [[ -n "$user" ]]; then
        vless_users+=("$user")
        # Cek aktif dalam 1 menit terakhir dengan hilangkan mikrodetik di log
        is_active=$(awk -v user="$user" -v start="$time_1min_ago" '
        {
            split($2, t, ".")
            timestamp = $1 " " t[1]
            if (timestamp > start && $0 ~ "email: " user) {
                print "yes"; exit
            }
        }' /var/log/xray/access.log)

        if [[ "$is_active" == "yes" ]]; then
            status="${GREEN}Aktif${NC}"
        else
            status="${RED}Tidak Aktif${NC}"
        fi

        echo -e " $(printf '%-20s' "$user") [$status]"
    fi
done < <(grep -oP '^#&\s+\K\S+' /etc/xray/config.json | sort -u)

echo "-----------------------------------------"
echo "------=[ Detail Login User VLESS ]=-------"
echo "-----------------------------------------"

found_any=0

for user in "${vless_users[@]}"; do
    # Ambil log koneksi user dalam 10 menit terakhir, hilangkan mikrodetik
    user_lines=$(awk -v user="$user" -v start="$time_10min_ago" '
    {
        split($2, t, ".")
        timestamp = $1 " " t[1]
        if (timestamp > start && $0 ~ "email: " user) print $0
    }' /var/log/xray/access.log | tail -40)

    if [[ -n "$user_lines" ]]; then
        found_any=1
        echo "User : $user"
        echo "$user_lines" | awk '
        {
            split($3, ip_port, ":");
            client_ip = ip_port[1];
            proto_field = $5;
            split(proto_field, proto_parts, ":");
            proto = proto_parts[1];
            host = proto_parts[2];
            port = proto_parts[3];
            printf " %s - Protocol: %s - Host: %s - Port: %s\n", client_ip, proto, host, port;
        }'
        echo "-----------------------------------------"
    fi
done

if [[ $found_any -eq 0 ]]; then
    echo "Tidak ada koneksi aktif yang ditemukan untuk user VLESS dalam 10 menit terakhir."
fi

echo ""
echo "Lihat access.log Xray secara real-time?"
echo "1) Ya, buka dengan less"
read -n 1 -s -r -p "Pilih [1] atau tekan tombol lain untuk keluar: " choice

if [[ "$choice" == "1" ]]; then
    echo ""
    echo -e "${GREEN}Membuka log: Tekan Ctrl+C untuk berhenti, lalu tekan q untuk kembali ke menu.${NC}"
    sleep 2
    less +F /var/log/xray/access.log
fi

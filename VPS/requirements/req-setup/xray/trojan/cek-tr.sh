#!/bin/bash
#===================++++===================#
# AUTHOR    : BENJAMIN.WICKMAN
# TELEGRAM  : MrZodoxVpython
# DISCORD   : benjaminwickman
# INSTA     : benjamin.wickman
# SUPPORTER : TOKOMARD
#===================++++===================#
# Konfigurasi warna
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'

# --- Colored Output Functions ---
green()    { echo -e "\033[32;1m${*}\033[0m"; }
red()      { echo -e "\033[31;1m${*}\033[0m"; }
yellow()   { echo -e "\033[33;1m${*}\033[0m"; }
tyblue()   { echo -e "\033[36;1m${*}\033[0m"; }
purple()   { echo -e "\033[35;1m${*}\033[0m"; }

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'


# Getting Ip Permit
MYIP=$(wget -qO- ipv4.icanhazip.com)
IZIN=$(curl -s https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini | grep -w "$MYIP")
if [[ -z "$IZIN" ]]; then
    echo -e "${RED}Permission Denied!${NC}"
    exit 0
fi

echo -e "${GREEN}Permission Accepted...${NC}"
clear

# Ambil waktu 10 menit lalu dalam format YYYY/MM/DD HH:MM:SS
time_10min_ago=$(date -d '10 minutes ago' '+%Y/%m/%d %H:%M:%S')
time_1min_ago=$(date -d '1 minutes ago' '+%Y/%m/%d %H:%M:%S')

# Menampilkan daftar user beserta status aktif/tidak
echo "-----------------------------------------"
echo "-----------=[ Daftar User ]=-------------"
echo "-----------------------------------------"

trojan_users=()
while IFS= read -r user; do
    if [[ -n "$user" ]]; then
        trojan_users+=("$user")
        # Cek apakah user aktif (ada log dalam 10 menit terakhir)
        is_active=$(awk -v user="$user" -v start="$time_1min_ago" '
        {
            timestamp = $1 " " $2;
            if (timestamp > start && $0 ~ "email: " user) {
                print "yes"; exit;
            }
        }' /var/log/xray/access.log)

        if [[ "$is_active" == "yes" ]]; then
            status="${GREEN}Aktif${NC}"
        else
            status="${RED}Tidak Aktif${NC}"
        fi

        echo -e " $(printf '%-20s' "$user") [$status]"
    fi
done < <(grep -oP '^#!\s+\K\S+' /etc/xray/config.json | sort -u)

echo "-----------------------------------------"
echo "---------=[ Trojan User Login ]=---------"
echo "-----------------------------------------"

found_any=0

for user in "${trojan_users[@]}"; do
    # Filter log untuk user + waktu > 10 menit lalu
    user_lines=$(awk -v user="$user" -v start="$time_10min_ago" '
    {
        timestamp = $1 " " $2;
        if (timestamp > start && $0 ~ "email: " user) print $0;
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
    echo "Tidak ada koneksi aktif yang ditemukan untuk user Trojan dalam 10 menit terakhir."
fi

# Tampilkan IP lain yang tidak terkait Trojan
all_ips=($(awk -v start="$time_10min_ago" '
    {
        timestamp = $1 " " $2;
        if (timestamp > start) {
            split($3,a,":");
            print a[1];
        }
    }' /var/log/xray/access.log | sort -u))

trojan_ips=($(awk -v start="$time_10min_ago" -v userlist="$(IFS=\|; echo "${trojan_users[*]}")" '
    {
        timestamp = $1 " " $2;
        if (timestamp > start && $0 ~ "email: ("userlist")") {
            split($3,a,":");
            print a[1];
        }
    }' /var/log/xray/access.log | sort -u))

other_ips=()
for ip in "${all_ips[@]}"; do
    skip=0
    for tip in "${trojan_ips[@]}"; do
        [[ "$ip" == "$tip" ]] && skip=1 && break
    done
    [[ $skip -eq 0 ]] && other_ips+=("$ip")
done

echo "Other IPs (tidak terkait user Trojan dalam 10 menit terakhir):"
if [[ ${#other_ips[@]} -eq 0 ]]; then
    echo "Tidak ada IP lain yang aktif."
else
    printf "%5s  %s\n" "No." "IP Address"
    for i in "${!other_ips[@]}"; do
        printf "%5d  %s\n" $((i+1)) "${other_ips[$i]}"
    done
fi

echo "-----------------------------------------"
echo ""
echo "Lihat access.log Xray secara real-time?"
echo "1) Ya, buka dengan less"
read -n 1 -s -r -p "Pilih [1] or press any key untuk kembali ke menu: " choice

if [[ "$choice" == "1" ]]; then
    echo ""
    echo -e "${GREEN}Membuka log: Tekan Ctrl+C untuk berhenti, lalu tekan q untuk kembali ke menu.${NC}"
    sleep 5
    less +F /var/log/xray/access.log
fi

m-trojan

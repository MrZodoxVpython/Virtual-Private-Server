#!/bin/bash
#BENJAMIN-WICKMAN
#TOKOMARD
#MRZODOXVPYTHON

# Warna
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
IZIN=$(curl -s https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini | grep -w "$MYIP")

if [[ -z "$IZIN" ]]; then
    echo -e "${RED}Permission Denied!${NC}"
    exit 0
fi

echo -e "${GREEN}Permission Accepted...${NC}"
clear

# Ambil user Trojan
trojan_users=($(grep -oP '^#!\s+\K\S+' /etc/xray/config.json | sort -u))

echo "-----------------------------------------"
echo "---------=[ Trojan User Login ]=---------"
echo "-----------------------------------------"

found_any=0

for user in "${trojan_users[@]}"; do
    # Cari di access.log semua koneksi yang pakai user ini
    user_lines=$(grep -w "email: $user" /var/log/xray/access.log)

    if [[ -n "$user_lines" ]]; then
        found_any=1
        echo "User : $user"
        # Print IP - Protocol - Host - Port
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
        }' | sort | uniq
        echo "-----------------------------------------"
    fi
done

if [[ $found_any -eq 0 ]]; then
    echo "Tidak ada koneksi aktif yang ditemukan untuk user Trojan."
fi

# Cari IP lain yang tidak terkait user Trojan
# Ambil semua IP client unik di access.log
all_ips=($(awk '{split($3,a,":"); print a[1]}' /var/log/xray/access.log | sort -u))

# Ambil IP dari user Trojan
trojan_ips=($(grep -w -E "$(IFS=\|; echo "${trojan_users[*]}")" /var/log/xray/access.log | awk '{split($3,a,":"); print a[1]}' | sort -u))

# Cari IP yang ada di all_ips tapi tidak di trojan_ips
other_ips=()
for ip in "${all_ips[@]}"; do
    skip=0
    for tip in "${trojan_ips[@]}"; do
        if [[ "$ip" == "$tip" ]]; then
            skip=1
            break
        fi
    done
    if [[ $skip -eq 0 ]]; then
        other_ips+=("$ip")
    fi
done

echo "Other IPs (tidak terkait user Trojan):"
if [[ ${#other_ips[@]} -eq 0 ]]; then
    echo "Tidak ada IP lain yang aktif."
else
    printf "%5s  %s\n" "No." "IP Address"
    for i in "${!other_ips[@]}"; do
        printf "%5d  %s\n" $((i+1)) "${other_ips[$i]}"
    done
fi

echo "-----------------------------------------"

read -n 1 -s -r -p "Press any key to back on menu"
m-trojan

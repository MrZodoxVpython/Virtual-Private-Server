#!/bin/bash

# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS..."
IZIN=$(curl -s ipv4.icanhazip.com | grep "$MYIP")

if [[ "$MYIP" == "$MYIP" ]]; then
    echo -e "${NC}${GREEN}Permission Accepted...${NC}"
else
    echo -e "${NC}${RED}Permission Denied!${NC}"
    exit 0
fi

clear
> /tmp/other.txt

# Ganti pencarian akun dari tag `#&#` ke `#!`
data=($(grep -oP '^#!\s+\K\S+' /etc/xray/config.json))

echo "-----------------------------------------"
echo "---------=[ Trojan User Login ]=---------"
echo "-----------------------------------------"

for akun in "${data[@]}"; do
    [[ -z "$akun" ]] && akun="tidakada"

    > /tmp/iptrojan.txt

    # Ambil IP yang sedang terhubung ke Xray
    data2=($(netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | awk '{print $5}' | cut -d: -f1 | sort -u))

    for ip in "${data2[@]}"; do
        jum=$(grep -w "$akun" /var/log/xray/access.log | awk '{print $3}' | cut -d: -f1 | grep -w "$ip" | sort -u)

        if [[ "$jum" == "$ip" ]]; then
            echo "$jum" >> /tmp/iptrojan.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi

        jum2=$(< /tmp/iptrojan.txt)
        sed -i "/$jum2/d" /tmp/other.txt >/dev/null 2>&1
    done

    jum=$(< /tmp/iptrojan.txt)
    if [[ -n "$jum" ]]; then
        echo "user : $akun"
        nl /tmp/iptrojan.txt
        echo "-----------------------------------------"
    fi

    rm -f /tmp/iptrojan.txt
done

# Tampilkan IP selain dari akun yang dikenali
oth=$(sort -u /tmp/other.txt | nl)
echo "other"
if [[ -n "$oth" ]]; then
    echo "$oth"
else
    echo "Tidak ada IP lain yang aktif."
fi
echo "-----------------------------------------"
echo ""
rm -f /tmp/other.txt

read -n 1 -s -r -p "Press any key to back on menu"
m-trojan

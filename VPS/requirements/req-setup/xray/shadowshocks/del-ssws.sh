#!/bin/bash
#Benjamin-Dev

#==========================================
# Warna
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
LIGHT='\033[0;37m'
#==========================================

# Cek IP VPS
MYIP=$(wget -qO- ipv4.icanhazip.com)
IZIN=$(curl -s ipv4.icanhazip.com | grep "$MYIP")
if [[ "$MYIP" == "$MYIP" ]]; then
    echo -e "${NC}${GREEN}Permission Accepted...${NC}"
else
    echo -e "${NC}${RED}Permission Denied!${NC}"
    echo -e "${NC}${LIGHT}Fuck You!!"
    exit 0
fi

# Cek jumlah akun SS
NUMBER_OF_CLIENTS=$(grep -cE '^#\$ ' "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m       Delete Sodosok Account      \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "You have no existing clients!"
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -n 1 -s -r -p "Press any key to back on menu"
    m-ssws
    exit 0
fi

# Tampilkan daftar user unik
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m       Delete Sodosok Account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "  User       Expired  "
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
grep -E '^#\$ [a-zA-Z0-9_]+ [0-9]{4}-[0-9]{2}-[0-9]{2}$' /etc/xray/config.json \
    | awk '!seen[$2]++ { print $2, $3 }' | column -t | sort
echo ""
echo -e "  • [NOTE] Press any key to back on menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Input username
read -rp "Input Username : " user
if [[ -z $user ]]; then
    m-ssws
    exit 0
fi

# Ambil tanggal expired yang sesuai
exp=$(grep -E "^#\\$ ${user} [0-9]{4}-[0-9]{2}-[0-9]{2}$" /etc/xray/config.json | awk '{print $3}' | head -n1)

# Validasi jika tidak ditemukan
if [[ -z "$exp" ]]; then
    echo -e "${RED}User not found!${NC}"
    read -n 1 -s -r -p "Press any key to back on menu"
    m-ssws
    exit 0
fi

# Hapus semua entri akun berdasarkan tag + tanggal
sed -i "/^#\\$ ${user} ${exp}/,/^},{/d" /etc/xray/config.json

# Restart layanan
systemctl restart xray > /dev/null 2>&1

# Tampilkan konfirmasi
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m       Delete Sodosok Account      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "   • Account Deleted Successfully"
echo -e ""
echo -e "   • Client Name : $user"
echo -e "   • Expired On  : $exp"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
m-ssws

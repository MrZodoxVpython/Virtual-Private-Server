#!/bin/bash
#BENJAMINWICKMAN
#MRZODOXVPYTHON-DEV
#TOKOMARD

MYIP=$(wget -qO- ipv4.icanhazip.com)
echo "Checking VPS"
clear

NUMBER_OF_CLIENTS=$(grep -c -E "^#! " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "  • You don't have any existing clients!"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo ""
  read -n 1 -s -r -p "   Press any key to back on menu"
  m-trojan
fi

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m           ⇱ Delete Trojan Account ⇲           \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Header kolom
printf "%-3s %-30s %s\n" "No" "Username/Email" "Expired"
echo "-----------------------------------------------"

# Loop daftar client dan format output agar expired rata kanan
i=1
grep -E "^#! " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | sort | uniq | while read -r user exp; do
  printf "%-3s %-30s %s\n" "$i" "$user" "$exp"
  ((i++))
done

echo -e ""
echo -e "• [NOTE] Press any key to back on menu"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -rp "  Input Username : " user
if [ -z "$user" ]; then
  m-trojan
else
  exp=$(grep -wE "^#! $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
  sed -i "/^#! $user $exp/,/^},{/d" /etc/xray/config.json
  systemctl restart xray > /dev/null 2>&1
  clear
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "   • Account deleted successfully"
  echo -e ""
  echo -e "   • Client Name : $user"
  echo -e "   • Expired On  : $exp"
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo ""
  read -n 1 -s -r -p "   Press any key to back on menu"
  m-trojan
fi

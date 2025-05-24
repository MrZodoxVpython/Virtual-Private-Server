#!/bin/bash
#TOKOMARD-X-BENJAMINWCIKMAN-MRZODOXVPYTHON

# --- Initial Cleanup & Preparation ---
cd ~
rm -rf install-setup.sh
clear

# --- Define Colors ---
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
BRed='\e[1;31m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
NC='\e[0m'

# --- Colored Output Functions ---
green()    { echo -e "\033[32;1m${*}\033[0m"; }
red()      { echo -e "\033[31;1m${*}\033[0m"; }
yellow()   { echo -e "\033[33;1m${*}\033[0m"; }
tyblue()   { echo -e "\033[36;1m${*}\033[0m"; }
purple()   { echo -e "\033[35;1m${*}\033[0m"; }


cd /root

# --- Root Permission Check ---
if [ "${EUID}" -ne 0 ]; then
  red "Run this script as root bitch!"
  sleep 5
  exit 1
fi

# --- Virtualization Check ---
if [ "$(systemd-detect-virt)" == "openvz" ]; then
  yellow "OpenVZ is not supported on your dumb server!"
  red "This is for VPS with KVM and VMWare virtualization ONLY!"
  sleep 5
  exit 1
fi

# --- Fix /etc/hosts if Needed ---
localip=$(hostname -I | cut -d' ' -f1)
hst=$(hostname)
dart=$(grep -w $(hostname) /etc/hosts | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
  echo "$localip $(hostname)" >> /etc/hosts
fi

# --- Create Config Folders ---
mkdir -p /etc/{xray,v2ray}
touch /etc/{xray,v2ray}/{domain,scdomain}

# --- Kernel Headers Check ---
green"[ NOTES ] I thinks that i want to go....."
sleep 0.5
green "[ NOTES ] But i need to check your headers first..."
sleep 0.5
purple "[ INFO ] Checking the headers and getting pawned to hack...."
sleep 0.8

# --- Install Kernel Headers If Needed ---
totet=$(uname -r)
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "ALL DONE NOW it's installed")
echo "Checking for $REQUIRED_PKG: $PKG_OK"
if [ -z "$PKG_OK" ]; then
  echo -e "[ ${BRed}WARNING${NC} ] Trying to install and injected trojan...."
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  apt-get --yes install $REQUIRED_PKG
  echo -e "[ ${BBlue}NOTES${NC} ] If you get error run this shit:"
  echo -e "[ ${BBlue}NOTES${NC} ] apt update && apt upgrade -y && reboot"
  echo -e "[ ${BBlue}NOTES${NC} ] Done? Then run this script again"
  read -rp "Enter to continue..."
else
  echo -e "[ ${BGreen}INFO${NC} ] === ALL DONE ==="
fi

# --- Recheck Headers ---
ttet=$(uname -r)
ReqPKG="linux-headers-$ttet"
if ! dpkg -s $ReqPKG >/dev/null 2>&1; then
  rm /root/install-setup.sh >/dev/null 2>&1
  exit
else
  clear
fi

# --- Time Tracking ---
to_human_time() {
  echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minutes $(( ${1} % 60 )) seconds"
}
start=$(date +%s)

# --- Timezone & IPv6 Configuration ---
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# --- Install Dependencies ---
echo -e "[ ${BGreen}INFO${NC} ] Preparing the install file"
apt install git curl python -y >/dev/null 2>&1
echo -e "[ ${BGreen}INFO${NC} ] Installation file is ready"
sleep 0.5
echo -e "$BGreen Permission Accepted!$NC"
sleep 2

# --- Prepare Domain Setup ---
mkdir -p /var/lib/ >/dev/null 2>&1
echo "IP=" >> /var/lib/ipvps.conf

clear
echo -e "$BBlue                     SETUP DOMAIN VPS                       $NC"
echo -e "$BYellow----------------------------------------------------------$NC"
echo -e "$BGreen     1. Use Domain Random / Gunakan Domain Random          $NC"
echo -e "$BGreen  2. Choose Your Own Domain / Gunakan Domain Sendiri       $NC"
echo -e "$BYellow----------------------------------------------------------$NC"
read -rp "Input 1 or 2 / Pilih 1 atau 2 : " dns

if [[ $dns -eq 1 ]]; then
  wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/cf.sh && chmod +x cf.sh && ./cf.sh
elif [[ $dns -eq 2 ]]; then
  read -rp "Enter Your Domain / Masukan Domain : " dom
  echo "IP=$dom" > /var/lib/ipvps.conf
  for path in /root/scdomain /etc/xray/scdomain /etc/xray/domain /etc/v2ray/domain /root/domain; do
    echo "$dom" > "$path"
  done
else
  red "Input tidak tersedia! 1/2 only!"
  exit 1
fi

# --- Install Scripts ---
green "=== PROCESS INSTALLING ALL SCRIPT ==="
clear
echo -e "\e[33m-----------------------------------\033[0m"
echo -e "$BGreen     Installing SSH Websocket         $NC"
echo -e "\e[33m-----------------------------------\033[0m"
sleep 0.5
clear
wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/insshws.sh && chmod +x insshws.sh && ./insshws.sh
tyblue "ALL DONE BY BENJAMIN-DEV"

clear
echo -e "\e[33m-----------------------------------\033[0m"
echo -e "$BGreen         Installing XRAY              $NC"
echo -e "\e[33m-----------------------------------\033[0m"
sleep 0.5
green "=== STARTED THE INSTALATION ==="
clear
wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
tyblue "=== ALL INSTALATION IS COMPLETE, PROCESSING FINISHING THE INSTALATION ==="

# --- Finalization ---
green "=== FINISHING THE INSTALATION SETUP ==="
cat > /root/.profile << END
if [ "\$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile

# --- Clean Logs ---
green "=== CLEARING LOGS ==="
rm -f /root/log-install.txt /etc/afak.conf
for log in ssh vmess vless trojan shadowsocks; do
  touch "/etc/log-create-${log}.log"
  echo "Log ${log^} Account " > "/etc/log-create-${log}.log"
done

# --- Versioning and Reboot ---
green "=== STARTED VERSIONING AND REBOOT ==="
history -c
curl -sS https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/versi > /opt/.ver
curl -sS ipv4.icanhazip.com > /etc/myipvps

to_human_time "$(( $(date +%s) - ${start} ))"
green "=== ALL DONE TTD BENJAMINWICKMAN-TOKOMARD-DEV ==="
tyblue "Auto reboot in 10 Seconds"
sleep 10
reboot

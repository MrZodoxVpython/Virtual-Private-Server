#!/bin/bash

# ========================== UI FX FOR INSTALLATION ==========================
ui_title="INSTALLATION - VPS SETUP WIZARD by BENJAMINWICKMAN-TOKOMARD-DEV"
ui_border="================================================================================"
ui_loading="|/-\\"

ui_print_centered() {
  term_width=$(tput cols)
  text_length=${#1}
  padding=$(( (term_width - text_length) / 2 ))
  printf "%*s%s\n" $padding "" "$1"
}

ui_banner() {
  clear
  echo -e "\e[1;32m$ui_border\e[0m"
  ui_print_centered "$ui_title"
  echo -e "\e[1;32m$ui_border\e[0m"
  echo
}

ui_progress() {
  local duration=${1:-5}
  local end_time=$((SECONDS+duration))
  local i=0
  while [ $SECONDS -lt $end_time ]; do
    i=$(( (i+1) %4 ))
    printf "\r[\e[1;36m%s\e[0m] Installing... %s" "$ui_title" "${ui_loading:$i:1}"
    sleep 0.2
  done
  printf "\r\e[1;32m✔\e[0m Done installing: $2\n"
}

ui_start_block() {
  echo -e "\n\e[1;33m[$(date +%H:%M:%S)] Starting: $1\e[0m"
  sleep 0.5
}

ui_end_block() {
  echo -e "\e[1;32m[$(date +%H:%M:%S)] Finished: $1\e[0m"
  echo
  sleep 0.3
}

# ========================== START INSTALLATION =============================
ui_banner
sleep 1

# Bagian awal: bersih-bersih dan deklarasi warna
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
purple() { echo -e "\033[35;1m${*}\033[0m"; }
tyblue() { echo -e "\033[36;1m${*}\033[0m"; }
yellow() { echo -e "\033[33;1m${*}\033[0m"; }
green()  { echo -e "\033[32;1m${*}\033[0m"; }
red()    { echo -e "\033[31;1m${*}\033[0m"; }

cd /root

# --- Check Permissions ---
if [ "${EUID}" -ne 0 ]; then
  red "You need to run this script as root"
  sleep 5
  exit 1
fi

# --- Virtualization Check ---
if [ "$(systemd-detect-virt)" == "openvz" ]; then
  red "OpenVZ is not supported"
  yellow "Only KVM or VMware virtualization is allowed"
  sleep 5
  exit 1
fi

# --- Fix /etc/hosts if Necessary ---
localip=$(hostname -I | cut -d' ' -f1)
hst=$(hostname)
dart=$(grep -w $(hostname) /etc/hosts | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
  echo "$localip $(hostname)" >> /etc/hosts
fi

# --- Create Config Folders ---
ui_start_block "Creating config directories"
mkdir -p /etc/{xray,v2ray}
touch /etc/{xray,v2ray}/{domain,scdomain}
ui_end_block "Config directories created"

# --- Check and Install Kernel Headers ---
ui_start_block "Checking kernel headers"
totet=$(uname -r)
REQUIRED_PKG="linux-headers-$totet"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG | grep "install ok installed")

if [ -z "$PKG_OK" ]; then
  red "$REQUIRED_PKG not found. Installing..."
  apt-get --yes install $REQUIRED_PKG >/dev/null 2>&1
  yellow "If installation fails, run: apt update && apt upgrade -y && reboot"
  read -rp "Press Enter to continue..."
else
  green "Headers already installed."
fi

# --- Final Check and Clear ---
if ! dpkg -s $REQUIRED_PKG >/dev/null 2>&1; then
  rm /root/install-setup.sh >/dev/null 2>&1
  exit
else
  clear
fi

# --- Time Calculation Function ---
to_human_time() {
  echo "Installation time : $(( $1 / 3600 )) hours $(( ($1 / 60) % 60 )) minutes $(( $1 % 60 )) seconds"
}
start=$(date +%s)

# --- Set Timezone and Disable IPv6 ---
ui_start_block "Setting timezone & disabling IPv6"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
ui_end_block "System config set"

# --- Install Dependencies ---
ui_start_block "Installing dependencies"
apt install -y git curl python >/dev/null 2>&1
ui_end_block "Dependencies installed"

# --- Prepare Domain Setup ---
mkdir -p /var/lib/
echo "IP=" > /var/lib/ipvps.conf

clear
echo -e "$BBlue SETUP DOMAIN VPS $NC"
echo -e "$BYellow----------------------------------------------------------$NC"
echo -e "$BGreen 1. Use Domain Random$NC"
echo -e "$BGreen 2. Use Your Own Domain$NC"
echo -e "$BYellow----------------------------------------------------------$NC"
read -rp "Choose 1 or 2: " dns

if [[ $dns -eq 1 ]]; then
  ui_progress 3 "Cloudflare Setup"
  wget -qO cf.sh https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/cf.sh
  chmod +x cf.sh && ./cf.sh
elif [[ $dns -eq 2 ]]; then
  read -rp "Enter your domain: " dom
  echo "IP=$dom" > /var/lib/ipvps.conf
  for path in /root/scdomain /etc/xray/scdomain /etc/xray/domain /etc/v2ray/domain /root/domain; do
    echo "$dom" > "$path"
  done
else
  echo "Invalid option"
  exit 1
fi

# --- Install Scripts ---
ui_start_block "Installing SSH Websocket"
wget -qO ssh-vpn.sh https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ssh-vpn.sh
chmod +x ssh-vpn.sh && ./ssh-vpn.sh
wget -qO insshws.sh https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/insshws.sh
chmod +x insshws.sh && ./insshws.sh
ui_end_block "SSH Websocket installed"

ui_start_block "Installing XRAY"
wget -qO ins-xray.sh https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ins-xray.sh
chmod +x ins-xray.sh && ./ins-xray.sh
ui_end_block "XRAY installed"

# --- Finalization ---
cat > /root/.profile << 'EOF'
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
mesg n || true
clear
menu
EOF
chmod 644 /root/.profile

# --- Clean Logs ---
echo "Clearing logs..."
rm -f /root/log-install.txt /etc/afak.conf
for log in ssh vmess vless trojan shadowsocks; do
  touch "/etc/log-create-${log}.log"
  echo "Log ${log^} Account" > "/etc/log-create-${log}.log"
  sleep 0.1
  ui_progress 1 "Log created for $log"
done

# --- Versioning and Final Steps ---
history -c
curl -sS https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/versi > /opt/.ver
curl -sS ipv4.icanhazip.com > /etc/myipvps

# --- Show Total Time ---
to_human_time $(( $(date +%s) - start ))

ui_banner
echo "\e[1;32m=== SETUP COMPLETE. BY BENJAMINWICKMAN-TOKOMARD-DEV ===\e[0m"
echo "\e[1;31mSystem will reboot in 10 seconds...\e[0m"
sleep 10
reboot

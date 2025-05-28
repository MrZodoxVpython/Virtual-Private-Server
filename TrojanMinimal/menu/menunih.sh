#!/bin/bash

# Warna
green='\e[0;32m'
cyan='\e[0;36m'
yellow='\e[0;33m'
red='\e[0;31m'
blue='\e[0;34m'
bold='\e[1m'
reset='\e[0m'

# Informasi statis
ISP="AMAZON-02"
RAM="30.47%"
CPU="1.56%"
CLIENT="niku - Aws"
EXPIRED="Thu Jun 26 06:29:17 WIB 2025"
STATUS="Kalo ada bug atau tanya di https://t.me/MrZodoxVpython"
VERSION="1.0.6 ( Up to date )"

# Status layanan
TODAY_USAGE="14.08 GiB"
MONTHLY_USAGE="14.08 GiB"

SSH=0
VMESS=2
VLESS=0
TROJAN=0
SHADOWSOCKS=0

SS=SSH
VM=VMESS
VL=VLESS
TR=TROJAN
SH=SHADOWSOCKS

clear
echo -e "${blue}• ISP                ${reset}= $ISP"
echo -e "${blue}• Server Resource    ${reset}= RAM = $RAM | CPU = $CPU"
echo -e "${blue}• Clients Name       ${reset}= $CLIENT"
echo -e "${blue}• Expired Script VPS ${reset}= $EXPIRED"
echo -e "${blue}• Status Hari ini    ${reset}= $STATUS"
echo -e "${blue}• Script Version     ${reset}= $VERSION"
echo ""

# Kotak Status
echo -e "${red}┌──────────────────────────────────────────────────────────────┐${reset}"
echo ""
echo -e "${red}${reset}  [ SSH WebSocket: ON ] [ NGINX: ON ] [ Today   : ${blue}$TODAY_USAGE${reset} ] ${red}"
echo -e "${red}${reset}  [ XRAY         : ON ]               [ Monthly : ${blue}$MONTHLY_USAGE${reset} ]         ${red}${reset}"
echo ""

# Jumlah akun
echo -e "${red}┌──────────────────────────────────────────────────────────────┐${reset}"
echo -e "${red}│                                                              │${reset}"
printf "${red}│${reset} ${yellow}%-10s${reset} ${yellow}%-10s${reset} ${yellow}%-10s${reset} ${yellow}%-10s${reset} ${yellow}%-10s${reset} ${red}     │${reset}\n" "     $SS" "   $VM" "  $VL" " $TR" "$SH"
printf "${red}│${reset} %-10s %-10s %-10s %-10s %-10s ${red}      │${reset}\n" "      $SSH" "     $VMESS" "    $VLESS" "    $TROJAN" "     $SHADOWSOCKS"
echo -e "${red}│                                                              │${reset}"
echo -e "${red}└──────────────────────────────────────────────────────────────┘${reset}"

# Definisikan warna
red='\e[31m'
yellow='\e[33m'
reset='\e[0m'

# Banner Tengah
echo -e "${red}┌──────────────────────────────────────────────────────────────┐${reset}"
echo ""
echo -e "                             • ${blue}BY${reset} •"
echo -e "                         *  ${blue}BENJAMIN${reset}  *"
echo ""
echo -e "${red}└──────────────────────────────────────────────────────────────┘${reset}"

# Menu
echo ""
echo -e "  ${blue}[1]${reset} • [SSH MENU]           ${blue}[10]${reset} • [NOTIF TELE]     "            
echo -e "  ${blue}[2]${reset} • [XRAY MENU]          ${blue}[11]${reset} • [CEK BANDWIDTH]  "           
echo -e "  ${blue}[3]${reset} • [ADD-HOST]           ${blue}[12]${reset} • [UPDATE-SCRIPT]  "
echo -e "  ${blue}[4]${reset} • [GEN-CERT]           ${blue}[13]${reset} • [RESTART SERVICE]"
echo -e "  ${blue}[5]${reset} • [INSTALL ADS-BLOCK]  ${blue}[14]${reset} • [AUTO-POINTING]  "
echo -e "  ${blue}[6]${reset} • [ADS-BLOCK MENU]     ${blue}[15]${reset} • [RUNNING]        "
echo -e "  ${blue}[7]${reset} • [REBOOT]             ${blue}[16]${reset} • [SPEEDTEST]      "
echo -e "  ${blue}[8]${reset} • [CLEARLOG]	     ${blue}[17]${reset} • [BACKUP&RESTORE] "
echo -e "  ${blue}[9]${reset} • [INFO]	             ${blue}[19]${reset} • [BACKUP&RESTORE] "
echo ""
echo -e "${red}└──────────────────────────────────────────────────────────────┘${reset}"
echo -e "  ${blue}[X]${reset} • [PRESS X TO EXIT]"
echo ""
read -rp "Select menu : " menu


#!/bin/bash
#==========================
#author:Benjamin Engel
#github:MrZodoxVpython
#discord:benjamin.wickman
#tele:MrZodoxVpython
#==========================

# Ambil IP publik dan cek VPS
MYIP=$(curl -sS ipv4.icanhazip.com)
echo "Checking VPS"
clear

# Fungsi untuk mengecek user dan IP
CekUserIp() {
    curl -sS https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini > /root/tmp
    ttl=$(date +%Y-%m-%d)

    while read -r line; do
        [[ $line =~ ^### ]] || continue

        ip=$(echo "$line" | awk '{print $2}')
        user=$(echo "$line" | awk '{print $3}')
        exp=$(echo "$line" | awk '{print $4}')

        if [[ "$ip" == "$MYIP" ]]; then
            d1=$(date -d "$exp" +%s)
            d2=$(date -d "$ttl" +%s)
            exp2=$(( (d1 - d2) / 86400 ))

            if [[ "$exp2" -le 0 ]]; then
                echo "$user" > /etc/.$user.ini
            else
                rm -f /etc/.$user.ini >/dev/null 2>&1
            fi
        fi
    done < /root/tmp

    rm -f /root/tmp
}

# Ambil nama dari IP
Name=$(curl -sS https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini | grep $MYIP | awk '{print $3}')
echo $Name > /usr/local/etc/.$Name.ini
CekOne=$(cat /usr/local/etc/.$Name.ini)

# Fungsi cek expired
CheckExp() {
    if [ -f "/etc/.$Name.ini" ]; then
        CekTwo=$(cat /etc/.$Name.ini)
        if [ "$CekOne" = "$CekTwo" ]; then
            res="Expired"
        fi
    else
        res="Permission Accepted..."
    fi
}

# Fungsi untuk cek izin akses VPS
PERMISSION() {
    IZIN=$(curl -sS https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini | awk '{print $2}' | grep $MYIP)
    if [ "$MYIP" = "$IZIN" ]; then
        CheckExp
    else
        res="Permission Denied!"
    fi
    CekUserIp
}

# Warna terminal
red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

# Jalankan cek izin sebelum tampilkan menu
PERMISSION

if [ "$res" = "Permission Denied!" ]; then
    echo -e "${red}Permission Denied!${NC} Your IP ($MYIP) is not authorized to use this script, silahkan hubungi author: tele:@MrZodoxVpython ig:mr.zodoxvpython tele:@tokomard_official discord:@benjaminwickman ig:benjamin.wickman github:MrZodoxVpython shopee:tokomard."
    exit 1
elif [ "$res" = "Expired" ]; then
    echo -e "${red}Access Expired!${NC} Your permission has expired. Please renew your access, silahkan hubungi author: tele:@MrZodoxVpython ig:mr.zodoxvpython tele:@tokomard_official discord:@benjaminwickman ig:benjamin.wickman github:MrZodoxVpython shopee:tokomard."
    exit 1
fi

# Cek status expired
if [ "$res" = "Expired" ]; then
    Exp="\e[36mExpired\033[0m"
else
    Exp=$(curl -sS https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/ipmini | grep $MYIP | awk '{print $4}')
fi

# Variabel warna tambahan
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
cyan='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
BGreen='\e[1;32m'
BYellow='\e[1;33m'
BBlue='\e[1;34m'
BPurple='\e[1;35m'
BCyan='\e[1;36m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHT='\033[0;37m'

# Informasi VPS
domain=$(cat /etc/xray/domain)

# Status TLS
cert_dir=$(find $HOME/.acme.sh -type d -name "*_ecc" | grep "vpn-premium.tokomard.store" | head -n1)
key_file=$(find "$cert_dir" -name "*.key" | head -n1)

if [[ -f "$key_file" ]]; then
    modifyTime=$(stat "$key_file" | awk 'NR==7 {print $2" "$3" "$4" "$5}')
    modifyTime1=$(date +%s -d "${modifyTime}")
    currentTime=$(date +%s)
    stampDiff=$((currentTime - modifyTime1))
    days=$((stampDiff / 86400))
    remainingDays=$((90 - days))

    if [[ $remainingDays -le 0 ]]; then
        tlsStatus="expired"
    else
        tlsStatus=$remainingDays
    fi
else
    tlsStatus="not found"
fi

# Uptime
uptime="$(uptime -p | cut -d " " -f 2-)"

# Penggunaan jaringan
iface="eth0"
dtoday="$(vnstat -i $iface | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i $iface | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i $iface | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
dyest="$(vnstat -i $iface | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i $iface | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i $iface | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
dmon="$(vnstat -i $iface -m | grep "$(date +"%b '%y")" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i $iface -m | grep "$(date +"%b '%y")" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i $iface -m | grep "$(date +"%b '%y")" | awk '{print $9" "substr ($10, 1, 1)}')"

# CPU dan Memori
cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
freq=$(awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo)
tram=$(free -m | awk 'NR==2 {print $2}')
uram=$(free -m | awk 'NR==2 {print $3}')
fram=$(free -m | awk 'NR==2 {print $4}')

# Informasi tanggal dan lokasi
DAY=$(date +%A)
DATE=$(date +%m/%d/%Y)
DATE2=$(date -R | cut -d " " -f -5)
IPVPS=$(curl -s ifconfig.me)
LOC=$(curl -s ifconfig.co/country)

# Tampilan informasi
clear
# Ambil OS secara fleksibel
if command -v hostnamectl >/dev/null 2>&1; then
    OS_INFO=$(hostnamectl | grep "Operating System" | cut -d ':' -f2- | sed 's/^ *//')
fi

if [ -z "$OS_INFO" ] && [ -f /etc/os-release ]; then
    OS_INFO=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi

if [ -z "$OS_INFO" ]; then
    OS_INFO="Unknown"
fi

# === Fungsi Restore via Key === #
    restore_via_key() {
    clear
    echo -e "\e[1;36m==== Restore Akun via KEY (Tanpa Validasi) ====\e[0m"
    read -rp "Masukkan KEY akun: " user_key

    # Buat file config.json berisi key
    echo -e "{\n  \"key\": \"$user_key\"\n}" > /etc/xray/config.json

    # Restart layanan xray supaya konfigurasi baru aktif
    systemctl restart xray

    echo -e "\e[92mRestore berhasil dengan memasukkan key ke config.json!\e[0m"
    read -n1 -r -p "Tekan tombol apapun untuk kembali ke menu..."
}


# Tampilkan menu utama
#!/bin/bash

clear

# Header ultra epic dengan ASCII art dan warna
echo -e "\e[1;96m     ____  _____ _   _     _   _    __  __ ___ _   _  \e[0m"
echo -e "\e[1;95m    | __ )| ____| \ | |   | | / \  |  \/  |_ _| \ | | \e[0m"
echo -e "\e[1;92m    |  _ \|  _| |  \| |_  | |/ _ \ | |\/| || ||  \| | \e[0m"
echo -e "\e[1;96m    | |_) | |___| |\  | |_| / ___ \| |  | || || |\  | \e[0m"
echo -e "\e[1;96m    |____/|_____|_| \_|\___/_/   \_\_|  |_|___|_| \_| \e[0m"
echo ""

# VPS Info Box
echo -e "\e[1;91m┌────────────────────────────────────────────────────────┐"
echo -e "│    \e[1;0m     🔥🔥🔥 𝐕𝐏𝐒 𝐈𝐍𝐅𝐎 𝐁𝐘 𝐁𝐄𝐍𝐉𝐀𝐌𝐈𝐍-𝐃𝐄𝐕 🔥🔥🔥\e[1;91m         │"
echo -e "├────────────────────────────────────────────────────────┤"              
echo -e "│  \e[1;93mOS          :\e[0m $OS_INFO"
echo -e "│  \e[1;93mUPTIME      :\e[0m $uptime"
echo -e "│  \e[1;93mPUBLIC IP   :\e[0m $IPVPS"
echo -e "│  \e[1;93mCOUNTRY     :\e[0m $LOC"
echo -e "│  \e[1;93mDOMAIN      :\e[0m $domain"
echo -e "│  \e[1;93mDATE & TIME :\e[0m $DATE2"
echo -e "└────────────────────────────────────────────────────────┘"

# RAM Info Box
echo -e "\n\e[1;38;5;198m                   ⚔  𝐑𝐀𝐌 𝐈𝐍𝐅𝐎  ⚔\e[0m"
echo -e "\e[1;91m╔════════════════════════════════════════════════════════╗\e[0m"
echo -e "║  \e[1;96mRAM USED  :\e[0m ${uram} MB                                    ║"
echo -e "║  \e[1;96mRAM TOTAL :\e[0m ${tram} MB                                   ║"
echo -e "╚════════════════════════════════════════════════════════╝"

# Main Menu Box
echo ""
echo -e "\e[1;38;5;198m                  ⚔  𝐌𝐀𝐈𝐍 𝐌𝐄𝐍𝐔  ⚔\e[0m"
echo -e "\e[1;95m╔════════════════════════════════════════════════════════╗\e[0m"
echo -e "║  \e[1;93m1\e[0m  : Menu SSH                                         ║"
echo -e "║  \e[1;93m2\e[0m  : Menu Vmess                                       ║"
echo -e "║  \e[1;93m3\e[0m  : Menu Vless                                       ║"
echo -e "║  \e[1;93m4\e[0m  : Menu Trojan                                      ║"
echo -e "║  \e[1;93m5\e[0m  : Menu Shadowsocks                                 ║"
echo -e "║  \e[1;93m6\e[0m  : Menu Setting                                     ║"
echo -e "║  \e[1;93m7\e[0m  : Status Service                                   ║"
echo -e "║  \e[1;93m8\e[0m  : Clear RAM Cache                                  ║"
echo -e "║  \e[1;93m9\e[0m  : Reboot VPS                                       ║"
echo -e "║  \e[1;93m10\e[0m : Bot Panel                                        ║"
echo -e "║  \e[1;93m11\e[0m : Set Udp VPS                                      ║"
echo -e "║  \e[1;93mb\e[0m  : Backup Account                                   ║"
echo -e "║  \e[1;93mr\e[0m  : Restore Account                                  ║"
echo -e "║  \e[1;93mk\e[0m  : Restore via Key/Kode                             ║"
echo -e "║  \e[1;93mx\e[0m  : Exit Script                                      ║"
echo -e "╚════════════════════════════════════════════════════════╝"

# User Info Box
echo ""
echo -e "\e[1;38;5;198m           ⚔  𝐔𝐋𝐓𝐑𝐀 𝐄𝐏𝐈𝐂 𝐔𝐒𝐄𝐑 𝐈𝐍𝐅𝐎  ⚔\e[0m"
echo -e "\e[1;35m╔════════════════════════════════════════════════════════╗\e[0m"
printf "║  \e[1;92mClient Name : %-43s\e[0m\n" "$Name"
printf "║  \e[1;92mExpired     : %-43s\e[0m\n" "$Exp"
echo -e "\e[1;35m╚════════════════════════════════════════════════════════╝\e[0m"


# Footer ASCII art
echo ""
echo -e "\e[1;0m         --------𝐁𝐄𝐍𝐉𝐀𝐌𝐈𝐍-𝐗-𝐓𝐎𝐊𝐎𝐌𝐀𝐑𝐃-𝐃𝐄𝐕--------\e[0m"
echo ""



# Input menu
read -p " Select menu :  "  benjaminwickman
echo -e ""

case $benjaminwickman in
1) clear ; m-sshovpn ;;
2) clear ; m-vmess ;;
3) clear ; m-vless ;;
4) clear ; m-trojan ;;
5) clear ; m-ssws ;;
6) clear ; m-system ;;
7) clear ; running ;;
8) clear ; clearcache ;;
9) clear ; reboot ; /sbin/reboot ;;
10) clear ; wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xolpanel.sh && chmod +x xolpanel.sh && ./xolpanel.sh ;;
11) clear ; wget -qO- -O udp.sh "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/udp.sh" && chmod +x udp.sh && ./udp.sh ;;
b) clear ; backup ;;
r) clear ; restore ;;
k) clear ; restore_via_key ;;    # <-- Tambahan baru untuk restore via key
x) exit ;;
*) echo "Input yang anda berikan tidak tersedia di script!" ; sleep 5 ; menu ;;
esac

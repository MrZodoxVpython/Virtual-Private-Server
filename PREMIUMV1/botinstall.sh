#!/bin/bash
clear
#By = t.me/xlordeuyy
red() { echo -e "\\033[32;1m${*}\\033[0m"; }
RED='\033[0;31m'
NC='\e[0m'
gray="\e[1;30m"
Blue="\033[1;36m"
GREEN='\033[0;32m'
grenbo="\e[92;1m"
YELL='\033[0;33m'
BGX="\033[42m"
ipsaya=$(wget -qO- ipinfo.io/ip)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
data_ip="https://raw.githubusercontent.com/MrZodoxVpython/VPS/"
#data_ip="https://abc.xcodehoster.com/izin"
checking_sc() {
  useexp=$(wget -qO- $data_ip | grep $ipsaya | awk '{print $3}')
  if [[ $date_list < $useexp ]]; then
    echo -ne
  else
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    echo -e "\033[42m          404 NOT FOUND AUTOSCRIPT          \033[0m"
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    echo -e ""
    echo -e "            ${RED}PERMISSION DENIED !${NC}"
    echo -e "   \033[0;33mYour VPS${NC} $ipsaya \033[0;33mHas been Banned${NC}"
    echo -e "     \033[0;33mBuy access permissions for scripts${NC}"
    echo -e "             \033[0;33mContact Admin :${NC}"
    echo -e "      \033[0;36mTelegram${NC} t.me/MrZodoxVpython"
    echo -e "      ${GREEN}WhatsApp${NC} wa.me/6287757185991"
    echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
    exit
  fi
}
clear

domain=$(cat /etc/xray/domain)

function install-bot(){
apt update -y && apt upgrade -y
apt install python3 python3-pip git speedtest-cli -y
cd /usr/bin
clear
wget https://raw.githubusercontent.com/MrZodoxVpython/main/botmin.zip &> /dev/null
unzip adminbot.zip &> /dev/null
pip3 install -r adminbot/requirements.txt
chmod +x *
mv -f * /usr/bin
rm -rf /usr/bin/adminbot.zip
cd
clear
echo -e "\033[1;36m┌━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┐\033[0m"
echo -e "   \e[1;97;101m      Masukan Id Tele & TokenBot       \e[0m"
echo -e "\033[1;36m└━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┘\033[0m"
echo -e "${grenbo}Tutorial Creat Bot and ID Telegram${NC}"
echo -e "${grenbo}[*] Creat Bot and Token Bot : @BotFather${NC}"
echo -e "${grenbo}[*] Info Id Telegram : @MissRose_bot , perintah /info${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -rp "[*] Input your Bot Token : " -e bottoken 
read -rp "[*] Input Your Id Telegram : " -e admin
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
clear
rm -rf /usr/bin/ddsdswl.session
rm -rf /usr/bin/adminbot/var.txt
rm -rf /usr/bin/adminbot/database.db
if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/bot/${bottoken}
fi
DATADB=$(cat /etc/bot/.bot.db | grep "^#bot#" | grep -w "${bottoken}" | awk '{print $2}')
if [[ "${DATADB}" != '' ]]; then
  sed -i "/\b${user}\b/d" /etc/bot/.bot.db
fi
echo "#bot# ${bottoken} ${admin}" >>/etc/bot/.bot.db

cat >/usr/bin/adminbot/var.txt <<EOF
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$domain"
EOF

echo "$bottoken" > /etc/per/token
echo "$admin" > /etc/per/id
echo "$bottoken" > /usr/bin/token
echo "$admin" > /usr/bin/idchat
echo "$bottoken" > /etc/perlogin/token
echo "$admin" > /etc/perlogin/id
clear

echo "SHELL=/bin/sh" >/etc/cron.d/cekbot
echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >>/etc/cron.d/cekbot
echo "*/1 * * * * root /usr/bin/cekbot" >>/etc/cron.d/cekbot

cat > /usr/bin/cekbot << END
nginx=$( systemctl status adminbot | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    echo -ne
else
    systemctl restart adminbot
    systemctl start adminbot
fi

adminbot=$( systemctl status adminbot | grep "TERM" | wc -l )
if [[ $adminbot == "0" ]]; then
echo -ne
else
    systemctl restart adminbot
    systemctl start adminbot
fi
END

cat > /etc/systemd/system/adminbot.service << END
[Unit]
Description=Simple adminbot - @adminbot
After=syslog.target network-online.target

[Service]
WorkingDirectory=/usr/bin
ExecStart=/usr/bin/python3 -m adminbot
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl stop adminbot
systemctl enable adminbot
systemctl start adminbot
systemctl restart adminbot

echo "Done"
echo " Installations complete, type /menu on your bot"
read -n 1 -s -r -p "Press any key to back on menu"
menu
}
cd
if [ -e /usr/bin/adminbot ]; then
echo -ne
else
install-bot
fi

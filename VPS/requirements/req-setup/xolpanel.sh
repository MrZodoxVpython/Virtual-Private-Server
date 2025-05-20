#!/bin/bash

#install
rm -rf xolpanel.sh
apt update && apt upgrade
apt install python3 python3-pip git
wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xolpanel.zip
unzip xolpanel.zip
pip3 install -r xolpanel/requirements.txt
pip3 install pillow

#isi data
echo "xolpanel registration"
read -e -p "[*] Input your Bot Token : " bottoken
read -e -p "[*] Input Your Id Telegram :" tokomard
read -e -p "[*] Input Your Subdomain :" domain
echo -e BOT_TOKEN='"'$bottoken'"' >> /root/xolpanel/var.txt
echo -e ADMIN='"'$tokomard'"' >> /root/xolpanel/var.txt
echo -e DOMAIN='"'$domain'"' >> /root/xolpanel/var.txt
clear
echo "Done"
echo "Your Data Bot"
echo -e "==============================="
echo "Bot Token     : $bottoken"
echo "Id Telegram   : $tokomard"
echo "Subdomain     : $domain"
echo -e "==============================="
echo "Setting done Please wait 10s"
sleep 10

cat > /etc/systemd/system/xolpanel.service << END
[Unit]
Description=Simple XolPanel - @XolPanel
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/python3 -m xolpanel
Restart=always

[Install]
WantedBy=multi-user.target
END

systemctl start xolpanel 
systemctl enable xolpanel

clear

echo -e "==============================================="
echo " CREATED BY BENJAMIN-TOKOMARD-DEV"
echo " Installations complete, type /menu on your bot"
echo -e "==============================================="
read -n 1 -s -r -p "Press any key to Reboot"
rm -rf xolpanel.sh
clear
reboot


# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition 1.0
# Author  : Benjamin-Tokomard-Dev
# (C) Copyright 2025
# =========================================
# benjamin.wickman

BGreen='\e[1;32m'
NC='\e[0m'

#setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload

#delete directory
cd
rm -rf /root/nsdomain
rm nsdomain

#input nameserver manual to cloudflare


read -rp "Benjamin-notification: Masukkan Subdomain Yang Dipakai Host Sekarang: " -e sub
SUB_DOMAIN=${sub}
NS_DOMAIN=ns-${SUB_DOMAIN}
echo $NS_DOMAIN > /root/nsdomain

nameserver=$(cat /root/nsdomain)
domen=$(cat /etc/xray/domain)
apt update -y
apt install -y python3 python3-dnslib net-tools
apt install ncurses-utils -y
apt install dnsutils -y
apt install golang -y
apt install git -y
apt install curl -y
apt install wget -y
apt install ncurses-utils -y
apt install screen -y
apt install cron -y
apt install iptables -y
apt install -y git screen whois dropbear wget
apt install -y pwgen python php jq curl
apt install -y sudo gnutls-bin
apt install -y mlocate dh-make libaudit-dev build-essential
apt install -y dos2unix debconf-utils
service cron reload
service cron restart

#tambahan port openssh
cd
echo "Port 2222" >> /etc/ssh/sshd_config
echo "Port 2269" >> /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
service ssh restart
service sshd restart

#konfigurasi slowdns
rm -rf /etc/slowdns
mkdir -m 777 /etc/slowdns
wget -q -O /etc/slowdns/server.key "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/server.key"
wget -q -O /etc/slowdns/server.pub "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/server.pub"
wget -q -O /etc/slowdns/slowdns-server "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/slowdns-server"
wget -q -O /etc/slowdns/slowdns-client "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/slowdns-client"

cd
chmod +x /etc/slowdns/server.key
chmod +x /etc/slowdns/server.pub
chmod +x /etc/slowdns/slowdns-server
chmod +x /etc/slowdns/slowdns-client
cd

wget -q -O /etc/systemd/system/client-slowdns.service "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/client-slowdns.service"
wget -q -O /etc/systemd/system/server-slowdns.service "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/server-slowdns.service"

#install client-slowdns.service
cd
cat > /etc/systemd/system/client-slowdns.service << END
[Unit]
Description=Client SlowDNS Benjamin-Dev
Documentation=https://tokomard.store
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/slowdns-client -udp 8.8.8.8:53 --pubkey-file /etc/slowdns/server.pub $nameserver 127.0.0.1:2222
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

cd
#install server-slowdns.service
cat > /etc/systemd/system/server-slowdns.service << END
[Unit]
Description=Server SlowDNS By MrZodoxVpython-X-Benjamin-Tokomard-Dev
Documentation=https://tokomard.store
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/slowdns-server -udp :5300 -privkey-file /etc/slowdns/server.key $nameserver 127.0.0.1:2269
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

#permission service slowdns
cd
chmod +x /etc/systemd/system/client-slowdns.service

chmod +x /etc/systemd/system/server-slowdns.service
pkill slowdns-server
pkill slowdns-client

systemctl daemon-reload
systemctl stop client-slowdns
systemctl stop server-slowdns

systemctl enable client-slowdns
systemctl enable server-slowdns

systemctl start client-slowdns
systemctl start server-slowdns

systemctl restart client-slowdns
systemctl restart server-slowdns

echo -e "\e[1;32m Benjamin-Notification: All Has Been Successd.. \e[0m"
echo "Benjamin-Notification: Silahkan Pointing Type NS $nameserver Dengan Target $domen"
sleep 10


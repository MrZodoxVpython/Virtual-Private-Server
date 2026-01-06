#!/bin/bash

MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;100;33m          • SYSTEM MENU •          \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m•1\e[0m] Panel Domain"
echo -e " [\e[36m•2\e[0m] Speedtest VPS"
echo -e " [\e[36m•3\e[0m] Set Auto Reboot"
echo -e " [\e[36m•4\e[0m] Restart All Service"
echo -e " [\e[36m•5\e[0m] Cek Bandwith"
echo -e " [\e[36m•6\e[0m] Install TCP BBR"
echo -e " [\e[36m•7\e[0m] Dns Changer"
echo -e " [\e[36m•8\e[0m] Set Udp VPS"    
echo -e " [\e[36m•9\e[0m] Cek Status Service"   
echo -e " [\e[36m•10\e[0m] Install Bot Panel"   
echo -e " [\e[36m•11\e[0m] Clear Cache"   
echo -e ""
echo -e " [\e[31m•0\e[0m] \e[31mBACK TO MENU\033[0m"
echo -e   ""
echo -e   "Press x or [ Ctrl+C ] • To-Exit"
echo -e   ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; m-domain ; exit ;;
2) clear ; speedtest ; exit ;;
3) clear ; auto-reboot ; exit ;;
4) clear ; restart ; exit ;;
5) clear ; bw ; exit ;;
6) clear ; m-tcp ; exit ;;
7) clear ; m-dns ; exit ;;
8) clear ; wget -qO- -O udp.sh "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/udp.sh" && chmod +x udp.sh && ./udp.sh ;;
9) clear ; running ;;
10) clear ; wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xolpanel.sh && chmod +x xolpanel.sh && ./xolpanel.sh ;;
11) clear ; 
#!/bin/bash

# Hapus atau kosongkan log Xray
truncate -s 0 /var/log/xray/error.log
truncate -s 0 /var/log/xray/access.log

# Hapus log rotasi NGINX
rm -f /var/log/nginx/access.log.1

# Kosongkan log aktif NGINX
truncate -s 0 /var/log/nginx/access.log
truncate -s 0 /var/log/syslog
truncate -s 0 /var/log/syslog.1


# Restart service untuk memastikan tetap jalan normal
systemctl restart xray
systemctl restart nginx
echo "Clean logs run at $(date)" >> /var/log/clean-logs.log

;;

0) clear ; menu ; exit ;;
x) exit ;;
*) echo -e "" ; echo "Benjamin-notif: Menu tidak tersedia!" ; sleep 1 ; m-system ;;
esac

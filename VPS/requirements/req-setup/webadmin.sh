#!/bin/bash
#TOKOMARD
#MRZODOXVPYTHON
#BENJAMIN.WICKMAN

# Warna dan Simbol
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
NC='\033[0m'

IPVPS=$(curl -s ifconfig.me)

function banner() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo -e "╔════════════════════════════════════════════════════════╗"
    echo -e "║                🌐  VPS Web Admin Panel  🌐             ║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
}

function menu_webadmin() {
    banner
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗"
    echo -e "║${YELLOW} [1] 🚀 Install Web Admin Panel (Caddy + PHP)            ${CYAN}║"
    echo -e "║${YELLOW} [2] 🔧 Jalankan PHP Web Server (tanpa Caddy)           ${CYAN}║"
    echo -e "║${YELLOW} [3] 🌍 Lihat URL Panel Web                             ${CYAN}║"
    echo -e "║${YELLOW} [4] 📝 Edit Web Admin Panel                            ${CYAN}║"
    echo -e "║${YELLOW} [5] 📁 Atur Folder Custom Web untuk Caddy              ${CYAN}║"
    echo -e "║${YELLOW} [0] ❌ Kembali ke Menu Utama                           ${CYAN}║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e "${BOLD}Pilih opsi: ${NC}")" pilih

    case $pilih in
        1)
            banner
            echo -e "${GREEN}🚀 Menginstal Caddy + PHP + Panel Web...${NC}"
            apt update && apt install -y php php-fpm curl unzip software-properties-common debian-keyring debian-archive-keyring apt-transport-https

            # Install Caddy
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
            apt update && apt install caddy -y

            PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
            PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"

            echo -e "${YELLOW}🌐 Masukkan domain untuk akses panel (Contoh: panel.domainkamu.com):${NC}"
            read -p "➤ " DOMAIN_PANEL

            mkdir -p /var/www/panel
            curl -s https://raw.githubusercontent.com/namaskuy/webadmin-xray/main/index.php -o /var/www/panel/index.php
            chown -R www-data:www-data /var/www/panel

            cat > /etc/caddy/Caddyfile <<EOF
            ${DOMAIN_PANEL} {
            # Reverse proxy untuk Xray (WS TLS)
                sgdo-2dev.tokomard.store {
                # Sesuaikan path dan port sesuai konfigurasi Xray Anda
                reverse_proxy /vmess 127.0.0.1:23456
                reverse_proxy /vless-ws 127.0.0.1:14016
                reverse_proxy /trojan-ws 127.0.0.1:25432
                reverse_proxy /ss-ws 127.0.0.1:30300
                encode gzip
            }
            # website statis HTML
                panel.tokomard.store {
                root * /var/www/html/xray-panel
                try_files {path} {path}/ /index.html /index.php
                php_fastcgi unix//run/php/php7.4-fpm.sock
                file_server
            }
            EOF

            systemctl restart $PHP_FPM_SERVICE
            systemctl enable $PHP_FPM_SERVICE

            systemctl restart caddy
            systemctl enable caddy

            echo -e "${GREEN}✅ Sukses! Akses panel di: https://${DOMAIN_PANEL}${NC}"
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            menu_webadmin
            ;;

        2)
            banner
            mkdir -p /var/www/html/panel
            curl -s https://raw.githubusercontent.com/namaskuy/webadmin-xray/main/index.php -o /var/www/html/panel/index.php
            echo -e "${GREEN}🔧 Menjalankan PHP Web Server di port 8080...${NC}"
            nohup php -S 0.0.0.0:8080 -t /var/www/html/panel >/dev/null 2>&1 &
            echo -e "${GREEN}✅ Web panel aktif di: http://${IPVPS}:8080${NC}"
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            menu_webadmin
            ;;

        3)
            banner
            echo -e "${CYAN}🌍 Akses Panel Web via:${NC}"
            echo -e "${YELLOW}- https://${DOMAIN_PANEL} (via Caddy)"
            echo -e "${YELLOW}- http://${IPVPS}:8080       (PHP server tanpa Caddy)"
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            menu_webadmin
            ;;

        4)
            banner
            EDITOR_PATH="/var/www/panel/index.php"
            if [ -f "$EDITOR_PATH" ]; then
                nano "$EDITOR_PATH"
            else
                echo -e "${RED}❌ File tidak ditemukan: $EDITOR_PATH${NC}"
            fi
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            menu_webadmin
            ;;

        5)
            banner
            echo -e "${YELLOW}📁 Folder yang tersedia di /var/www/html:${NC}"
            ls -1 /var/www/html
            echo -e "\n${YELLOW}🔧 Masukkan nama folder yang ingin dijadikan root Caddy (contoh: facebook):${NC}"
            read -p "➤ " FOLDER

            if [ -d "/var/www/html/$FOLDER" ]; then
                echo -e "${YELLOW}🌐 Masukkan domain untuk folder ini (contoh: facebook.domainkamu.com):${NC}"
                read -p "➤ " DOMAIN_CUSTOM

                echo "${DOMAIN_CUSTOM} {
            root * /var/www/html/${FOLDER}
            file_server
            }" >> /etc/caddy/Caddyfile

                systemctl reload caddy
                echo -e "${GREEN}✅ Domain ${DOMAIN_CUSTOM} sekarang mengarah ke folder /var/www/html/${FOLDER}${NC}"
            else
                echo -e "${RED}❌ Folder /var/www/html/${FOLDER} tidak ditemukan.${NC}"
            fi
            read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
            menu_webadmin
            ;;

        0)
            clear
            echo "Kembali ke menu utama..."
            sleep 1
            exit
            ;;
        *)
            echo -e "${RED}❌ Pilihan tidak valid!${NC}"
            sleep 1
            menu_webadmin
            ;;
            esac
}

menu_webadmin

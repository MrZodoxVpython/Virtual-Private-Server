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
    echo -e "║              🌐  VPS Web Admin Panel - Elite           ║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
}

function menu_webadmin() {
    banner
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗"
    echo -e "║${YELLOW} [1] 🚀 Install Web Admin Panel (Nginx + PHP)           ${CYAN}║"
    echo -e "║${YELLOW} [2] 🔧 Jalankan PHP Web Server (tanpa Nginx)           ${CYAN}║"
    echo -e "║${YELLOW} [3] 🌍 Lihat URL Panel Web                             ${CYAN}║"
    echo -e "║${YELLOW} [0] ❌ Kembali ke Menu Utama                           ${CYAN}║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e "${BOLD}Pilih opsi: ${NC}")" pilih

    case $pilih in
        1)
            banner
            echo -e "${GREEN}🚀 Menginstal Nginx + PHP + Panel Web...${NC}"
            apt update && apt install nginx php php-fpm curl -y
            mkdir -p /var/www/html/panel
            curl -s https://raw.githubusercontent.com/namaskuy/webadmin-xray/main/index.php -o /var/www/html/panel/index.php
            chown -R www-data:www-data /var/www/html/panel
            systemctl enable php*-fpm nginx
            systemctl restart php*-fpm nginx
            echo -e "${GREEN}✅ Sukses! Akses via: http://${IPVPS}/panel${NC}"
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
            echo -e "${YELLOW}- http://${IPVPS}/panel (Nginx)"
            echo -e "${YELLOW}- http://${IPVPS}:8080     (PHP server)"
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
            menu
            ;;
    esac
}

menu_webadmin

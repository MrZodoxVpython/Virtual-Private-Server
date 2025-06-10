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
    echo -e "║${YELLOW} [1] 🚀 Install Web Admin Panel (Nginx + PHP)           ${CYAN}║"
    echo -e "║${YELLOW} [2] 🔧 Jalankan PHP Web Server (tanpa Nginx)           ${CYAN}║"
    echo -e "║${YELLOW} [3] 🌍 Lihat URL Panel Web                             ${CYAN}║"
    echo -e "║${YELLOW} [4] 📝 Edit Web Admin Panel                            ${CYAN}║"
    echo -e "║${YELLOW} [0] ❌ Kembali ke Menu Utama                           ${CYAN}║"
    echo -e "╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "$(echo -e "${BOLD}Pilih opsi: ${NC}")" pilih

    case $pilih in
        1)
            banner
            echo -e "${GREEN}🚀 Menginstal Nginx + PHP + Panel Web...${NC}"
            apt update && apt install nginx php php-fpm curl unzip software-properties-common certbot python3-certbot-nginx -y

            PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
            PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"

            echo -e "${YELLOW}🌐 Masukkan domain untuk akses panel (Contoh: panel.domainkamu.com):${NC}"
            read -p "➤ " DOMAIN_PANEL

            if [[ ! "$DOMAIN_PANEL" =~ ^[a-zA-Z0-9.-]+$ ]]; then
                echo -e "${RED}❌ Domain tidak valid! Harap masukkan domain yang benar.${NC}"
                read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
                menu_webadmin
                return
            fi

            mkdir -p /var/www/panel
            curl -s https://raw.githubusercontent.com/namaskuy/webadmin-xray/main/index.php -o /var/www/panel/index.php
            chown -R www-data:www-data /var/www/panel

            cat > /etc/nginx/sites-available/panel <<EOF
server {
    listen 127.0.0.1:8880;
    server_name $DOMAIN_PANEL;

    root /var/www/panel;
    index index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}

server {
    listen 8443 ssl;
    server_name $DOMAIN_PANEL;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_PANEL/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_PANEL/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8880;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

            ln -sf /etc/nginx/sites-available/panel /etc/nginx/sites-enabled/panel

            nginx -t && systemctl restart nginx
            systemctl enable "$PHP_FPM_SERVICE" nginx

            echo -e "${GREEN}🔐 Memasang SSL Let's Encrypt untuk $DOMAIN_PANEL...${NC}"
            certbot certonly --webroot -w /var/www/panel -d "$DOMAIN_PANEL" --agree-tos --email admin@"$DOMAIN_PANEL" --non-interactive

            nginx -t && systemctl reload nginx

            echo -e "${GREEN}✅ Sukses! Akses panel di: https://$DOMAIN_PANEL:8443${NC}"
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
            echo -e "${YELLOW}- https://${DOMAIN_PANEL}:8443 (dengan SSL)"
            echo -e "${YELLOW}- http://${IPVPS}:8080       (PHP server tanpa nginx)"
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

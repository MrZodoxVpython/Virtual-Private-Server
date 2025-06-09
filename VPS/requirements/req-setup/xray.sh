#!/bin/bash
#BENJAMINWICKMAN
#TOKOMARD

# Warna
Green="\033[0;32m"
Yellow="\033[1;33m"
Red="\033[0;31m"
NC="\033[0m"

clear
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${Green}       🚀 Installing Xray v1.8.4 (Go 1.21.0)        ${NC}"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Update & install dependencies
echo -e "${Yellow}[•] Updating packages and installing dependencies...${NC}"
apt update -y && apt upgrade -y
apt install -y curl wget unzip tar

# Buat direktori sementara
cd /tmp || exit

# Download Xray 1.8.4
echo -e "${Yellow}[•] Downloading Xray v1.8.4...${NC}"
wget -q --show-progress https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-64.zip

# Ekstrak dan install
echo -e "${Yellow}[•] Extracting Xray files...${NC}"
unzip -o Xray-linux-64.zip >/dev/null 2>&1
install -m 755 xray /usr/local/bin/xray
mkdir -p /usr/local/share/xray
install -m 644 geoip.dat /usr/local/share/xray/geoip.dat
install -m 644 geosite.dat /usr/local/share/xray/geosite.dat

# Buat folder konfigurasi
mkdir -p /etc/xray

# Buat file systemd
echo -e "${Yellow}[•] Creating systemd service...${NC}"
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/xray -config /etc/xray/config.json
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd & aktifkan service
echo -e "${Yellow}[•] Enabling Xray service...${NC}"
mkdir -p /var/log/xray
touch /var/log/xray/access.log /var/log/xray/error.log
chown -R nobody:nogroup /var/log/xray
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable xray
systemctl start xray

# Tampilkan versi
echo -e "${Green}[✓] Xray installed successfully!${NC}"
xray version

echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${Green} ✅ Done! Please configure your /etc/xray/config.json${NC}"
echo -e "${Yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

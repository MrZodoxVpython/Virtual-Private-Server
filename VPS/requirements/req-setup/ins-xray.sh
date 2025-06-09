#!/bin/bash
#BenjaminWickman
#MrZodoxVpython
#Tokomard
rm -rf /root/ins-xray.sh
clear
# --- Colored Output Functions ---
green()    { echo -e "\033[32;1m${*}\033[0m"; }
red()      { echo -e "\033[31;1m${*}\033[0m"; }
yellow()   { echo -e "\033[33;1m${*}\033[0m"; }
tyblue()   { echo -e "\033[36;1m${*}\033[0m"; }
purple()   { echo -e "\033[35;1m${*}\033[0m"; }

MYIP=$(wget -qO- ipv4.icanhazip.com)
green "Checking VPS"
clear
yellow "Checking the systems ...."
date
green "done step 1 ....."
domain=$(cat /etc/xray/domain)
sleep 0.5
mkdir -p /etc/xray 

# ... bagian instalasi dan setting sistem sama seperti aslinya ...

# --- Wildcard SSL Certificate Installation via acme.sh with Cloudflare DNS API ---

green "[ BENJAMIN ] Installing acme.sh for wildcard certificate issuance"

systemctl stop nginx
red "[ BENJAMIN ] If you getting error than run 'systemctl start nginx' right!"
sleep 2

# === KONFIGURASI ===
DOMAIN=$(cat /etc/xray/domain)
CF_Token="v-twyDjZZiUNsu9WXxt5uaYrQC4u0gIV6cFUl9p8"
CERT_DIR="/etc/xray"
ACME_DIR="$HOME/.acme.sh"

# === 1. EXPORT TOKEN CLOUDFLARE ===
export CF_Token="${CF_Token}"

# === 2. INSTALASI acme.sh ===
echo -e "\e[1;32m[ BENJAMIN ] Installing acme.sh for wildcard certificate issuance\e[0m"
curl https://get.acme.sh | sh

# Tambahkan alias agar bisa dipakai langsung jika terminal baru dibuka
source ~/.bashrc

# === 3. DAPATKAN SERTIFIKAT ===
$ACME_DIR/acme.sh --register-account -m mrzodoxvpython@email.com #change to ur own email
$ACME_DIR/acme.sh --issue --dns dns_cf -d "*.${DOMAIN}" -d "${DOMAIN}" --force
if [ $? -ne 0 ]; then
    echo -e "\e[1;31m[ ERROR ] Failed to issue certificate\e[0m"
    exit 1
fi

# === 4. INSTALL SERTIFIKAT KE DIREKTORI YANG DIGUNAKAN OLEH XRAY ===
mkdir -p ${CERT_DIR}
$ACME_DIR/acme.sh --install-cert -d "*.${DOMAIN}" \
  --key-file ${CERT_DIR}/xray.key \
  --fullchain-file ${CERT_DIR}/xray.crt \
  --reloadcmd "systemctl restart nginx"

# === 5. CEK DAN RESTART NGINX ===
echo -e "\e[1;34m[ INFO ] Restarting Nginx...\e[0m"
systemctl restart nginx
if [ $? -ne 0 ]; then
    echo -e "\e[1;31m[ ERROR ] Nginx failed to restart. Showing status:\e[0m"
    systemctl status nginx --no-pager
    exit 2
fi

echo -e "\e[1;32m[ SUCCESS ] Wildcard certificate installed and Nginx restarted successfully.\e[0m"


#mkdir -p /root/.acme.sh
#curl https://get.acme.sh | sh
#export PATH="/root/.acme.sh:$PATH"

# *** SET VARIABEL CLOUDflare API TOKEN DISINI ***
#CF_Token="v-twyDjZZiUNsu9WXxt5uaYrQC4u0gIV6cFUl9p8"
#export CF_Token

# issue wildcard certificate menggunakan DNS API Cloudflare
#/root/.acme.sh/acme.sh --issue --dns dns_cf -d "*.$domain" -d "$domain"

#if [ $? -ne 0 ]; then
#  red "Failed to issue wildcard certificate for $domain"
#  exit 1
#fi

#/root/.acme.sh/acme.sh --installcert -d "*.$domain" -d "$domain" \
#--key-file /etc/xray/xray.key \
#--fullchain-file /etc/xray/xray.crt \
#--ecc

#green "[ BENJAMIN ] Wildcard certificate installed at /etc/xray/xray.crt and /etc/xray/xray.key"

# Setup cron renew for acme.sh wildcard cert
echo -n '#!/bin/bash
systemctl stop nginx
/root/.acme.sh/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
systemctl start nginx
systemctl status nginx
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh

if ! crontab -l | grep -q 'ssl_renew.sh'; then
  (crontab -l 2>/dev/null; echo "15 3 */3 * * /usr/local/bin/ssl_renew.sh") | crontab -
fi

mkdir -p /home/vps/public_html

green "=== SETTING UUID AND JSON CONF ==="
# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)
# xray config
cat > /etc/xray/config.json << END
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
   {
     "listen": "127.0.0.1",
     "port": "14016",
     "protocol": "vless",
      "settings": {
          "decryption":"none",
            "clients": [
               {
                 "id": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264"                 
#vless
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vless"
          }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "23456",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264",
                 "alterId": 0
#vmess
### pimes 2222-01-01
},{"id": "pimes","alterId": 0,"email": "pimes"
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": {
                "path": "/vmess"
          }
        }
     },
    {
      "listen": "127.0.0.1",
      "port": "25432",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",
           "clients": [
              {
                 "password": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264"
#trojanws
#! benjaminwickman 2222-01-01
},{"password": "benjaminwickman","email": "benjaminwickman"
              }
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": {
               "path": "/trojan-ws"
            }
         }
     },
    {
         "listen": "127.0.0.1",
        "port": "30300",
        "protocol": "shadowsocks",
        "settings": {
           "clients": [
           {
           "method": "aes-128-gcm",
          "password": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264"
#ssws
           }
          ],
          "network": "tcp,udp"
       },
       "streamSettings":{
          "network": "ws",
             "wsSettings": {
               "path": "/ss-ws"
           }
        }
     },
      {
        "listen": "127.0.0.1",
     "port": "24456",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264"
#vlessgrpc
             }
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": {
                "serviceName": "vless-grpc"
           }
        }
     },
     {
      "listen": "127.0.0.1",
     "port": "31234",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264",
                 "alterId": 0
#vmessgrpc
### pimes 2222-01-01
},{"id": "pimes","alterId": 0,"email": "pimes"
             }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": {
                "serviceName": "vmess-grpc"
          }
        }
     },
     {
        "listen": "127.0.0.1",
     "port": "33456",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               {
                 "password": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264"
#trojangrpc
#! benjaminwickman 2222-01-01
},{"password": "benjaminwickman","email": "benjaminwickman"
               }
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": {
               "serviceName": "trojan-grpc"
         }
      }
   },
   {
    "listen": "127.0.0.1",
    "port": "30310",
    "protocol": "shadowsocks",
    "settings": {
        "clients": [
          {
             "method": "aes-128-gcm",
             "password": "19bd1c2b-42d4-43ce-a4f7-31d50cb70264"
#ssgrpc
           }
         ],
           "network": "tcp,udp"
      },
    "streamSettings":{
     "network": "grpc",
        "grpcSettings": {
           "serviceName": "ss-grpc"
          }
       }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}
END

rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service
cat <<EOF > /etc/systemd/system/xray.service
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/runn.service
[Unit]
Description=benjaminwickmandev
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

green "=== ALL HAS BEEN COMPLETED ==="

#nginx config
green "=== CONFIGURING THE NGINX CONF ==="
cat <<EOF > /etc/nginx/conf.d/xray.conf
    server {
             listen 80;
             listen [::]:80;
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;	
             server_name *.$domain;
             ssl_certificate /etc/xray/xray.crt;
             ssl_certificate_key /etc/xray/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /home/vps/public_html;
        }
EOF

sed -i '$ ilocation = /vless' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:14016;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /vmess' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:23456;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /trojan-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:25432;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /ss-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:30300;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation /' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:700;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vless-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:24456;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vmess-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:31234;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /trojan-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:33456;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /ss-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:30310;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

green "[ BENJAMIN-SERVICE ] Restart All service"
systemctl daemon-reload
sleep 0.5
green "[ BENJAMIN ] Enable & restart xray "
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
systemctl restart nginx
systemctl enable runn
systemctl restart runn
green "=== ALL HAS BEEN COMPLETED ==="

cd

yellow "[ BENJAMIN ] === PROCESSING INSTALL ACCOUNT CONTROLS ==="
wget https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/client/acc-control.sh -O /etc/xray/auto-lock.sh && chmod +x /etc/xray/auto-lock.sh
green "=== ACCOUNT CONTROLS INSTALLED ==="

cd /usr/bin/

# vmess
yellow "[ BENJAMIN ]" green "=== PROCESSING INSTALL THE VMESS SERVICE ==="
wget -O add-ws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vmess/add-ws.sh" && chmod +x add-ws
wget -O trialvmess "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vmess/trialvmess.sh" && chmod +x trialvmess
wget -O renew-ws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vmess/renew-ws.sh" && chmod +x renew-ws
wget -O del-ws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vmess/del-ws.sh" && chmod +x del-ws
wget -O cek-ws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vmess/cek-ws.sh" && chmod +x cek-ws
echo "=== ALL DONE ==="

# vless
yellow "[ BENJAMIN ]" green "=== PROCESSING INSTALL VLESS SERVICE ==="
wget -O add-vless "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vless/add-vless.sh" && chmod +x add-vless
wget -O trialvless "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vless/trialvless.sh" && chmod +x trialvless
wget -O renew-vless "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vless/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vless/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/vless/cek-vless.sh" && chmod +x cek-vless
green "=== ALL DONE ==="

# trojan
yellow "[ BENJAMIN ]" green "=== PROCESSING INSTALL TROJAN SERVICE ==="
wget -O add-tr "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/trojan/add-tr.sh" && chmod +x add-tr
wget -O trialtrojan "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/trojan/trialtrojan.sh" && chmod +x trialtrojan
wget -O del-tr "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/trojan/del-tr.sh" && chmod +x del-tr
wget -O renew-tr "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/trojan/renew-tr.sh" && chmod +x renew-tr
wget -O cek-tr "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/trojan/cek-tr.sh" && chmod +x cek-tr
green "=== ALL DONE ==="

# shadowsocks
yellow "[ BENJAMIN ]" green "=== PROCESSING INSTALL SHADOWSHOCKS SERVICE ==="
wget -O add-ssws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/shadowshocks/add-ssws.sh" && chmod +x add-ssws
wget -O trialssws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/shadowshocks/trialssws.sh" && chmod +x trialssws
wget -O del-ssws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/shadowshocks/del-ssws.sh" && chmod +x del-ssws
wget -O renew-ssws "https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/req-setup/xray/shadowshocks/renew-ssws.sh" && chmod +x renew-ssws
green "=== ALL DONE ==="

yellow "[ BENJAMIN ]" green " === PROCESS FINISHING ALL INSTALATION ==="
sleep 0.5
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"

mv /root/domain /etc/xray/ 
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
yellow "[ BENJAMIN ]" tyblue "=== ALL HAS BEEN COMPLETE! ==="
clear
rm -rf ins-

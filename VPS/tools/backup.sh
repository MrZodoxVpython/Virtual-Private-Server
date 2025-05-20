#!/bin/bash

echo "[INFO] Membuat backup sebelum perubahan..."

# Buat folder backup utama
BACKUP_DIR="/home/backup-setup"
mkdir -p "$BACKUP_DIR"

# Folder target backup
mkdir -p $BACKUP_DIR/{etc_xray,etc_v2ray,root,var_lib,etc}

# Backup file-file konfigurasi penting
[ -f /etc/xray/domain ] && cp /etc/xray/domain $BACKUP_DIR/etc_xray/domain.bak
[ -f /etc/xray/scdomain ] && cp /etc/xray/scdomain $BACKUP_DIR/etc_xray/scdomain.bak
[ -f /etc/v2ray/domain ] && cp /etc/v2ray/domain $BACKUP_DIR/etc_v2ray/domain.bak
[ -f /etc/v2ray/scdomain ] && cp /etc/v2ray/scdomain $BACKUP_DIR/etc_v2ray/scdomain.bak

# Backup file di /root
[ -f /root/domain ] && cp /root/domain $BACKUP_DIR/root/domain.bak
[ -f /root/scdomain ] && cp /root/scdomain $BACKUP_DIR/root/scdomain.bak
[ -f /root/.profile ] && cp /root/.profile $BACKUP_DIR/root/profile.bak

# Backup file di /var/lib dan /etc
[ -f /var/lib/ipvps.conf ] && cp /var/lib/ipvps.conf $BACKUP_DIR/var_lib/ipvps.conf.bak
[ -f /var/lib/SIJA/ipvps.conf ] && cp /var/lib/SIJA/ipvps.conf $BACKUP_DIR/var_lib/sija_ipvps.conf.bak
[ -f /etc/myipvps ] && cp /etc/myipvps $BACKUP_DIR/etc/myipvps.bak
[ -f /opt/.ver ] && cp /opt/.ver $BACKUP_DIR/opt-ver.bak
[ -f /etc/rc.local ] && cp /etc/rc.local $BACKUP_DIR/rc.local.bak
[ -f /etc/nginx/nginx.conf ] && cp /etc/nginx/nginx.conf $BACKUP_DIR/nginx.conf.bak
[ -f /etc/iptables.up.rules ] && cp /etc/iptables.up.rules $BACKUP_DIR/

# Backup file log akun jika ada
for log in ssh vmess vless trojan shadowsocks; do
    [ -f /etc/log-create-${log}.log ] && cp /etc/log-create-${log}.log $BACKUP_DIR/
done

# Backup folder-folder besar (dengan timestamp agar unik)
timestamp=$(date +%s)
cp -r /etc/xray "$BACKUP_DIR/etc_xray_$timestamp" 2>/dev/null
cp -r /var/log/xray "$BACKUP_DIR/var_log_xray_$timestamp" 2>/dev/null
cp -r /etc/v2ray "$BACKUP_DIR/etc_v2ray_$timestamp" 2>/dev/null
cp -r /home/vps "$BACKUP_DIR/home_vps_$timestamp" 2>/dev/null
cp -r /usr/local/bin "$BACKUP_DIR/usr_local_bin_$timestamp" 2>/dev/null
cp -r /etc/stunnel "$BACKUP_DIR/etc_stunnel_$timestamp" 2>/dev/null
cp -r /etc/systemd/system "$BACKUP_DIR/systemd_units_$timestamp" 2>/dev/null

echo "[INFO] Backup selesai dan disimpan di: $BACKUP_DIR"


opsional 

cp -r /etc/xray /home/backup-setup/
cp -r /etc/v2ray /home/backup-setup/
cp -r /var/lib /home/backup-setup/
cp -r /opt /home/backup-setup/opt

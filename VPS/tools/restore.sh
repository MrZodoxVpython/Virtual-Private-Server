#!/bin/bash

echo "[INFO] Mulai proses restore dari backup..."

BACKUP_DIR="/home/backup-setup"

# Pilih folder backup timestamp (paling baru) atau folder khusus "latest"
# Kalau kamu ingin restore dari backup timestamp tertentu, isi variabel ini
# Contoh: RESTORE_TIMESTAMP="20250518_153045"
RESTORE_TIMESTAMP=""

if [ -z "$RESTORE_TIMESTAMP" ]; then
    echo "[INFO] Restore dari folder backup 'latest'..."
else
    echo "[INFO] Restore dari folder backup dengan timestamp: $RESTORE_TIMESTAMP"
fi

# Fungsi restore file tunggal (cek dulu file backup ada, baru restore)
restore_file() {
    local src="$1"
    local dst="$2"
    if [ -f "$src" ]; then
        echo "Restore $src -> $dst"
        cp -f "$src" "$dst"
    else
        echo "File backup $src tidak ditemukan, lewati."
    fi
}

# Fungsi restore folder (rekursif)
restore_folder() {
    local src="$1"
    local dst="$2"
    if [ -d "$src" ]; then
        echo "Restore folder $src -> $dst"
        cp -r "$src" "$dst"
    else
        echo "Folder backup $src tidak ditemukan, lewati."
    fi
}

# Tentukan path backup folder untuk restore folder besar
if [ -z "$RESTORE_TIMESTAMP" ]; then
    # Restore dari folder 'latest'
    etc_xray_src="$BACKUP_DIR/xray-latest"
    etc_v2ray_src="$BACKUP_DIR/v2ray-latest"
    var_lib_src="$BACKUP_DIR/var_lib_latest"
    opt_src="$BACKUP_DIR/opt_latest"
else
    # Restore dari folder timestamp
    etc_xray_src="$BACKUP_DIR/etc_xray_$RESTORE_TIMESTAMP"
    etc_v2ray_src="$BACKUP_DIR/etc_v2ray_$RESTORE_TIMESTAMP"
    var_lib_src="$BACKUP_DIR/var_lib_$RESTORE_TIMESTAMP"
    opt_src="$BACKUP_DIR/opt_$RESTORE_TIMESTAMP"
fi

# Restore file-file konfigurasi penting (file tunggal)
restore_file "$BACKUP_DIR/etc_xray/domain.bak" /etc/xray/domain
restore_file "$BACKUP_DIR/etc_xray/scdomain.bak" /etc/xray/scdomain
restore_file "$BACKUP_DIR/etc_v2ray/domain.bak" /etc/v2ray/domain
restore_file "$BACKUP_DIR/etc_v2ray/scdomain.bak" /etc/v2ray/scdomain

restore_file "$BACKUP_DIR/root/domain.bak" /root/domain
restore_file "$BACKUP_DIR/root/scdomain.bak" /root/scdomain
restore_file "$BACKUP_DIR/root/profile.bak" /root/.profile

restore_file "$BACKUP_DIR/var_lib/ipvps.conf.bak" /var/lib/ipvps.conf
restore_file "$BACKUP_DIR/var_lib/sija_ipvps.conf.bak" /var/lib/SIJA/ipvps.conf
restore_file "$BACKUP_DIR/etc/myipvps.bak" /etc/myipvps
restore_file "$BACKUP_DIR/opt/ver.bak" /opt/.ver
restore_file "$BACKUP_DIR/etc/rc.local.bak" /etc/rc.local
restore_file "$BACKUP_DIR/etc/nginx.conf.bak" /etc/nginx/nginx.conf
restore_file "$BACKUP_DIR/etc/iptables.up.rules.bak" /etc/iptables.up.rules

# Restore file log akun (jika ada)
for log in ssh vmess vless trojan shadowsocks; do
    src_log="$BACKUP_DIR/log-create-${log}.log"
    dst_log="/etc/log-create-${log}.log"
    if [ -f "$src_log" ]; then
        echo "Restore $src_log -> $dst_log"
        cp -f "$src_log" "$dst_log"
    else
        echo "File log $src_log tidak ditemukan, lewati."
    fi
done

# Restore folder besar
restore_folder "$etc_xray_src" /etc/xray
restore_folder "$BACKUP_DIR/var_log_xray_$RESTORE_TIMESTAMP" /var/log/xray
restore_folder "$etc_v2ray_src" /etc/v2ray
restore_folder "$BACKUP_DIR/home_vps_$RESTORE_TIMESTAMP" /home/vps
restore_folder "$BACKUP_DIR/usr_local_bin_$RESTORE_TIMESTAMP" /usr/local/bin
restore_folder "$BACKUP_DIR/etc_stunnel_$RESTORE_TIMESTAMP" /etc/stunnel
restore_folder "$BACKUP_DIR/systemd_units_$RESTORE_TIMESTAMP" /etc/systemd/system

# Restore folder opsional (latest)
restore_folder "$var_lib_src" /var/lib
restore_folder "$opt_src" /opt

echo "[INFO] Restore selesai."

#!/bin/bash

echo "[UNINSTALL] Menghapus semua file, folder, dan service yang dibuat oleh setup.sh dan semua dependensinya..."

# === 1. Hentikan dan Nonaktifkan Service ===
echo "[UNINSTALL] Menonaktifkan dan menghentikan service terkait..."
SERVICES=(
  xray.service
  runn
  ws-dropbear.service
  ws-stunnel.service
  rc-local
  stunnel4
  nginx
)

for svc in "${SERVICES[@]}"; do
  systemctl disable $svc >/dev/null 2>&1
  systemctl stop $svc >/dev/null 2>&1
done

# === 2. Hapus systemd service unit ===
echo "[UNINSTALL] Menghapus unit systemd..."
rm -f /etc/systemd/system/{xray.service,runn.service,ws-dropbear.service,ws-stunnel.service,rc-local.service}
rm -f /etc/systemd/system/nginx.service.d/override.conf
systemctl daemon-reload

# === 3. Hapus konfigurasi, folder, dan file penting ===
echo "[UNINSTALL] Menghapus file konfigurasi dan sistem..."
rm -rf /etc/xray /etc/v2ray /var/log/xray /usr/local/bin/ws-* /usr/local/bin/xray
rm -rf /etc/stunnel /etc/default/dropbear /etc/rc.local /etc/issue.net
rm -rf /etc/nginx/conf.d/xray.conf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
rm -rf /usr/local/ddos /usr/local/bin/ssl_renew.sh /root/.acme.sh
rm -rf /opt /opt/.ver /var/lib/ipvps.conf /var/lib/SIJA /etc/myipvps
rm -rf /home/vps /home/re_otm /root/domain /root/scdomain /root/.profile /root/log-install.txt

# === 4. Hapus sisa file script yang diunduh oleh setup.sh ===
echo "[UNINSTALL] Menghapus script hasil download setup..."
rm -f /root/{cf.sh,ssh-vpn.sh,ins-xray.sh,insshws.sh,key.pem,cert.pem,bbr.sh}

# === 5. Hapus script handler/menu tools ===
echo "[UNINSTALL] Menghapus semua script menu dan handler dari /usr/bin/..."
rm -f /usr/bin/menu /usr/bin/xp /usr/bin/*.sh /usr/bin/*.py

# === 6. Bersihkan cron job otomatis ===
echo "[UNINSTALL] Menghapus cron jobs..."
rm -f /etc/cron.d/re_otm /etc/cron.d/xp_otm

# === 7. Flush dan simpan ulang aturan iptables ===
echo "[UNINSTALL] Membersihkan aturan firewall iptables..."
iptables -F
iptables -X
iptables-save > /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

echo ""
echo "[UNINSTALL] Proses uninstall selesai. VPS akan reboot dalam 10 detik..."
sleep 10
reboot

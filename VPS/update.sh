#!/bin/bash
#=================================================
#   UPDATE SCRIPT - VPS SETUP BY MrZodoxVpython
#   Sinkronkan VPS dengan source code terbaru GitHub
#=================================================

set -e

# Warna
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
NC='\e[0m'

# Konfigurasi GitHub
GITHUB_REPO="MrZodoxVpython/Virtual-Private-Server"
GITHUB_BRANCH="main"
GITHUB_BASE="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/VPS"

# Path lokal
LOCAL_VER="/opt/.ver"
LOCAL_REQ_DIR="/root/req-update"

echo -e "${yellow}╔════════════════════════════════════════════════╗${NC}"
echo -e "${green}      🔄 UPDATE SCRIPT VPS SETUP${NC}"
echo -e "${yellow}╚════════════════════════════════════════════════╝${NC}"
echo ""

if [ "${EUID}" -ne 0 ]; then
  echo -e "${red}❌ Jalankan script ini sebagai root!${NC}"
  exit 1
fi

mkdir -p "${LOCAL_REQ_DIR}"
cd "${LOCAL_REQ_DIR}" || exit 1
# Fungsi cek versi
cek_versi() {
  echo -e "${yellow}[INFO] Mengecek versi terbaru dari GitHub...${NC}"

  REMOTE_VER=$(curl -sS "${GITHUB_BASE}/requirements/req-setup/versi" 2>/dev/null || echo "unknown")

  if [ -f "${LOCAL_VER}" ]; then
    LOCAL_VER_CONTENT=$(cat "${LOCAL_VER}")
  else
    LOCAL_VER_CONTENT="belum terinstall"
  fi

  echo -e "${green}Versi lokal   :${NC} ${LOCAL_VER_CONTENT}"
  echo -e "${green}Versi GitHub  :${NC} ${REMOTE_VER}"

  if [ "${LOCAL_VER_CONTENT}" = "${REMOTE_VER}" ]; then
    echo -e "${green}✅ Sudah menggunakan versi terbaru!${NC}"
    rm -rf "${LOCAL_REQ_DIR}"
    exit 0
  else
    echo -e "${yellow}📦 Terdapat update baru. Memulai proses update...${NC}"
  fi
}

# Fungsi download file
download_file() {
  local remote_path="$1"
  local local_path="$2"

  echo -e "${yellow}[DOWNLOAD]${NC} ${remote_path} -> ${local_path}"

  if curl -sSL -o "${local_path}.tmp" "${GITHUB_BASE}/${remote_path}"; then
    mv "${local_path}.tmp" "${local_path}"
    chmod +x "${local_path}" 2>/dev/null || true
    echo -e "${green}✅ Berhasil${NC}"
  else
    echo -e "${red}❌ Gagal download ${remote_path}${NC}"
    rm -f "${local_path}.tmp"
  fi
}

# Fungsi update semua file
update_semua() {
  echo -e "${yellow}═════════════════════════════════════════════════${NC}"
  echo -e "${green}      MEMULAI PROSES UPDATE FILE${NC}"
  echo -e "${yellow}═════════════════════════════════════════════════${NC}"
  echo ""

  declare -A FILES_MAP
  FILES_MAP["requirements/req-setup/versi"]="${LOCAL_VER}"
  FILES_MAP["requirements/req-setup/menu/menu.sh"]="/usr/bin/menu"
  FILES_MAP["requirements/req-setup/menu/ssh/m-sshovpn.sh"]="/usr/bin/m-sshovpn"
  FILES_MAP["requirements/req-setup/menu/xray/m-vmess.sh"]="/usr/bin/m-vmess"
  FILES_MAP["requirements/req-setup/menu/xray/m-vless.sh"]="/usr/bin/m-vless"
  FILES_MAP["requirements/req-setup/menu/xray/m-trojan.sh"]="/usr/bin/m-trojan"
  FILES_MAP["requirements/req-setup/menu/xray/m-ssws.sh"]="/usr/bin/m-ssws"
  FILES_MAP["requirements/req-setup/menu/system/m-system.sh"]="/usr/bin/m-system"
  FILES_MAP["requirements/req-setup/menu/system/bw.sh"]="/usr/bin/bw"
  FILES_MAP["requirements/req-setup/menu/system/tcp.sh"]="/usr/bin/tcp"
  FILES_MAP["requirements/req-setup/menu/system/m-dns.sh"]="/usr/bin/m-dns"
  FILES_MAP["requirements/req-setup/menu/system/auto-reboot.sh"]="/usr/bin/auto-reboot"
  FILES_MAP["requirements/req-setup/menu/system/restart.sh"]="/usr/bin/restart"
  FILES_MAP["requirements/req-setup/menu/system/certv2ray.sh"]="/usr/bin/certv2ray"
  FILES_MAP["requirements/req-setup/menu/system/add-host.sh"]="/usr/bin/add-host"
  FILES_MAP["requirements/req-setup/menu/system/speedtest_cli.py"]="/usr/bin/speedtest"
  FILES_MAP["requirements/req-setup/menu/system/xpnotnormal.sh"]="/usr/bin/xp"
  FILES_MAP["requirements/req-setup/menu/system/m-domain.sh"]="/usr/bin/m-domain"
  FILES_MAP["requirements/req-setup/menu/system/certv2rayforce.sh"]="/usr/bin/certv2rayforce"
  FILES_MAP["requirements/req-setup/menu/system/sshws.sh"]="/usr/bin/sshws"
  FILES_MAP["requirements/req-setup/menu/ssh/usernew.sh"]="/usr/bin/usernew"
  FILES_MAP["requirements/req-setup/menu/ssh/trial.sh"]="/usr/bin/trial"
  FILES_MAP["requirements/req-setup/menu/ssh/renew.sh"]="/usr/bin/renew"
  FILES_MAP["requirements/req-setup/menu/ssh/delete.sh"]="/usr/bin/delete"
  FILES_MAP["requirements/req-setup/menu/ssh/hapus.sh"]="/usr/bin/hapus"
  FILES_MAP["requirements/req-setup/menu/ssh/cek.sh"]="/usr/bin/cek"
  FILES_MAP["requirements/req-setup/menu/ssh/member.sh"]="/usr/bin/member"
  FILES_MAP["requirements/req-setup/menu/ssh/ceklim.sh"]="/usr/bin/ceklim"
  FILES_MAP["requirements/req-setup/menu/ssh/user-lock.sh"]="/usr/bin/user-lock"
  FILES_MAP["requirements/req-setup/menu/ssh/user-unlock.sh"]="/usr/bin/user-unlock"
  FILES_MAP["requirements/req-setup/menu/ssh/tendang.sh"]="/usr/bin/tendang"
  FILES_MAP["requirements/req-setup/menu/ssh/autokill.sh"]="/usr/bin/autokill"
  FILES_MAP["requirements/req-setup/menu/ssh/sshws.sh"]="/usr/bin/sshws"
  FILES_MAP["requirements/req-setup/menu/ssh/menu.sh"]="/usr/bin/menu-ssh"

  for remote in "${!FILES_MAP[@]}"; do
    local_path="${FILES_MAP[$remote]}"
    download_file "${remote}" "${local_path}"
  done

  echo ""
  echo -e "${yellow}═════════════════════════════════════════════════${NC}"
  echo -e "${green}      UPDATE FILE SELESAI${NC}"
  echo -e "${yellow}═════════════════════════════════════════════════${NC}"
# Fungsi restart service
restart_services() {
  echo -e "${yellow}🔄 Merestart layanan...${NC}"

  systemctl restart nginx 2>/dev/null && echo -e "${green}✅ Nginx${NC}" || echo -e "${red}⚠️  Nginx${NC}"
  systemctl restart xray 2>/dev/null && echo -e "${green}✅ Xray${NC}" || echo -e "${red}⚠️  Xray${NC}"

  echo -e "${green}✅ Semua layanan telah di-restart${NC}"
}

# Eksekusi utama
cek_versi
update_semua
restart_services

# Simpan versi baru
if [ -f "${LOCAL_REQ_DIR}/versi" ]; then
  cp "${LOCAL_REQ_DIR}/versi" "${LOCAL_VER}"
fi

# Bersihkan
rm -rf "${LOCAL_REQ_DIR}"

echo ""
echo -e "${green}╔════════════════════════════════════════════════╗${NC}"
echo -e "${green}      ✅ UPDATE SELESAI!${NC}"
echo -e "${yellow}      VPS Anda sekarang menggunakan versi terbaru${NC}"
echo -e "${green}╚════════════════════════════════════════════════╝${NC}"
echo ""

read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
menu 2>/dev/null || exit 0
}
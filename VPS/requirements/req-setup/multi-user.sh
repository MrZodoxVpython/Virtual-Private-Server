#!/bin/bash
#===================++++===================#
# AUTHOR    : BENJAMIN.WICKMAN
# SUPPORTER : TOKOMARD
#===================++++===================#
# Fungsi : Deteksi multi-login akun Xray (vmess/vless/trojan)
# Log     : /var/log/xray/access.log
#==========================================#

LOGFILE="/var/log/xray/access.log"
TAIL_LINES=500
THRESHOLD=1  # tampilkan akun yang login dari >1 IP

# Warna
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
BLUE='\033[1;34m'
NC='\033[0m'

clear
echo -e "${PURPLE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║        XRAY MULTI-LOGIN MONITOR - TOKOMARD         ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}Log digunakan:${NC} $LOGFILE"
echo -e "${CYAN}Analisis:${NC} ${TAIL_LINES} baris terakhir"
echo -e "${CYAN}Batas multi-login:${NC} > ${THRESHOLD} IP unik"
echo

if [ ! -f "$LOGFILE" ]; then
  echo -e "${RED}❌ File log tidak ditemukan:${NC} $LOGFILE"
  exit 1
fi

# Proses log dan sortir hasilnya berdasarkan username
RESULT=$(
  tail -n "$TAIL_LINES" "$LOGFILE" | \
  awk -v red="$RED" -v yellow="$YELLOW" -v green="$GREEN" -v nc="$NC" -v threshold="$THRESHOLD" '
  {
    match($0, /([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*email:[[:space:]]*([a-zA-Z0-9._-]+)/, m)
    if (m[1] != "" && m[2] != "") {
      user = m[2]
      ip = m[1]
      data[user][ip] = 1
    }
  }
  END {
    for (u in data) {
      count = 0
      iplist = ""
      for (i in data[u]) {
        count++
        iplist = iplist i ", "
      }

      # Pewarnaan berdasarkan jumlah IP
      if (count > 10)
        color = red
      else if (count > threshold)
        color = yellow
      else
        color = green

      printf "%s%-25s %-10d %s%s\n", color, u, count, iplist, nc
    }
  }' | sort
)

# Cetak header (selalu di atas)
printf "${BLUE}%-25s %-10s %s${NC}\n" "USERNAME" "IP_COUNT" "IP_LIST"
echo "---------------------------------------------------------------"
echo "$RESULT"

echo
echo -e "${PURPLE}Selesai memindai.${NC} Jika ada ${YELLOW}kuning${NC} atau ${RED}merah${NC}, berarti akun itu kemungkinan multi-login!"

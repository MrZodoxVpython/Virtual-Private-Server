#!/bin/bash
#===================++++===================#
# AUTHOR    : BENJAMIN.WICKMAN
# TELEGRAM  : MrZodoxVpython
# DISCORD   : benjaminwickman
# INSTA     : benjamin.wickman
# SUPPORTER : TOKOMARD
#===================++++===================#

CONFIG_FILE="/etc/xray/config.json"

read -rp "Masukkan KEY (UUID/PASSWORD): " KEY
read -rp "Masukkan Username/Email: " USER
read -rp "Masukkan Tanggal Expired (format: YYYY-MM-DD): " EXP
read -rp "Masukkan Protokol (vmess/vless/trojan/ss): " PROTOCOL

# ===== Validasi input dasar ===== #
if [[ -z "$KEY" || -z "$USER" || -z "$EXP" || -z "$PROTOCOL" ]]; then
  echo "❌ Input tidak lengkap. Silakan isi semua data."
  exit 1
fi

# Validasi format tanggal
if ! date -d "$EXP" &>/dev/null; then
  echo "❌ Format tanggal salah. Gunakan format YYYY-MM-DD."
  exit 1
fi

# ===== Pemetaan protokol ke tag di config.json =====
declare -A PROTOCOL_TAGS=(
  ["vmess"]="vmess vmessgrpc"
  ["vless"]="vless vlessgrpc"
  ["ss"]="ssws ssgrpc"
  ["trojan"]="trojanws trojangrpc"
)

# Pastikan protokol valid
if [[ -z "${PROTOCOL_TAGS[$PROTOCOL]}" ]]; then
  echo "❌ Protokol tidak dikenali. Gunakan salah satu: vmess, vless, trojan, ss"
  exit 1
fi

# ===== Siapkan COMMENT_PREFIX dan JSON_ENTRY (dengan awalan '},') =====
case "$PROTOCOL" in
  vmess)
    COMMENT_PREFIX="###"
    JSON_ENTRY="        },{\"id\": \"$KEY\", \"alterId\": 0,\"email\": \"$USER\""
    TAG_LIST=( ${PROTOCOL_TAGS[$PROTOCOL]} )
    ;;
  vless)
    COMMENT_PREFIX="#&"
    JSON_ENTRY="        },{\"id\": \"$KEY\",\"email\": \"$USER\""
    TAG_LIST=( ${PROTOCOL_TAGS[$PROTOCOL]} )
    ;;
  ss)
    COMMENT_PREFIX="###"
    JSON_ENTRY="        },{\"method\": \"aes-128-gcm\", \"password\": \"$KEY\", \"email\": \"$USER\""
    TAG_LIST=( ${PROTOCOL_TAGS[$PROTOCOL]} )
    ;;
  trojan)
    COMMENT_PREFIX="#!"
    JSON_ENTRY="        },{\"password\": \"$KEY\",\"email\": \"$USER\""
    TAG_LIST=( ${PROTOCOL_TAGS[$PROTOCOL]} )
    ;;
esac

# ===== Backup config.json =====
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak-$(date +%Y%m%d%H%M%S)"

# ===== Fungsi menyisipkan ke satu tag =====
insert_into_tag() {
  local TAG="$1"
  local LINE_NUM

  # Cari baris pertama yang mengandung "#TAG"
  LINE_NUM=$(grep -n "#${TAG}" "$CONFIG_FILE" | cut -d: -f1 | head -n1)
  if [[ -n "$LINE_NUM" ]]; then
    local INSERT_LINE=$(( LINE_NUM + 1 ))
    local COMMENT_LINE="        ${COMMENT_PREFIX} $USER $EXP"

    # Sisipkan baris komentar
    sed -i "${INSERT_LINE}i ${COMMENT_LINE}" "$CONFIG_FILE"
    # Sisipkan JSON_ENTRY tepat di bawah komentar
    sed -i "$((INSERT_LINE + 1))i ${JSON_ENTRY}" "$CONFIG_FILE"

    echo "✅ Disisipkan di #${TAG}"
  else
    echo "⚠  Tag #${TAG} tidak ditemukan di config.json"
  fi
}

# ===== Sisipkan ke setiap tag yang terdaftar =====
for TAG in "${TAG_LIST[@]}"; do
  insert_into_tag "$TAG"
done

echo "✅ Akun $PROTOCOL berhasil ditambahkan untuk user $USER (expired $EXP)."


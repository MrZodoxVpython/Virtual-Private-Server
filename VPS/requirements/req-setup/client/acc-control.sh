#!/bin/bash
#==================================================#
# Author    : BENJAMIN WICKMAN
# Supporter : TOKOMARD
# WhatsApp  : 6285941868955
# Discord   : benjaminwickman
# Github    : MrZodoxVpython
# Telegram  : MrZodoxVpython
# Instagram : Benjamin.Wickman
#==================================================#

CONFIG_FILE="/etc/xray/config.json"
LOCKED_DATE_DIR="/etc/xray/locked_dates"
LOCKED_BACKUP_DIR="/etc/xray/locked_backup"
LOG_FILE="/var/log/xray/akuncontrol.log"

declare -A PROTOCOL_TAGS=(
  ["vmess"]="vmess vmessgrpc"
  ["vless"]="vless vlessgrpc"
  ["ss"]="ssws ssgrpc"
  ["trojan"]="trojanws trojangrpc"
)

mkdir -p "$LOCKED_DATE_DIR" "$LOCKED_BACKUP_DIR" "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

function log_action() {
  local action="$1"
  local user="$2"
  local proto="$3"
  local tag="$4"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$action] [$proto] [$tag] $user" >> "$LOG_FILE"
}

function list_locked_accounts() {
  local current_tag=""
  local locked_users=()
  local total_lines
  total_lines=$(wc -l < "$CONFIG_FILE")
  mapfile -t tag_lines < <(grep -n "^#\\w\+" "$CONFIG_FILE" | cut -d: -f1)
  tag_lines+=("$((total_lines + 1))")

  for ((i=0; i < ${#tag_lines[@]} -1; i++)); do
    local start_line=${tag_lines[i]}
    local end_line=${tag_lines[i+1]}
    current_tag=$(sed -n "${start_line}p" "$CONFIG_FILE" | sed 's/^#//')
    mapfile -t block_lines < <(sed -n "$((start_line + 1)),$((end_line - 1))p" "$CONFIG_FILE")

    for ((j=0; j < ${#block_lines[@]}; j++)); do
      line="${block_lines[j]}"
      if [[ "$line" =~ ^#![[:space:]]*([a-zA-Z0-9_]+)[[:space:]]+locked ]]; then
        username="${BASH_REMATCH[1]}"
        locked_users+=("$current_tag - $username")
      elif [[ "$line" =~ ^###[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        username="${BASH_REMATCH[1]}"
        next_index=$((j+1))
        if (( next_index < ${#block_lines[@]} )) && [[ "${block_lines[next_index]}" == "##LOCK##" ]]; then
          locked_users+=("$current_tag - $username")
        fi
      fi
    done
  done

  if [[ ${#locked_users[@]} -eq 0 ]]; then
    echo "❌ Tidak ada akun yang dikunci."
  else
    echo "🔒 Daftar akun yang dikunci:"
    for entry in "${locked_users[@]}"; do
      echo " - $entry"
    done
  fi
}

function save_original_date() {
  echo "$3" > "$LOCKED_DATE_DIR/${1}_${2}.date"
}

function get_original_date() {
  local file="$LOCKED_DATE_DIR/${1}_${2}.date"
  [[ -f "$file" ]] && cat "$file" || echo ""
}

function remove_original_date() {
  rm -f "$LOCKED_DATE_DIR/${1}_${2}.date"
}

function save_backup_line() {
  echo "$3" > "$LOCKED_BACKUP_DIR/${1}_${2}.txt"
}

function get_backup_line() {
  local file="$LOCKED_BACKUP_DIR/${1}_${2}.txt"
  [[ -f "$file" ]] && cat "$file" || echo ""
}

function remove_backup_line() {
  rm -f "$LOCKED_BACKUP_DIR/${1}_${2}.txt"
}

function escape_sed() {
  echo "$1" | sed -e 's/[\/&]/\\&/g'
}

function process_account_in_tag() {
  local target_user="$1"
  local target_user_esc="$2"
  local proto="$3"
  local tag="$4"
  local action="$5"

  total_lines=$(wc -l < "$CONFIG_FILE")
  tag_line_num=$(grep -n "^#$tag$" "$CONFIG_FILE" | head -n1 | cut -d: -f1)
  [[ -z "$tag_line_num" ]] && return 0

  next_tag_line_num=$(grep -n "^#\\w\+" "$CONFIG_FILE" | cut -d: -f1 | awk -v start="$tag_line_num" '$1 > start {print $1; exit}')
  [[ -z "$next_tag_line_num" ]] && next_tag_line_num=$((total_lines + 1))

  mapfile -t block_lines < <(sed -n "$((tag_line_num + 1)),$((next_tag_line_num - 1))p" "$CONFIG_FILE")

  if [[ "$proto" == "trojan" ]]; then
    local user_line_index=-1
    for i in "${!block_lines[@]}"; do
      if [[ "${block_lines[i]}" =~ ^#![[:space:]]*$target_user_esc[[:space:]]+([0-9]{4}-[0-9]{2}-[0-9]{2}|locked)$ ]]; then
        user_line_index=$i
        break
      fi
    done
    (( user_line_index == -1 )) && return 0

    local abs_line_num=$((tag_line_num + 1 + user_line_index))
    local next_line_index=$((user_line_index + 1))
    local next_line="${block_lines[next_line_index]}"

    if [[ "$action" == "lock" ]]; then
      [[ "${block_lines[user_line_index]}" =~ locked$ ]] && { echo "✅ Akun '$target_user' sudah dikunci di $tag."; return 2; }
      [[ "${block_lines[user_line_index]}" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]] && save_original_date "$target_user" "$tag" "${BASH_REMATCH[1]}"
      save_backup_line "$target_user" "$tag" "$next_line"

      sed -i "${abs_line_num}s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\$/locked/" "$CONFIG_FILE"
      sed -i "$((abs_line_num + 1))s@\"password\"[[:space:]]*:[[:space:]]*\"[^\"]*\"@\"password\": \"locked\"@" "$CONFIG_FILE"

      log_action "LOCK" "$target_user" "$proto" "$tag"
      echo "✅ Akun '$target_user' berhasil dikunci di $tag."
      return 1
    else
      [[ "${block_lines[user_line_index]}" =~ locked$ ]] || return 0

      local orig_date=$(get_original_date "$target_user" "$tag")
      local backup_line=$(get_backup_line "$target_user" "$tag")
      [[ -z "$orig_date" ]] && orig_date=$(date -d "+30 days" +"%Y-%m-%d")

      # Escape variabel untuk sed
      local orig_date_esc
      local backup_line_esc
      orig_date_esc=$(escape_sed "$orig_date")
      backup_line_esc=$(escape_sed "$backup_line")

      sed -i "${abs_line_num}s@locked\$@${orig_date_esc}@" "$CONFIG_FILE"

      sed -i "$((abs_line_num + 1))d" "$CONFIG_FILE"
      sed -i "$((abs_line_num + 1))i ${backup_line_esc}" "$CONFIG_FILE"

      remove_original_date "$target_user" "$tag"
      remove_backup_line "$target_user" "$tag"
      log_action "UNLOCK" "$target_user" "$proto" "$tag"
      echo "✅ Akun '$target_user' berhasil dibuka kuncinya di $tag."
      return 1
    fi
  else
    local line_num_in_block=-1
    for i in "${!block_lines[@]}"; do
      if [[ "${block_lines[i]}" =~ ^###[[:space:]]+$target_user_esc[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        line_num_in_block=$i
        break
      fi
    done
    (( line_num_in_block == -1 )) && return 0

    local next_line_index=$((line_num_in_block + 1))
    local abs_line_num=$((tag_line_num + 1 + next_line_index))
    local next_line="${block_lines[next_line_index]}"

    if [[ "$action" == "lock" ]]; then
      [[ "$next_line" == "##LOCK##" ]] && { echo "✅ Akun '$target_user' sudah dikunci di $tag."; return 2; }
      [[ "${block_lines[line_num_in_block]}" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]] && save_original_date "$target_user" "$tag" "${BASH_REMATCH[1]}"
      save_backup_line "$target_user" "$tag" "$next_line"

      sed -i "$abs_line_num"d "$CONFIG_FILE"
      sed -i "$((abs_line_num))i ##LOCK##" "$CONFIG_FILE"

      log_action "LOCK" "$target_user" "$proto" "$tag"
      echo "✅ Akun '$target_user' berhasil dikunci di $tag."
      return 1
    else
      [[ "$next_line" == "##LOCK##" ]] || return 0

      local orig_line
      orig_line=$(get_backup_line "$target_user" "$tag")
      local orig_date=$(get_original_date "$target_user" "$tag")

      sed -i "$((abs_line_num))d" "$CONFIG_FILE"
      if [[ -n "$orig_line" ]]; then
        sed -i "$((abs_line_num - 1))d" "$CONFIG_FILE"
        sed -i "$((abs_line_num - 1))i ### $target_user $orig_date" "$CONFIG_FILE"
        sed -i "$((abs_line_num))i $orig_line" "$CONFIG_FILE"
      fi

      remove_original_date "$target_user" "$tag"
      remove_backup_line "$target_user" "$tag"
      log_action "UNLOCK" "$target_user" "$proto" "$tag"
      echo "✅ Akun '$target_user' berhasil dibuka kuncinya di $tag."
      return 1
    fi
  fi
}

function lock_unlock_account() {
  local action="$1"
  read -rp "Masukkan nama akun: " target_user
  [[ -z "$target_user" ]] && { echo "❌ Nama akun tidak boleh kosong."; read -rp "Tekan Enter untuk kembali ke menu..."; return; }

  target_user_esc=$(printf '%s\n' "$target_user" | sed 's/[][\\/*.^$]/\\&/g')
  local changed=0
  local found=0

  for proto in "${!PROTOCOL_TAGS[@]}"; do
    for tag in ${PROTOCOL_TAGS[$proto]}; do
      process_account_in_tag "$target_user" "$target_user_esc" "$proto" "$tag" "$action"
      ret=$?
      (( ret == 1 || ret == 2 )) && { changed=1; found=1; }
    done
  done

  [[ $found -eq 0 ]] && echo "❌ Akun '$target_user' tidak ditemukan di semua protokol."
  read -rp "Tekan Enter untuk kembali ke menu..."
}

function auto_lock_install() {
#==================================================#
# Author    : BENJAMIN WICKMAN
# Supporter : TOKOMARD
# WhatsApp  : 6285941868955
# Discord   : benjaminwickman
# Github    : MrZodoxVpython
# Telegram  : MrZodoxVpython
# Instagram : Benjamin.Wickman
#==================================================#

CONFIG_FILE="/etc/xray/config.json"
LOCKED_DATE_DIR="/etc/xray/locked_dates"
LOCKED_BACKUP_DIR="/etc/xray/locked_backup"
LOG_FILE="/var/log/xray/akuncontrol.log"
CRON_FILE="/etc/cron.d/auto-lock"

declare -A PROTOCOL_TAGS=(
  ["vmess"]="vmess vmessgrpc"
  ["vless"]="vless vlessgrpc"
  ["ss"]="ssws ssgrpc"
  ["trojan"]="trojanws trojangrpc"
)

setup_dirs_and_files() {
  mkdir -p "$LOCKED_DATE_DIR" "$LOCKED_BACKUP_DIR" "$(dirname "$LOG_FILE")"
  touch "$LOG_FILE"
}

log_action() {
  local action="$1"
  local user="$2"
  local proto="$3"
  local tag="$4"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$action] [$proto] [$tag] $user" >> "$LOG_FILE"
}

save_original_date() {
  echo "$3" > "$LOCKED_DATE_DIR/${1}_${2}.date"
}

save_backup_line() {
  echo "$3" > "$LOCKED_BACKUP_DIR/${1}_${2}.txt"
}

auto_lock_accounts() {
  local today_ts
  today_ts=$(date +%s)

  for proto in "${!PROTOCOL_TAGS[@]}"; do
    for tag in ${PROTOCOL_TAGS[$proto]}; do
      tag_line_num=$(grep -n "^#$tag\$" "$CONFIG_FILE" | cut -d: -f1)
      [[ -z "$tag_line_num" ]] && continue

      total_lines=$(wc -l < "$CONFIG_FILE")
      next_tag_line_num=$(grep -n "^#\w\+" "$CONFIG_FILE" | cut -d: -f1 | awk -v start="$tag_line_num" '$1 > start {print $1; exit}')
      [[ -z "$next_tag_line_num" ]] && next_tag_line_num=$((total_lines + 1))

      mapfile -t block_lines < <(sed -n "$((tag_line_num + 1)),$((next_tag_line_num - 1))p" "$CONFIG_FILE")

      if [[ "$proto" == "trojan" ]]; then
        for i in "${!block_lines[@]}"; do
          line="${block_lines[i]}"
          if [[ "$line" =~ ^#![[:space:]]*([a-zA-Z0-9_]+)[[:space:]]+([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
            username="${BASH_REMATCH[1]}"
            exp="${BASH_REMATCH[2]}"
            exp_ts=$(date -d "$exp" +%s 2>/dev/null)
            if [[ -z "$exp_ts" ]]; then
              echo "⚠ Gagal parsing tanggal untuk user $username di $tag: $exp"
              continue
            fi
            if (( exp_ts < today_ts )); then
              next_index=$((i+1))
              next_line=""
              if (( next_index < ${#block_lines[@]} )); then
                next_line="${block_lines[next_index]}"
              fi
              abs_line_num=$((tag_line_num + 1 + i))

              save_original_date "$username" "$tag" "$exp"
              save_backup_line "$username" "$tag" "$next_line"

              sed -i "${abs_line_num}s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\$/locked/" "$CONFIG_FILE"
              sed -i "$((abs_line_num + 1))s@\"password\"[[:space:]]*:[[:space:]]*\"[^\"]*\"@\"password\": \"locked\"@" "$CONFIG_FILE"

              log_action "LOCK" "$username" "$proto" "$tag"
              echo "✅ Akun '$username' (expired $exp) dikunci di $tag"
            fi
          fi
        done
      else
        for i in "${!block_lines[@]}"; do
          line="${block_lines[i]}"
          if [[ "$line" =~ ^###[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]+([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
            username="${BASH_REMATCH[1]}"
            exp="${BASH_REMATCH[2]}"
            exp_ts=$(date -d "$exp" +%s 2>/dev/null)
            if [[ -z "$exp_ts" ]]; then
              echo "⚠ Gagal parsing tanggal untuk user $username di $tag: $exp"
              continue
            fi
            next_index=$((i+1))
            next_line=""
            if (( next_index < ${#block_lines[@]} )); then
              next_line="${block_lines[next_index]}"
            fi
            if (( exp_ts < today_ts )) && [[ "$next_line" != "##LOCK##" ]]; then
              abs_line_num=$((tag_line_num + 1 + next_index))

              save_original_date "$username" "$tag" "$exp"
              save_backup_line "$username" "$tag" "$next_line"

              sed -i "${abs_line_num}d" "$CONFIG_FILE"
              sed -i "$((abs_line_num))i ##LOCK##" "$CONFIG_FILE"

              log_action "LOCK" "$username" "$proto" "$tag"
              echo "✅ Akun '$username' (expired $exp) dikunci di $tag"
            fi
          fi
        done
      fi
    done
  done
}

install_cronjob() {
  echo "Memasang cron job auto-lock di /etc/cron.d/auto-lock"
  cat <<EOF > "$CRON_FILE"
# Auto-lock Xray VPN accounts at midnight every day
0 0 * * * root /etc/xray/auto-lock.sh
EOF
  chmod 644 "$CRON_FILE"
  echo "✅ Cron job terpasang."
}

show_usage() {
  echo "Usage:"
  echo "  $0          --> menjalankan auto-lock"
  echo "  $0 --install  --> setup direktori, file, dan pasang cron job"
}

if [[ "$1" == "--install" ]]; then
  echo "=== Memulai instalasi auto-lock ==="
  setup_dirs_and_files
  install_cronjob
  echo "=== Instalasi selesai ==="
  exit 0
fi

# Jika bukan install, jalankan auto-lock normal
setup_dirs_and_files
auto_lock_accounts


}

while true; do
  clear
  echo "=== MENU KUNCI AKUN Xray VPN ==="
  echo "1. Lihat daftar akun yang dikunci"
  echo "2. Kunci akun"
  echo "3. Buka kunci akun"
  echo "4. Install auto-lock"
  echo "0. Keluar"
  read -rp "Pilih menu: " menu
  case $menu in
    1) clear; list_locked_accounts; read -rp "Tekan Enter untuk kembali ke menu...";;
    2) clear; lock_unlock_account "lock";;
    3) clear; lock_unlock_account "unlock";;
    4) clear; auto_lock_install "--install";;
    0) echo "Bye!"; exit 0;;
    *) echo "Pilihan tidak valid."; sleep 1;;
  esac
done

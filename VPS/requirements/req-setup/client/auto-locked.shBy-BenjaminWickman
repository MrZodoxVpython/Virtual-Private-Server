#!/bin/bash
#======================++++=======================#
# Author    : BENJAMIN WICKMAN
# Supporter : TOKOMARD
# WhatsApp  : 6285941868955
# Discord   : benjaminwickman
# Github    : MrZodoxVpython
# Telegram  : MrZodoxVpython
# Instagram : Benjamin.Wickman
#======================++++=======================#
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
  local locked_any=false

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
              locked_any=true
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
              locked_any=true
              echo "✅ Akun '$username' (expired $exp) dikunci di $tag"
            fi
          fi
        done
      fi
    done
  done

  if $locked_any; then
    echo "🔄 Restarting Xray service..."
    systemctl restart xray
  fi

}

# Setup direktori dan file log
mkdir -p "$LOCKED_DATE_DIR" "$LOCKED_BACKUP_DIR" "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Jalankan fungsi auto lock akun
auto_lock_accounts

cat > /etc/systemd/system/autocommit.service <<EOF
[Unit]
Description=Multi-Repo Git Auto Commit & Push
After=network.target

[Service]
ExecStart=/etc/xray/autocommit.sh
Restart=always
User=root
Environment=GIT_SSH_COMMAND=ssh

[Install]
WantedBy=multi-user.target
EOF
cat > /etc/xray/autocommit.sh <<EOF
#!/bin/bash

# Daftar direktori git yang ingin dimonitor
WATCH_REPOS=(
  "/var/www/html/Website-Tokomard-Panel"
  "/var/www/html/telegram_bot_panel"
  # Tambahkan repo lain di sini
)

echo "🌀 Auto-commit watcher started..."
echo "🔍 Monitoring these repos:"
for dir in "${WATCH_REPOS[@]}"; do
    echo " - $dir"
done

# Loop selamanya
while true; do
    # Tunggu perubahan di semua repo
    inotifywait -r -e modify,create,delete,move "${WATCH_REPOS[@]}"

    # Setelah perubahan terdeteksi, iterasi semua repo
    for repo in "${WATCH_REPOS[@]}"; do
        if [ -d "$repo/.git" ]; then
            cd "$repo" || continue

            # Tambahkan dan commit jika ada perubahan
            if ! git diff --quiet || ! git diff --cached --quiet; then
                git add .
                git commit -m "Auto commit developing progress By Benjamin.Wickman : $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null

                # Push ke origin (main/master tergantung)
                git push origin main #HEAD 2>/dev/null

                echo "✅ Changes committed in $repo"
            fi
        fi
    done
done

EOF
# Ubah permission
chmod 644 /etc/systemd/system/autocommit.service
chmod +x /etc/xray/autocommit.sh

# Reload systemd agar service dikenali
systemctl daemon-reexec
systemctl daemon-reload

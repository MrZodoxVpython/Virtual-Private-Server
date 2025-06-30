cat > /etc/systemd/system/autocommit.service <<EOF
[Unit]
Description=Auto Commit and Push Git Changes
After=network.target

[Service]
ExecStart=/etc/xray/autocommit.sh
WorkingDirectory=/var/www/html/Website-Tokomard-Panel
Restart=always
User=root
Environment=GIT_SSH_COMMAND=ssh

[Install]
WantedBy=multi-user.target
EOF

# Ubah permission
chmod 644 /etc/systemd/system/autocommit.service

# Reload systemd agar service dikenali
systemctl daemon-reexec
systemctl daemon-reload

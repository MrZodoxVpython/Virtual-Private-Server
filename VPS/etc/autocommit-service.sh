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

# Ubah permission
chmod 644 /etc/systemd/system/autocommit.service
chmod +x /etc/xray/autocommit.sh

# Reload systemd agar service dikenali
systemctl daemon-reexec
systemctl daemon-reload

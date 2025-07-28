#!/bin/bash

# 🛑 Hanya bisa dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Script ini harus dijalankan sebagai root!"
  exit 1
fi

# 📥 Minta input hostname baru
read -p "Masukkan hostname baru (tanpa spasi): " NEW_HOSTNAME

# ✅ Validasi input
if [[ -z "$NEW_HOSTNAME" ]]; then
  echo "❌ Hostname tidak boleh kosong!"
  exit 1
fi

# 📛 Tampilkan hostname saat ini
echo "📛 Hostname saat ini: $(hostname)"

# 📝 Simpan hostname baru ke /etc/hostname
echo "$NEW_HOSTNAME" > /etc/hostname

# 🔧 Update /etc/hosts (ganti baris 127.0.1.1 jika ada)
if grep -q "127.0.1.1" /etc/hosts; then
  sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
else
  echo -e "127.0.1.1\t$NEW_HOSTNAME" >> /etc/hosts
fi

# 💡 Terapkan hostname tanpa reboot
hostnamectl set-hostname "$NEW_HOSTNAME"

# ✅ Konfirmasi
echo "✅ Hostname berhasil diubah menjadi: $NEW_HOSTNAME"
exec bash

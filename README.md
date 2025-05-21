<h2 align="center">
  <img src="https://readme-typing-svg.herokuapp.com/?color=Benjamin_Tokomard_Dev&center=true&vCenter=true&lines=Supported+Linux+Distribution"><br>
  <img src="https://user-images.githubusercontent.com/76937659/153705486-44e6c1b2-74fa-4d44-be1c-36c8fdb83331.gif"/>
</h2>

<p align="center">
  <img src="https://d33wubrfki0l68.cloudfront.net/5911c43be3b1da526ed609e9c55783d9d0f6b066/9858b/assets/img/debian-ubuntu-hover.png">
</p>

<p align="center">
  <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=debian&label=Debian%209&message=Stretch&color=purple">
  <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=debian&label=Debian%2010&message=Buster&color=purple">
  <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=ubuntu&label=Ubuntu%2018&message=Lts&color=red">
  <img src="https://img.shields.io/static/v1?style=for-the-badge&logo=ubuntu&label=Ubuntu%2020&message=Lts&color=red">
</p>

---

## ✅ Supported Services

<p align="center">
  <img src="https://img.shields.io/badge/Service-SSH_Over_Websocket-success.svg">
  <img src="https://img.shields.io/badge/Service-SSH_UDP_Custom-success.svg">
  <img src="https://img.shields.io/badge/Service-SSH_Dropbear-success.svg">
  <img src="https://img.shields.io/badge/Service-Stunnel4-success.svg">
  <img src="https://img.shields.io/badge/Service-Fail2Ban-brightgreen">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Service-XRAY_VLESS-success.svg">
  <img src="https://img.shields.io/badge/Service-XRAY_VMESS-success.svg">
  <img src="https://img.shields.io/badge/Service-XRAY_TROJAN-success.svg">
  <img src="https://img.shields.io/badge/Service-Websocket-success.svg">
  <img src="https://img.shields.io/badge/Service-GRPC-success.svg">
  <img src="https://img.shields.io/badge/Service-Shadowsocks-success.svg">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Service-Webmin-success.svg">
  <img src="https://img.shields.io/badge/Service-Helium-success.svg">
</p>

<p align="center">
  <img src="https://wangchujiang.com/sb/status/stable.svg">
</p>

---

## ⚙️ System Requirements

- ⚠️ **Jika menginstall script 2x, wajib rebuild VPS ke factory default di panel VPS.**
- Domain (wajib) / bisa random
- **Supported OS:**
  - Debian 9 / 10
  - Ubuntu 18.04 / 20.04 LTS
- **Minimum Hardware:**
  - CPU: 1 Core
  - RAM: 1 GB
- ✅ **Rekomendasi:** Ubuntu 18/20 LTS (paling stabil)

---

## 📡 Service & Port

| Service                 | Port        |
|------------------------|-------------|
| OpenSSH                | 22          |
| SSH Websocket          | 80          |
| SSH SSL Websocket      | 443         |
| Stunnel4               | 222, 777    |
| Dropbear               | 109, 143    |
| Badvpn                 | 7100–7900   |
| Nginx                  | 81          |
| Vmess WS TLS           | 443         |
| Vless WS TLS           | 443         |
| Trojan WS TLS          | 443         |
| Shadowsocks WS TLS     | 443         |
| Vmess WS non-TLS       | 80          |
| Vless WS non-TLS       | 80          |
| Trojan WS non-TLS      | 80          |
| Shadowsocks WS non-TLS | 80          |
| Vmess gRPC             | 443         |
| Vless gRPC             | 443         |
| Trojan gRPC            | 443         |
| Shadowsocks gRPC       | 443         |

---

## 🧩 Features

- Speedtest® by [Ookla®](https://speedtest.net)
- Set Auto Reboot
- Restart All Service
- Auto Delete User Expired
- Check Bandwidth
- BBRPLUS v1.4.0 by [Chikage0o0](https://github.com/Chikage0o0)  
  > Apa itu BBR? [Cari di Google](https://www.google.com/search?q=what+bbr+in+linux)
- DNS Changer
- Tidak ada auto-backup (fitur ini dihapus permanen)
- Anda bisa menambah fitur manual sesuai kebutuhan

---

## 🔌 Optional Installation

> Install setelah proses utama selesai

- [OpenVPN + UDP-Custom + SlowDNS](https://github.com/SETANTAZVPN/AutoScriptXray/tree/master/udp-custom)  
  - UDP-Custom by [Exe302](https://gitlab.com/Exe302)  
  - SlowDNS by [SL](https://github.com/fisabiliyusri)

- [Webmin + ADS Block (Helium v3.0)](https://github.com/SETANTAZVPN/AutoScriptXray/tree/master/helium)  
  - by [Abi Darwish](https://github.com/abidarwish)

- [Bot Telegram Panel (XolPanel)](https://github.com/SETANTAZVPN/AutoScriptXray/tree/master/bot%20telegram%20panel)  
  - by [XolvaID](https://github.com/XolvaID)

---

# 💻 Virtual Private Server (VPS)

---

## 🚀 Launch Instalation (One Way)

```bash
wget -O epic-install-setup.sh https://raw.githubusercontent.com/MrZodoxVpython/Virtual-Private-Server/main/VPS/requirements/epic-install-setup.sh && chmod +x epic-install-setup.sh && ./epic-install-setup.sh

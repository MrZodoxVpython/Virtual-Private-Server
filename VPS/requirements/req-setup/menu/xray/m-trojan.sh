#BENJAMINWICKMAN
#TOKOMARD

#!/usr/bin/env bash
set -euo pipefail

trap 'printf "\nBye.\n"; exit 0' SIGINT SIGTERM

MYIP=$(wget -qO- ipv4.icanhazip.com || echo "unknown")

show_menu() {
  clear
  printf '\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n'
  printf '\033[0;100;33m      • TROJAN MENU •          \033[0m\n'
  printf '\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n\n'

  printf ' [\033[36m•1\033[0m] Create Account Trojan\n'
  printf ' [\033[36m•2\033[0m] Trial Account Trojan\n'
  printf ' [\033[36m•3\033[0m] Extending Account Trojan\n'
  printf ' [\033[36m•4\033[0m] Delete Account Trojan\n'
  printf ' [\033[36m•5\033[0m] Check User Login Trojan\n'
  printf ' [\033[36m•6\033[0m] User list created Account\n\n'

  printf ' [\033[36m•0\033[0m] \033[31mBACK TO MENU\033[0m\n\n'
  printf ' Press x or [ Ctrl+C ] • To-Exit\n\n'
  printf '\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n\n'
}

# main loop
while true; do
  show_menu
  read -rp " Select menu : " opt
  echo ""

  case "$opt" in
    1)
      clear
      if command -v add-tr >/dev/null 2>&1; then add-tr; else printf "add-tr: command not found\n"; sleep 2; fi
      ;;
    2)
      clear
      if command -v trialtrojan >/dev/null 2>&1; then trialtrojan; else printf "trialtrojan: command not found\n"; sleep 2; fi
      ;;
    3)
      clear
      if command -v renew-tr >/dev/null 2>&1; then renew-tr; else printf "renew-tr: command not found\n"; sleep 2; fi
      ;;
    4)
      clear
      if command -v del-tr >/dev/null 2>&1; then del-tr; else printf "del-tr: command not found\n"; sleep 2; fi
      ;;
    5)
      clear
      if command -v cek-tr >/dev/null 2>&1; then cek-tr; else printf "cek-tr: command not found\n"; sleep 2; fi
      ;;
    6)
      clear
      if [[ -f /etc/log-create-trojan.log ]]; then
        cat /etc/log-create-trojan.log
      else
        printf "/etc/log-create-trojan.log not found\n"
      fi
      printf "\nAnda punya waktu 15 detik sebelum menu kembali...\n"
      sleep 15
      ;;
    0)
      clear
      if command -v menu >/dev/null 2>&1; then menu; else printf "menu: command not found\n"; sleep 2; fi
      ;;
    x|X)
      printf "Bye.\n"
      exit 0
      ;;
    *)
      printf "Benjamin-notif: Input tidak tersedia!\n"
      sleep 1
      ;;
  esac
done

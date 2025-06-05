#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking Your VPS"
clear
# Animasi loading sederhana
loading_animation() {
    local message="$1"
    local delay=0.1
    local frames=("/" "-" "\\" "|")

    echo -ne "[INFO] $message "
    for i in {1..10}; do
        for frame in "${frames[@]}"; do
            echo -ne "\r[INFO] $message $frame"
            sleep $delay
        done
    done
    echo -ne "\r[INFO] $message [DONE]\n"
}

clear
echo -e "\033[32m=== RAM Cache Cleaner ===\033[0m\n"

# Step 1: Sync filesystem
loading_animation "Flushing file system to disk..."
sync

# Step 2: Clear all caches
loading_animation "Dropping all system caches..."
echo 3 > /proc/sys/vm/drop_caches

# Step 3: Done
echo -e "\n\033[32m[OK]\033[0m Cache cleared successfully!"
echo -e "\nMemory status:\n"
free -h
sleep 5
menu

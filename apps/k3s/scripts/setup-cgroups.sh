#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

backup_and_modify() {
    local cmdline="/boot/firmware/cmdline.txt"
    echo "Creating backup of $cmdline"
    cp "$cmdline" "${cmdline}.backup"
    
    if ! grep -q "cgroup_memory=1 cgroup_enable=memory" "$cmdline"; then
        echo "Adding cgroup parameters"
        sed -i "$ s/$/ cgroup_memory=1 cgroup_enable=memory/" "$cmdline"
        echo "Updated $cmdline"
        cat "$cmdline"
        echo -e "\nSystem needs to be rebooted to apply changes"
    else
        echo "Cgroup parameters already present"
    fi
}

backup_and_modify

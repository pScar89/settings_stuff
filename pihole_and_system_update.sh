#!/bin/bash

# Define log file
log_file="/var/log/update_log"

# Function to log with date and message
log_with_date() {
    echo "$(date '+%F %H:%M:%S') - $1" >>"$log_file"
}

# Updating APT packages and logging
if apt-get update && apt full-upgrade -y && apt autoremove -y && apt autoclean -y; then
    log_with_date "APT update and maintenance successful."
else
    log_with_date "APT update and maintenance failed."
    exit 1
fi

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    log_with_date "System reboot is required."
    sudo reboot
else
    log_with_date "System reboot is not required."
fi

# Log separator for readability
echo -e "\n ------------- \n" >>"$log_file"

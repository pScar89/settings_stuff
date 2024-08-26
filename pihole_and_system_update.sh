#!/bin/bash

# Define log directory and file
log_dir="/home/beast/cronlog"
log_file="${log_dir}/update_log"

# Check if log directory exists, create if not
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

# Function to log with date and message
log_with_date() {
    echo "$(date '+%F %H:%M:%S') - $1" >> "$log_file"
}

# Updating APT packages and logging
if apt-get update && apt full-upgrade -y && apt autoremove -y && apt autoclean -y; then
    log_with_date "APT update and maintenance successful."
else
    log_with_date "APT update and maintenance failed."
    exit 1
fi

# Updating Pi-hole and logging
if pihole updatePihole; then
    log_with_date "Pi-hole update successful."
else
    log_with_date "Pi-hole update failed."
    exit 1
fi

# Updating Gravity and logging
if pihole updateGravity; then
    log_with_date "Gravity update successful."
else
    log_with_date "Gravity update failed."
    exit 1
fi

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    log_with_date "System reboot is required."
else
    log_with_date "System reboot is not required."
fi

# Log separator for readability
echo -e "\n ------------- \n" >> "$log_file"
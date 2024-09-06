#!/bin/bash

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y ufw fail2ban unattended-upgrades

# Enable and configure UFW (Uncomplicated Firewall)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Configure Fail2Ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Apply security configurations
echo "net.ipv4.conf.all.rp_filter = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 2048" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_synack_retries = 2" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_syn_retries = 5" | sudo tee -a /etc/sysctl.conf

# Apply the changes
sudo sysctl -p

# Enable automatic security updates
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Create the update script
cat << 'EOF' | sudo tee /usr/local/bin/update-system.sh
#!/bin/bash

# Define log file
log_file="/var/log/update_log"

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

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    log_with_date "System reboot is required."
    sudo reboot
else
    log_with_date "System reboot is not required."
fi

# Log separator for readability
echo -e "\n ------------- \n" >> "$log_file"
EOF

# Make the update script executable
sudo chmod +x /usr/local/bin/update-system.sh

# Set up a cron job to run the update script daily at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/update-system.sh") | crontab -

echo "Hardening, configuration, and update setup complete!"

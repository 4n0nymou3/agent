#!/bin/bash
# This script sets up a basic firewall using UFW to protect exposed ports.

# Check if UFW is installed; install it if not found
if ! command -v ufw &> /dev/null
then
    echo "UFW not found, installing..."
    sudo apt-get update && sudo apt-get install -y ufw
fi

# Enable UFW if not already enabled
sudo ufw --force enable

# Allow SSH connections
sudo ufw allow ssh

# Allow necessary ports for xray-core and nginx
sudo ufw allow 80/tcp      # Nginx HTTP
sudo ufw allow 443/tcp     # xray-core and Nginx HTTPS
sudo ufw allow 443/udp
sudo ufw allow 2053/tcp    # Additional port for nginx/xray-core
sudo ufw allow 2053/udp
sudo ufw allow 8443/tcp    # Additional port for nginx/xray-core
sudo ufw allow 8443/udp

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "Firewall configured successfully."

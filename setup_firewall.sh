#!/bin/bash
# This script sets up a basic firewall using nftables to protect exposed ports.

# Check if firewalld is installed and remove it if so
if dpkg -l | grep -qw firewalld; then
    echo "firewalld found. Removing firewalld..."
    sudo apt purge firewalld -yq
fi

# Check if nftables is installed, install if not
if ! command -v nft &> /dev/null; then
    echo "nftables not found, installing..."
    sudo apt-get update && sudo apt-get install -y nftables
fi

# Flush any existing nftables ruleset
sudo nft flush ruleset

# Create a new nftables table and chains
sudo nft add table inet filter
sudo nft 'add chain inet filter input { type filter hook input priority 0; policy drop; }'
sudo nft 'add chain inet filter forward { type filter hook forward priority 0; policy drop; }'
sudo nft 'add chain inet filter output { type filter hook output priority 0; policy accept; }'

# Allow loopback traffic
sudo nft add rule inet filter input iif lo accept

# Allow established and related connections
sudo nft add rule inet filter input ct state established,related accept

# Allow SSH connections (port 22)
sudo nft add rule inet filter input tcp dport 22 accept

# Allow HTTP (port 80) for nginx
sudo nft add rule inet filter input tcp dport 80 accept

# Allow HTTPS (port 443) for xray (only)
sudo nft add rule inet filter input tcp dport 443 accept
sudo nft add rule inet filter input udp dport 443 accept

# Allow additional nginx ports (2053 and 8443)
sudo nft add rule inet filter input tcp dport 2053 accept
sudo nft add rule inet filter input udp dport 2053 accept
sudo nft add rule inet filter input tcp dport 8443 accept
sudo nft add rule inet filter input udp dport 8443 accept

echo "nftables firewall configured successfully."

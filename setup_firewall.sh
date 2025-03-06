#!/bin/bash
# This script sets up a firewall using nftables with a single configuration file.
# It checks for firewalld and removes it if installed, then applies the nftables config.
# It dynamically detects the SSH port from /etc/ssh/sshd_config.

# Paths & Variables
CONFIG_FILE="/etc/nftables.conf"
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_PORT=""

# Function to check and remove firewalld if installed
remove_firewalld() {
    if dpkg -l | grep -qw firewalld; then
        echo "firewalld detected. Removing firewalld..."
        sudo apt purge firewalld -yq
    else
        echo "firewalld not found."
    fi
}

# Function to detect SSH port from sshd_config
find_ssh_port() {
    echo "Detecting SSH port..."
    if [ -f "$SSH_CONFIG" ]; then
        SSH_PORT=$(grep -oP '^Port\s+\K\d+' "$SSH_CONFIG" 2>/dev/null)
        if [ -z "$SSH_PORT" ]; then
            echo "No SSH port found; defaulting to 22."
            SSH_PORT=22
        else
            echo "SSH port detected: $SSH_PORT"
        fi
    else
        echo "SSH configuration file not found; defaulting to 22."
        SSH_PORT=22
    fi
}

# Function to create the nftables configuration file using a heredoc
create_nftables_config() {
    cat << EOF | sudo tee "$CONFIG_FILE" > /dev/null
#!/usr/sbin/nft -f
flush ruleset
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        ct state established,related accept
        tcp dport $SSH_PORT accept
        tcp dport 80 accept
        tcp dport 443 accept
        udp dport 443 accept
        tcp dport 2053 accept
        udp dport 2053 accept
        tcp dport 8443 accept
        udp dport 8443 accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
}

# Function to secure the config file
secure_config_file() {
    sudo chown root:root "$CONFIG_FILE"
    sudo chmod 600 "$CONFIG_FILE"
}

# Function to apply the nftables rules from the config file with error checking
apply_nftables_rules() {
    sudo nft -f "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo "Failed to load firewall rules from $CONFIG_FILE. Check syntax."
        exit 1
    fi
    echo "Firewall rules applied successfully from $CONFIG_FILE."
}

# Main execution flow
main() {
    remove_firewalld
    sleep 0.5
    find_ssh_port
    sleep 0.5
    create_nftables_config
    sleep 0.5
    secure_config_file
    sleep 0.5
    apply_nftables_rules
    sleep 0.5
}

main

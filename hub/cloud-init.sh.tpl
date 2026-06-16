#!/bin/bash
set -euo pipefail

apt-get update
apt-get install -y wireguard

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-wireguard.conf
sysctl --system

install -m 600 /dev/null /etc/wireguard/wg0.conf
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = ${server_private_key}
Address = ${server_address}
ListenPort = 51820

[Peer]
PublicKey = ${client_public_key}
AllowedIPs = ${client_tunnel_ip}
EOF

systemctl enable --now wg-quick@wg0

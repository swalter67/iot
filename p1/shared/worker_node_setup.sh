#!/bin/bash
# Usage: install_k3s_agent.sh <TOKEN>

MASTER_IP="192.168.42.110"
TOKEN="$1"

# Installer K3s comme agent
curl -sfL https://get.k3s.io | K3S_URL="https://$MASTER_IP:6443" K3S_TOKEN="$TOKEN" sh -

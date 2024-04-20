#!/bin/bash

# Installer K3s
curl -sfL https://get.k3s.io | sh -

# Attendre que K3s soit prêt
while ! kubectl get nodes &> /dev/null; do
    echo "Waiting for K3s to be ready..."
    sleep 5
done

# Sauvegarder le token dans un fichier partagé
sudo cat /var/lib/rancher/k3s/server/node-token > /home/vagrant/shared/token

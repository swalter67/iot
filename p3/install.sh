#!/bin/bash

# Chemin du répertoire de configuration
CONFIG_DIR="/vagrant/confs"

# Color
YELLOW='\033[0;33m'
NC='\033[0m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'

#Vérification des privilèges root
#if [ "$(id -u)" != "0" ]; then
#    echo "Ce script doit être exécuté avec les droits superutilisateur."
#    exit 1
#fi

echo "Démmarage de l'installation..."

echo -e $YELLOW"Mise à jour du système..." $NC
sudo apt-get update  > /dev/null && sudo apt-get upgrade -y  > /dev/null
echo -e $YELLOW"Installation des dépendances..." $NC
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common uidmap ca-certificates curl  > /dev/null 2>&1 

# Installation de Docker
if ! command -v docker &> /dev/null; then
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
			chmod a+r /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update
	apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	groupadd docker
	usermod -aG docker $USER
	#newgrp docker
#	chown "$USER":"$USER" /home/"$USER"/.docker -R
#	chmod g+rwx "$HOME/.docker" -R
	systemctl enable docker.service
	systemctl enable containerd.service
	echo -e $GREEN"Docker installé avec succès.\033[0m" $NC
else
	echo -e $GREEN"Docker est déjà installé.\033[0m" $NC
fi

# Installation de kubectl & Traefik
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

curl https://baltocdn.com/helm/signing.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo apt-get update  > /dev/null && sudo apt-get install -y kubectl helm  > /dev/null
echo "source <(kubectl completion bash)" >> ~/.bashrc

#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#chmod +x kubectl
#mv kubectl /usr/local/bin/.

#helm repo add traefik https://helm.traefik.io/traefik
#helm repo update


# Installation de k3d
echo -e $YELLOW"Installation de k3d..." $NC
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | sudo bash
echo "source <(k3d completion bash)" >> ~/.bashrc

# Vérification que kubectl et k3d sont installés
command -v kubectl >/dev/null 2>&1 || { echo -e $RED"kubectl n'a pas été installé correctement.\033[0m" $NC ; exit 1; }
command -v k3d >/dev/null 2>&1 || { echo -e $RED"k3d n'a pas été installé correctement.\033[0m" $NC ; exit 1; }

# Création d'un cluster k3d
echo -e $YELLOW"Création d'un cluster k3d." $NC
k3d cluster create mycluster --port 8080:80@loadbalancer --port 8443:443@loadbalancer --k3s-arg "--disable=traefik@server:0" --verbose
#k3d cluster create mycluster --port 8080:80@loadbalancer --port 8443:443@loadbalancer --port 8888:8888@loadbalancer --k3s-arg "--disable=traefik@server:0" --verbose

# Configuration du contexte kubectl
echo -e $YELLOW"Configuration du contexte kubectl." $NC
mkdir -p $HOME/.kube
k3d kubeconfig get mycluster > $HOME/.kube/config
kubectl config use-context k3d-mycluster || { echo -e $RED "Le contexte k3d-mycluster n'a pas été trouvé.\033[0m" $NC; exit 1; }

# Installation de ArgoCD
#helm install traefik traefik/traefik --namespace kube-system
echo -e $YELLOW"Installation de ArgoCD..." $NC
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl config set-context --current --namespace=argocd

# Déploiement de l'application dans le namespace 'dev'
#kubectl create namespace dev
#kubectl apply -f $CONFIG_DIR/will_app.yaml
kubectl apply -f $CONFIG_DIR/playground.yaml

check_secret_exists() {
  kubectl -n argocd get secret argocd-initial-admin-secret > /dev/null 2>&1
}

spin='-\|/'
i=0
while ! check_secret_exists; do
  i=$(( (i+1) %4 ))
  printf "\rAttente du démarrage de ArgoCD. ${spin:$i:1}"
  sleep 1
done

PASSWORD_ARGO=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "\nLe mot de passe par défaut pour l'interface web d'ArgoCD est :"$PURPLE $PASSWORD_ARGO $NC
echo -e "Utilisez la commande suivante pour accéder à l'interface web d'ArgoCD :" $PURPLE
echo -e "kubectl port-forward svc/argocd-server -n argocd 8081:443" $NC
echo "Installation terminée. ArgoCD et k3d sont prêts à l'emploi."
echo $PASSWORD_ARGO >> argopassword.txt

k3s est une distribution Kubernetes allégée pour une utilisation en production ou dans des environnements avec ressources limitées, tandis que k3d est un outil pour simuler des clusters k3s dans des conteneurs Docker, destiné aux phases de développement et de test.

tout se fait donc en local, je vais tester tout cela dans ma vm

je fais la premiere partie du sujet avec l image will 
https://hub.docker.com/r/wil42/playground


commandes k3d cluster list ; liste des klusters
kubectl get pods -n argocd


sudo snap install kubectl --classic


PROBLEMES :

kubectl config get-contexts rien ne s affiche

 L'erreur que vous rencontrez indique que le dossier `.kube` n'existe pas dans votre répertoire personnel, ou qu'il n'y a pas de fichier `config` dans ce dossier. Pour résoudre ce problème, vous devez créer le dossier `.kube` et le fichier `config` nécessaire pour stocker la configuration de `kubectl`. Voici comment vous pouvez faire cela :

### Étape 1: Créer le Dossier .kube

Avant de rediriger le kubeconfig vers le fichier `config`, assurez-vous que le dossier `.kube` existe dans votre répertoire personnel. Exécutez cette commande pour le créer :

```bash
mkdir -p /home/walter/.kube
```

### Étape 2: Obtenir le Kubeconfig et le Rediriger

Après avoir créé le dossier, réessayez de récupérer et de stocker votre kubeconfig :

```bash
k3d kubeconfig get mycluster > /home/walter/.kube/config
```

Cette commande va extraire le kubeconfig de votre cluster k3d et le sauvegarder dans le fichier de configuration par défaut de `kubectl`.

### Étape 3: Vérifier le Fichier Kubeconfig

Après avoir sauvegardé le kubeconfig, vous pouvez vérifier que le fichier a été correctement créé et contient les informations attendues :

```bash
cat /home/walter/.kube/config
```

### Étape 4: Utiliser le Contexte Kubectl

Maintenant que vous avez le fichier kubeconfig configuré, vous pouvez définir le contexte par défaut pour `kubectl` pour qu'il utilise le contexte de votre cluster k3d :

```bash
kubectl config use-context k3d-mycluster
```

Remplacez `mycluster` par le nom exact de votre cluster si différent.

### Étape 5: Tester la Connexion

Pour confirmer que tout fonctionne correctement, testez la connexion à votre cluster Kubernetes :

```bash
kubectl cluster-info
```

Si tout est configuré correctement, cette commande devrait afficher les informations de votre cluster Kubernetes géré par k3d.

En suivant ces étapes, vous devriez résoudre le problème du fichier kubeconfig manquant et vous assurer que `kubectl` peut se connecter et interagir avec votre cluster k3d.



COMMANDES : 

 k3d cluster list


kubectl cluster-info

 

kubectl get ns 

NAME              STATUS   AGE
kube-system       Active   10m
kube-public       Active   10m
kube-node-lease   Active   10m
default           Active   10m
argocd            Active   10m
dev               Active   


PROBLEME le port 8888 deja pris donc kubectl port-forward svc/wiilapp 10232:8888 -n dev c est un peu null

curl http://localhost:10232
{"status":"ok", "message": "v1"}(base)   enfin ca marche mais j ai du refaire la manip .kube



pour argocd idem kubectl port-forward svc/argocd-server -n argocd 8081:443


k3d cluster delete mycluster


argocd web interface : 

kubectl port-forward svc/argocd-server -n argocd 8081:443
localhost:8081

user : admin
mnot de passe :
    argocd admin initial-password -n argocd

ATTENTION le repo doit etre en public, sinon gerer les cle pour argocd !!!!! ca fait deux jours de galere pour se connecter a argocd et le faire fonctionner 

changement de version dasn wiil_app.yaml puis git add, commit, push -> dans l appli web argocd refresh -> creation d un nouveau pod qui remplce l ancien verif avec kubectl get pods -n dev


Reste a faire : je vais modifier le repo, le passer en priver et gerer la connection en parametrant argocd
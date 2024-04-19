prerequis : 
    1- virtualbox
    2- vagant : 
        creation de vm a la volee, on va installer k3s dans des machines virtuelles. le master dsans une (cl dans k8s) et dans un node les differents pods necessaires. On pourrais mettre aussi un oui plusieurs pods dans plusieres vm. Dans un pods on peut y mettre plusisurs contenair selon les besoins et la pertinence.

        https://developer.hashicorp.com/vagrant/install

        vagant init 

    3 - k3s different de k8s :
        Kubernetes, souvent abrégé en K8s, est une plateforme open-source très populaire pour l'orchestration de conteneurs, permettant de gérer des applications conteneurisées à grande échelle. K3s est une version allégée de Kubernetes, développée par Rancher Labs, conçue pour être plus rapide à installer, moins gourmande en ressources et plus facile à utiliser dans des environnements avec des ressources limitées ou des exigences simplifiées.

Voici les principales différences entre K8s et K3s :

    Taille et Complexité:
        K8s : Kubernetes est connu pour sa robustesse et ses nombreuses fonctionnalités, ce qui le rend adapté pour les grandes entreprises et les applications complexes. Cependant, cette complexité peut rendre Kubernetes difficile à installer et à maintenir.
        K3s : K3s supprime certaines fonctionnalités non essentielles par défaut (comme le stockage de données de cluster et certains pilotes de réseau) pour simplifier le déploiement et réduire l'empreinte mémoire. K3s est souvent utilisé pour les IoT, les environnements edge, ou les petites infrastructures cloud.

    Installation et Configuration:
        K8s : L'installation de Kubernetes peut être complexe et nécessite généralement une configuration manuelle étendue ou l'utilisation d'outils supplémentaires.
        K3s : K3s est conçu pour être installé rapidement et avec une seule commande, ce qui le rend idéal pour les développement rapides et les tests.

    Dépendances et Composants Externes:
        K8s : Kubernetes a des dépendances avec divers composants externes, comme etcd pour la base de données de cluster.
        K3s : K3s utilise une base de données SQLite intégrée comme option par défaut pour stocker les données du cluster, ce qui réduit la complexité et les dépendances externes.

    Utilisation des Ressources:
        K8s : Plus gourmand en ressources système, Kubernetes nécessite généralement une infrastructure plus robuste.
        K3s : Avec une empreinte réduite, K3s peut fonctionner efficacement sur du matériel moins puissant et avec moins de ressources, ce qui est avantageux pour les environnements à ressources limitées.

    Communauté et Écosystème:
        K8s : Ayant une large adoption et une vaste communauté, Kubernetes bénéficie d'un écosystème riche en outils, en supports et en documentation.
        K3s : Bien que plus jeune et avec une communauté plus petite que Kubernetes, K3s gagne rapidement en popularité, surtout dans les secteurs nécessitant des solutions légères.

En résumé, K3s est souvent préféré pour des déploiements rapides, des environnements de test, ou des scénarios où les ressources hardware sont un facteur limitant. Kubernetes, en revanche, reste la solution de choix pour les entreprises nécessitant une solution d'orchestration de conteneurs robuste et évolutive.

Part 1 :

juste un vagrantfile pour deployer deux machines virtuelles : 
    la premierer server et une serverworker. avec k3s on pourrais faire tourner master et agent dans le meme noeud : mais bof


deux nodes : 
 dans le premiere k3s em mode master ou controler  version allegee des des composant de kubernetes
 dans le deuxieme k3s en mode agent

 le controleur va orchestrer les differents agents    

pour installer k3s en passe soir directementy inline script : config.vm.provision "shell", inline : echo toto ... y a aussi des option pour le sudo possible  (privileged(true)) https://developer.hashicorp.com/vagrant/docs/provisioning/shell#options

ou external script (dans un fichier .sh) config.vm.provision "shell", path: "script.sh" -> tu va preferer le script je pense 


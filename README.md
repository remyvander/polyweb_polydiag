## 3 Polyweb

### 3.1 Création from scratch de PolyWeb

#### 3.1.1 Prérequis

Pour la création de l’image de `polyweb/core`, nous avons 2 solutions : soit une compilation du Dockerfile, soit une pull d’une image depuis le DockerHub.

1. **Compilation du Dockerfile** :
    - Téléchargez l’archive contenant les softs et la liste des librairies nécessaires à la compilation.
    - Lancez la commande :
      ```sh
      docker build -t nom_image\:TAG .
      ```

2. **Pull depuis DockerHub** :
    - Téléchargez l’image via la commande :
      ```sh
      docker pull imaginebioinfo/polyweb\:tagname
      ```

Avant de continuer, créez un groupe Docker, `polyweb` et `mysql`, ainsi que deux utilisateurs `polyweb` et `mysql` :
```sh
sudo groupadd docker
sudo groupadd polyweb -g 9999
sudo useradd polyweb -u 9999 -g polyweb -G docker -m -p "bIKsB9yKk9gvs" -s "/bin/bash"
sudo groupadd mysql -g 27
sudo useradd mysql -u 27 -g mysql -M
Créez maintenant le répertoire source pour polyweb, qui sera la source de toute l’installation :

Copier
sudo mkdir /poly-disk
sudo chown polyweb\:polyweb /poly-disk
3.1.2 Configuration de polyweb-core.cfg

Le fichier de configuration polyweb-core.cfg se trouve dans polyweb-install/conf/polyweb-core.cfg.

Modifiez le paramètre SOURCE pour qu'il pointe vers le chemin de base de poly-disk : SOURCE/poly-disk.

Une fois cette configuration faite, lancez le script d’installation :

Copier
/polyweb-install/install/install-polyweb.sh
Ce script se chargera de créer l’arborescence et de créer des liens symboliques.

3.1.3 Configuration de la base de données

3.1.3.1 Installation de MariaDB

Installez MariaDB sur votre système. Sur un système basé sur Debian ou Ubuntu, utilisez les commandes suivantes :

Copier
sudo apt-get update
sudo apt-get install mariadb-server
Assurez-vous que le service MariaDB est bien démarré :

Copier
sudo systemctl start mariadb
sudo systemctl enable mariadb
3.1.3.2 Création de l’utilisateur

Connectez-vous à MariaDB :

Copier
sudo mariadb
Exécutez les commandes suivantes dans le shell MariaDB :

Copier
CREATE USER 'polyweb'@'localhost' IDENTIFIED BY 'mot_de_passe';
GRANT ALL PRIVILEGES ON *.* TO 'polyweb'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
3.1.3.3 Chargement des schémas de base de données

Téléchargez ou placez l’archive sql-dumps.tar sur votre système, puis extrayez le contenu :

Copier
tar -xvf sql-dumps.tar
Pour charger chaque dump dans MariaDB, utilisez la commande suivante (à adapter selon le nom de vos fichiers SQL) :

Copier
mysql -u polyweb -p < nom_du_fichier.sql
Par exemple :

Copier
mysql -u polyweb -p < PolyprojectNGS_schema.sql
Répétez cette opération pour chaque fichier présent dans l’archive afin de charger tous les schémas nécessaires.

3.1.4 Lancement du serveur Polyweb

Pour lancer le serveur Polyweb, suivez les étapes ci-dessous :

Exécutez le script start_services.sh :

Copier
./start_services.sh
Accédez au conteneur :

Copier
docker exec -it <container_name> /bin/bash
Supprimez le fichier http.pid s’il existe :

Copier
rm -f /var/run/http.pid
Redémarrez le serveur HTTP en mode premier plan :

Copier
/usr/bin/httpd -DFOREGROUND

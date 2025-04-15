## 3 Polyweb

### 3.1 Création from scratch de PolyWeb

#### 3.1.1 Prérequis

Pour la création de l’image de `polyweb/core`, nous avons 2 solutions : soit une compilation du Dockerfile, soit une pull d’une image depuis le DockerHub.

1. **Compilation du Dockerfile** :
    - Téléchargez l’archive contenant les softs et la liste des librairies nécessaires à la compilation.
    - Lancez la commande :
      ```sh
      docker build -t nom_image:TAG .
      ```

2. **Pull depuis DockerHub** :
    - Téléchargez l’image via la commande :
      ```sh
      docker pull imaginebioinfo/polyweb:tagname
      ```

Avant de continuer, créez un groupe Docker, `polyweb` et `mysql`, ainsi que deux utilisateurs `polyweb` et `mysql` :
```sh
sudo groupadd docker
sudo groupadd polyweb -g 9999
sudo useradd polyweb -u 9999 -g polyweb -G docker -m -p "mon mot depasse" -s "/bin/bash"
sudo groupadd mysql -g 27
sudo useradd mysql -u 27 -g mysql -M
```

Créez maintenant le répertoire source pour polyweb, qui sera la source de toute l’installation :
```sh
sudo mkdir /poly-disk
sudo chown polyweb:polyweb /poly-disk
```

### 3.1.2 Configuration de polyweb-core.cfg

Le fichier de configuration `polyweb-core.cfg` se trouve dans `polyweb-install/conf/polyweb-core.cfg`.

Modifiez le paramètre `SOURCE` pour qu'il pointe vers le chemin de base de `poly-disk` : `SOURCE/poly-disk`.

Une fois cette configuration faite, lancez le script d’installation :
```sh
/polyweb-install/install/install-polyweb.sh
```

Ce script se chargera de créer l’arborescence et de créer des liens symboliques.

### 3.1.3 Configuration de la base de données

#### 3.1.3.1 Installation de MariaDB

Installez MariaDB sur votre système. Sur un système basé sur Debian ou Ubuntu, utilisez les commandes suivantes :
```sh
sudo apt-get update
sudo apt-get install mariadb-server
```

Assurez-vous que le service MariaDB est bien démarré :
```sh
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

#### 3.1.3.2 Création de l’utilisateur

Connectez-vous à MariaDB :
```sh
sudo mysql -u root
```

Exécutez les commandes suivantes dans le shell MariaDB :
```sql
CREATE USER 'polyweb'@'localhost' IDENTIFIED BY 'mot_de_passe';
GRANT ALL PRIVILEGES ON *.* TO 'polyweb'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

#### 3.1.3.3 Chargement des schémas de base de données

Téléchargez ou placez l’archive `sql-dumps.tar` sur votre système, puis extrayez le contenu :
```sh
tar -xvf sql-dumps.tar
```

Pour charger chaque dump dans MariaDB, utilisez la commande suivante (à adapter selon le nom de vos fichiers SQL) :
```sh
mysql -u polyweb -p < nom_du_fichier.sql
```

Par exemple :
```sh
mysql -u polyweb -p < PolyprojectNGS_schema.sql
```

Répétez cette opération pour chaque fichier présent dans l’archive afin de charger tous les schémas nécessaires.

### 3.1.3.4 Chargement d'une procédure SQL pour la table `polyprojectNGS`

Chargez la procédure dans MariaDB avec la commande suivante :
```sh
mysql -u polyweb -p < new_project.sql
```

Vous pouvez également vérifier que la procédure a bien été créée en vous connectant à MariaDB :
```sh
sudo mysql -u polyweb -p
```

Et en listant les procédures disponibles :
```sql
SHOW PROCEDURE STATUS WHERE Db = 'polyprojectNGS';
```

### 3.1.4 Lancement du serveur Polyweb

Pour lancer le serveur Polyweb, suivez les étapes ci-dessous :

Exécutez le script `start_services.sh` :
```sh
./start_services.sh
```

Si le conteneur tombe en erreur, alors il faut accéder au conteneur :

Accédez au conteneur :
```sh
docker exec -it <container_name> /bin/bash
```

Supprimez le fichier `http.pid` s’il existe :
```sh
rm -f /var/run/http.pid
```

Redémarrez le serveur HTTP en mode premier plan :
```sh
/usr/bin/httpd -DFOREGROUND
```

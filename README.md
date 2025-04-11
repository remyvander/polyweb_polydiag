# polyweb_polydiag

3 Polyweb
3.1 Création from scratch de PolyWeb
3.1.1 Prérequis
Pour la création de l’image de polyweb/core, nous avons 2 solutions : soit une
compilation du Dockerfile(1), soit une pull d’une image depuis le DockerHub(2).
1. Pour une compialtion du Dockerfile, il vous faudra telecharger l’archive
contenant les softs, la liste des librairies nécessaire à la compilation. Vous
pourrez ensuite lancer la commande :
docker build -t nom_image:TAG .
2. Si vous préférez la solution depuis le DockerHub, il vous suffira de télé-
charger l’image via la commande :
docker push imaginebioinfo/polyweb:tagname
Il vous faudra aussi au préalable créer un groupe docker, polyweb et mysql
ainsi que deux utilisateurs polyweb et mysql :
sudo groupadd docker
sudo groupadd polyweb -g 9999
sudo useradd polyweb -u 9999 -g polyweb -G docker -m -p "bIKsB9yKk9gvs" -s "/bin/bash"
sudo groupadd mysql -g 27
sudo useradd mysql -u 27 -g mysql -M
Il faut maintenant le répertoire source pour polyweb, qui sera la source de
toute l’installation.
sudo mkdir /poly-disk
sudo chown polyweb:polyweb /poly-disk
3.1.2 Configuration de polyweb-core.cfg
Vous trouverez le fichier de configuration polyweb-core.cfg dans polyweb-
install/conf/polyweb-core.cfg.
Il faut modifier le paramètre SOURCE, étant le chemin à la base de poly-
disk : SOURCE/poly-disk.
Une fois cette configuration faites, il suffit de lancer le script d’installation
/polyweb-install/install/install-polyweb.sh, qui se chargera de créer l’ar-
borescence et de créer des liens symboliques.
3
3.1.3 Configuration de la base de donnée
3.1.3.1 Installation de MariaDB
Tout d’abord, il est nécessaire d’installer MariaDB sur votre système. Sur
un système basé sur Debian ou Ubuntu, vous pouvez utiliser la commande sui-
vante :
sudo apt-get update
sudo apt-get install mariadb-server
Assurez-vous que le service MariaDB est bien démarré :
sudo systemctl start mariadb
sudo systemctl enable mariadb
3.1.3.2 Création de l’utilisateur
Une fois MariaDB installé et fonctionnel, il faut créer un utilisateur polyweb
et lui accorder tous les privilèges sur toutes les bases de données. Connectez-vous
à MariaDB :
sudo mariadb
Puis exécutez les commandes suivantes dans le shell MariaDB :
CREATE USER ’polyweb’@’localhost’ IDENTIFIED BY ’mot_de_passe’;
GRANT ALL PRIVILEGES ON *.* TO ’polyweb’@’localhost’ WITH GRANT OPTION;
FLUSH PRIVILEGES;
3.1.3.3 Chargement des schémas de base de données
Téléchargez ou placez l’archive sql-dumps.tar sur votre système. Ensuite,
extrayez le contenu :
tar -xvf sql-dumps.tar
Cela devrait créer un dossier contenant plusieurs fichiers .sql. Pour charger
chaque dump dans MariaDB, utilisez la commande suivante (à adapter selon le
nom de vos fichiers SQL) :
mysql -u polyweb -p < nom_du_fichier.sql
Par exemple :
mysql -u polyweb -p < PolyprojectNGS_schema.sql
Répétez cette opération pour chaque fichier présent dans l’archive afin de
charger tous les schémas nécessaires.
4
3.1.4 Lancement du serveur polyweb
Pour lancer le serveur polyweb, suivez les étapes ci-dessous :
1. Exécutez le script start_services.sh, qui se charge de lancer le conte-
neur Docker et de monter correctement les volumes nécessaires :
./start_services.sh
2. Une fois le conteneur lancé, accédez à celui-ci à l’aide de la commande
suivante (en remplaçant <container_name> par le nom réel du conte-
neur) :
docker exec -it <container_name> /bin/bash
3. Supprimez le fichier http.pid s’il existe, afin d’éviter les conflits lors du
redémarrage du serveur HTTP :
rm -f /var/run/http.pid
4. Redémarrez ensuite le serveur HTTP en mode premier plan :
/usr/bin/httpd -DFOREGROUND
Vous pouvez maintenant accéder à l’interface polyweb via votre navigateur à
l’adresse habituelle !

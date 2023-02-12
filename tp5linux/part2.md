Partie 2 : Mise en place et maîtrise du serveur de base de données
Petite section de mise en place du serveur de base de données sur db.tp5.linux. On ira pas aussi loin qu'Apache pour lui, simplement l'installer, faire une configuration élémentaire avec une commande guidée (mysql_secure_installation), et l'analyser un peu.
🖥️ VM db.tp5.linux
N'oubliez pas de dérouler la 📝checklist📝.



Machines
IP
Service




web.tp5.linux
10.105.1.11
Serveur Web


db.tp5.linux
10.105.1.12
Serveur Base de Données



🌞 Install de MariaDB sur db.tp5.linux

déroulez la doc d'install de Rocky

je veux dans le rendu toutes les commandes réalisées
faites en sorte que le service de base de données démarre quand la machine s'allume

pareil que pour le serveur web, c'est une commande systemctl fiez-vous au mémo

```
[ranvin@router ~]$ sudo !!
sudo dnf install mariadb-server


[ranvin@router ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.


[ranvin@router ~]$ sudo systemctl start mariadb

```
[ranvin@router ~]$ sudo mysql_secure_installation
```



🌞 Port utilisé par MariaDB

vous repérerez le port utilisé par MariaDB avec une commande ss exécutée sur db.tp5.linux

filtrez les infos importantes avec un | grep

```
[ranvin@router /]$ sudo ss -alnp | grep mysql
u_str LISTEN 0      80                      /var/lib/mysql/mysql.sock 36585                  * 0     users:(("mariadbd",pid=13316,fd=18))

[ranvin@router /]$ sudo firewall-cmd --add-port=36585/tcp --permanent
success

[ranvin@router /]$ sudo firewall-cmd --reload
success

```

il sera nécessaire de l'ouvrir dans le firewall


La doc vous fait exécuter la commande mysql_secure_installation c'est un bon réflexe pour renforcer la base qui a une configuration un peu chillax à l'install.

🌞 Processus liés à MariaDB

repérez les processus lancés lorsque vous lancez le service MariaDB
utilisz une commande ps

filtrez les infos importantes avec un | grep

```
[ranvin@router ~]$ ps -ef | grep mysql
mysql        782       1  0 12:30 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
ranvin      1006     979  0 12:33 pts/0    00:00:00 grep --color=auto mysql
```



➜ Une fois la db en place, go sur la partie 3.
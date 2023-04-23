Module 2 : Sauvegarde du système de fichiers
Dans cette partie, on va monter un serveur de sauvegarde qui sera chargé d'accueillir les sauvegardes des autres machines, en particulier du serveur Web qui porte NextCloud.
Le serveur de sauvegarde sera un serveur NFS. NFS est un protocole qui permet de partager un dossier à travers le réseau.
Ainsi, notre serveur de sauvegarde pourra partager un dossier différent à chaque machine qui a besoin de stocker des données sur le long terme.
Dans le cadre du TP, le serveur partagera un dossier à la machine web.tp6.linux.
Sur la machine web.tp6.linux s'exécutera à un intervalles réguliers un script qui effectue une sauvegarde des données importantes de NextCloud et les place dans le dossier partagé.
Ainsi, ces données seront archivées sur le serveur de sauvegarde.


Sommaire


Module 2 : Sauvegarde du système de fichiers

Sommaire

I. Script de backup

1. Ecriture du script
2. Clean it
3. Service et timer



II. NFS

1. Serveur NFS
2. Client NFS






I. Script de backup
Partie à réaliser sur web.tp6.linux.

1. Ecriture du script
🌞 Ecrire le script bash

il s'appellera tp6_backup.sh

il devra être stocké dans le dossier /srv sur la machine web.tp6.linux

le script doit commencer par un shebang qui indique le chemin du programme qui exécutera le contenu du script

ça ressemble à ça si on veut utiliser /bin/bash pour exécuter le contenu de notre script :




#!/bin/bash



pour apprendre quels dossiers il faut sauvegarder dans tout le bordel de NextCloud, il existe une page de la doc officielle qui vous informera

vous devez compresser les dossiers importants

au format .zip ou .tar.gz

le fichier produit sera stocké dans le dossier /srv/backup/

il doit comporter la date, l'heure la minute et la seconde où a été effectué la sauvegarde

par exemple : nextcloud_2211162108.tar.gz







On utilise la notation américaine de la date yymmdd avec l'année puis le mois puis le jour, comme ça, un tri alphabétique des fichiers correspond à un tri dans l'ordre temporel :)


2. Clean it
On va rendre le script un peu plus propre vous voulez bien ?
➜ Utiliser des variables déclarées en début de script pour stocker les valeurs suivantes :

le nom du fichier .tar.gz ou zip produit par le script


# Déclaration d'une variable toto qui contient la string "tata"
toto="tata"

# Appel de la variable toto
# Notez l'utilisation du dollar et des double quotes
echo "$toto"



➜ Commentez le script

au minimum un en-tête sous le shebang

date d'écriture du script
nom/pseudo de celui qui l'a écrit
un résumé TRES BREF de ce que fait le script




➜ Environnement d'exécution du script

créez un utilisateur sur la machine web.tp6.linux

il s'appellera backup

son homedir sera /srv/backup/

son shell sera /usr/bin/nologin



cet utilisateur sera celui qui lancera le script
le dossier /srv/backup/ doit appartenir au user backup

pour tester l'exécution du script en tant que l'utilisateur backup, utilisez la commande suivante :


$ sudo -u backup /srv/tp6_backup.sh



3. Service et timer
🌞 Créez un service système qui lance le script

inspirez-vous des services qu'on a créés et/ou manipulés jusqu'à maintenant
la seule différence est que vous devez rajouter Type=oneshot dans la section [Service] pour indiquer au système que ce service ne tournera pas à l'infini (comme le fait un serveur web par exemple) mais se terminera au bout d'un moment
vous appelerez le service backup.service

assurez-vous qu'il fonctionne en utilisant des commandes systemctl



$ sudo systemctl status backup
$ sudo systemctl start backup


🌞 Créez un timer système qui lance le service à intervalles réguliers

le fichier doit être créé dans le même dossier
le fichier doit porter le même nom
l'extension doit être .timer au lieu de .service

ainsi votre fichier s'appellera backup.timer

la syntaxe est la suivante :


[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target



La doc Arch est cool à ce sujet.

🌞 Activez l'utilisation du timer

vous vous servirez des commandes suivantes :


# demander au système de lire le contenu des dossiers de config
# il découvrira notre nouveau timer
$ sudo systemctl daemon-reload

# on peut désormais interagir avec le timer
$ sudo systemctl start backup.timer
$ sudo systemctl enable backup.timer
$ sudo systemctl status backup.timer

# il apparaîtra quand on demande au système de lister tous les timers
$ sudo systemctl list-timers



II. NFS

1. Serveur NFS

On a déjà fait ça au TP4 ensemble :)

🖥️ VM storage.tp6.linux
N'oubliez pas de dérouler la 📝checklist📝.
🌞 Préparer un dossier à partager sur le réseau (sur la machine storage.tp6.linux)

créer un dossier /srv/nfs_shares

créer un sous-dossier /srv/nfs_shares/web.tp6.linux/



Et ouais pour pas que ce soit le bordel, on va appeler le dossier comme la machine qui l'utilisera :)

🌞 Installer le serveur NFS (sur la machine storage.tp6.linux)

installer le paquet nfs-utils

créer le fichier /etc/exports

remplissez avec un contenu adapté
j'vous laisse faire les recherches adaptées pour ce faire


ouvrir les ports firewall nécessaires
démarrer le service
je vous laisse check l'internet pour trouver ce genre de lien pour + de détails


2. Client NFS
🌞 Installer un client NFS sur web.tp6.linux

il devra monter le dossier /srv/nfs_shares/web.tp6.linux/ qui se trouve sur storage.tp6.linux

le dossier devra être monté sur /srv/backup/

je vous laisse là encore faire vos recherches pour réaliser ça !
faites en sorte que le dossier soit automatiquement monté quand la machine s'allume

🌞 Tester la restauration des données sinon ça sert à rien :)

livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure


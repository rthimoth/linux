Partie 3 : Configuration et mise en place de NextCloud
Enfin, on va setup NextCloud pour avoir un site web qui propose de vraies fonctionnalités et qui a un peu la classe :)


Partie 3 : Configuration et mise en place de NextCloud

1. Base de données
2. Serveur Web et NextCloud
3. Finaliser l'installation de NextCloud




1. Base de données
Dans cette section, on va préparer le service de base de données pour que NextCloud puisse s'y connecter.
Le but :

créer une base de données dans le serveur de base de données
créer une utilisateur dans le serveur de base de données
donner tous les droits à cet utilisateur sur la base de données qu'on a créé


Note : ici on parle d'un utilisateur de la base de données. Il n'a rien à voir avec les utilisateurs du système Linux qu'on manipule habituellement. Il existe donc un système d'utilisateurs au sein d'un serveur de base de données, qui ont des droits définis sur des bases précises.

🌞 Préparation de la base pour NextCloud

une fois en place, il va falloir préparer une base de données pour NextCloud :

connectez-vous à la base de données à l'aide de la commande sudo mysql -u root -p

exécutez les commandes SQL suivantes :




-- Création d'un utilisateur dans la base, avec un mot de passe
-- L'adresse IP correspond à l'adresse IP depuis laquelle viendra les connexions. Cela permet de restreindre les IPs autorisées à se connecter.
-- Dans notre cas, c'est l'IP de web.tp5.linux
-- "pewpewpew" c'est le mot de passe hehe
CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';

-- Création de la base de donnée qui sera utilisée par NextCloud
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- On donne tous les droits à l'utilisateur nextcloud sur toutes les tables de la base qu'on vient de créer
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';

-- Actualisation des privilèges
FLUSH PRIVILEGES;

-- C'est assez générique comme opération, on crée une base, on crée un user, on donne les droits au user sur la base

```
[ranvin@router ~]$ sudo mysql -u root -p
[sudo] password for ranvin:
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.004 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> Ctrl-C -- exit!
Aborted
```



Par défaut, vous avez le droit de vous connecter localement à la base si vous êtes root. C'est pour ça que sudo mysql -u root fonctionne, sans nous demander de mot de passe. Evidemment, n'importe quelles autres conditions ne permettent pas une connexion aussi facile à la base.

🌞 Exploration de la base de données

afin de tester le bon fonctionnement de la base de données, vous allez essayer de vous connecter, comme NextCloud le fera plus tard :

depuis la machine web.tp5.linux vers l'IP de db.tp5.linux

utilisez la commande mysql pour vous connecter à une base de données depuis la ligne de commande

par exemple mysql -u <USER> -h <IP_DATABASE> -p

```
[ranvin@router ~]$ mysql -u nextcloud -h 10.105.1.12 -ppewpewpew
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 10
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.005 sec)

MariaDB [(none)]> USE <DATABASE_NAME>;
ERROR 1044 (42000): Access denied for user 'nextcloud'@'10.105.1.11' to database '<DATABASE_NAME>'
MariaDB [(none)]> USE nextcloud;
Database changed
MariaDB [nextcloud]> SHOW TABLES;
Empty set (0.002 sec)

MariaDB [nextcloud]>

```

si vous ne l'avez pas, installez-là
vous pouvez déterminer dans quel paquet est disponible la commande mysql en saisissant dnf provides mysql





donc vous devez effectuer une commande mysql sur web.tp5.linux
une fois connecté à la base, utilisez les commandes SQL fournies ci-dessous pour explorer la base


SHOW DATABASES;
USE <DATABASE_NAME>;
SHOW TABLES;



Si ça marche cette commande, alors on est assurés que NextCloud pourra s'y connecter aussi. En effet, il utilisera le même user et même password, depuis la même machine.

🌞 Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données

vous ne pourrez pas utiliser l'utilisateur nextcloud de la base pour effectuer cette opération : il n'a pas les droits
il faudra donc vous reconnectez localement à la base en utilisant l'utilisateur root



Comme déjà dit dans une note plus haut, les utilisateurs de la base de données sont différents des utilisateurs du système Rocky Linux qui porte la base. Les utilisateurs de la base définissent des identifiants utilisés pour se connecter à la base afin d'y voir ou d'y modifier des données.

Une fois qu'on s'est assurés qu'on peut se co au service de base de données depuis web.tp5.linux, on peut continuer.

2. Serveur Web et NextCloud
⚠️⚠️⚠️ N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.
🌞 Install de PHP

# On ajoute le dépôt CRB
$ sudo dnf config-manager --set-enabled crb
# On ajoute le dépôt REMI
$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# On liste les versions de PHP dispos, au passage on va pouvoir accepter les clés du dépôt REMI
$ dnf module list php

# On active le dépôt REMI pour récupérer une version spécifique de PHP, celle recommandée par la doc de NextCloud
$ sudo dnf module enable php:remi-8.1 -y

# Eeeet enfin, on installe la bonne version de PHP : 8.1
$ sudo dnf install -y php81-php
```
[ranvin@router conf]$ sudo dnf install -y php81-php
Extra Packages for Enterprise Linux 9 - x86_64  1.7 MB/s |  13 MB     00:07
Remi's Modular repository for Enterprise Linux  2.3 kB/s | 833  B     00:00
Remi's Modular repository for Enterprise Linux  1.7 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Remi's Modular repository for Enterprise Linux  1.2 MB/s | 838 kB     00:00
Safe Remi's RPM repository for Enterprise Linux 2.3 kB/s | 833  B     00:00
Safe Remi's RPM repository for Enterprise Linux 2.4 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Safe Remi's RPM repository for Enterprise Linux 1.3 MB/s | 890 kB     00:00
Last metadata expiration check: 0:00:01 ago on Tue 31 Jan 2023 03:42:44 PM CET.
Dependencies resolved.
================================================================================
 Package                 Arch       Version                 Repository     Size
================================================================================
Installing:
 php81-php               x86_64     8.1.14-1.el9.remi       remi-safe     1.7 M
Installing dependencies:
 environment-modules     x86_64     5.0.1-1.el9             baseos        481 k
 libsodium               x86_64     1.0.18-8.el9            epel          161 k
 libxslt                 x86_64     1.1.34-9.el9            appstream     240 k
 oniguruma5php           x86_64     6.9.8-1.el9.remi        remi-safe     219 k
 php81-php-common        x86_64     8.1.14-1.el9.remi       remi-safe     667 k
 php81-runtime           x86_64     8.1-2.el9.remi          remi-safe     1.1 M
 scl-utils               x86_64     1:2.0.3-2.el9           appstream      37 k
 tcl                     x86_64     1:8.6.10-7.el9          baseos        1.1 M
Installing weak dependencies:
 php81-php-cli           x86_64     8.1.14-1.el9.remi       remi-safe     3.5 M
 php81-php-fpm           x86_64     8.1.14-1.el9.remi       remi-safe     1.8 M
 php81-php-mbstring      x86_64     8.1.14-1.el9.remi       remi-safe     475 k
 php81-php-opcache       x86_64     8.1.14-1.el9.remi       remi-safe     378 k
 php81-php-pdo           x86_64     8.1.14-1.el9.remi       remi-safe      86 k
 php81-php-sodium        x86_64     8.1.14-1.el9.remi       remi-safe      41 k
 php81-php-xml           x86_64     8.1.14-1.el9.remi       remi-safe     141 k

Transaction Summary
================================================================================
Install  16 Packages

Total download size: 12 M
Installed size: 49 M
Downloading Packages:
(1/16): libsodium-1.0.18-8.el9.x86_64.rpm       534 kB/s | 161 kB     00:00
(2/16): oniguruma5php-6.9.8-1.el9.remi.x86_64.r 549 kB/s | 219 kB     00:00
(3/16): php81-php-common-8.1.14-1.el9.remi.x86_ 531 kB/s | 667 kB     00:01
(4/16): php81-php-8.1.14-1.el9.remi.x86_64.rpm  803 kB/s | 1.7 MB     00:02
(5/16): php81-php-mbstring-8.1.14-1.el9.remi.x8 925 kB/s | 475 kB     00:00
(6/16): php81-php-opcache-8.1.14-1.el9.remi.x86 848 kB/s | 378 kB     00:00
(7/16): php81-php-pdo-8.1.14-1.el9.remi.x86_64. 679 kB/s |  86 kB     00:00
(8/16): php81-php-sodium-8.1.14-1.el9.remi.x86_ 620 kB/s |  41 kB     00:00
(9/16): php81-php-xml-8.1.14-1.el9.remi.x86_64. 566 kB/s | 141 kB     00:00
(10/16): php81-php-fpm-8.1.14-1.el9.remi.x86_64 598 kB/s | 1.8 MB     00:03
(11/16): php81-php-cli-8.1.14-1.el9.remi.x86_64 733 kB/s | 3.5 MB     00:04
(12/16): php81-runtime-8.1-2.el9.remi.x86_64.rp 747 kB/s | 1.1 MB     00:01
(13/16): environment-modules-5.0.1-1.el9.x86_64 603 kB/s | 481 kB     00:00
(14/16): scl-utils-2.0.3-2.el9.x86_64.rpm       171 kB/s |  37 kB     00:00
(15/16): libxslt-1.1.34-9.el9.x86_64.rpm        456 kB/s | 240 kB     00:00
(16/16): tcl-8.6.10-7.el9.x86_64.rpm            1.0 MB/s | 1.1 MB     00:01
--------------------------------------------------------------------------------
Total                                           1.5 MB/s |  12 MB     00:08
Extra Packages for Enterprise Linux 9 - x86_64  1.5 MB/s | 1.6 kB     00:00
Importing GPG key 0x3228467C:
 Userid     : "Fedora (epel9) <epel@fedoraproject.org>"
 Fingerprint: FF8A D134 4597 106E CE81 3B91 8A38 72BF 3228 467C
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
Key imported successfully
Safe Remi's RPM repository for Enterprise Linux 3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0x478F8947:
 Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
 Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Installing       : libxslt-1.1.34-9.el9.x86_64                           1/16
  Installing       : tcl-1:8.6.10-7.el9.x86_64                             2/16
  Installing       : environment-modules-5.0.1-1.el9.x86_64                3/16
  Running scriptlet: environment-modules-5.0.1-1.el9.x86_64                3/16
  Installing       : scl-utils-1:2.0.3-2.el9.x86_64                        4/16
  Installing       : php81-runtime-8.1-2.el9.remi.x86_64                   5/16
  Running scriptlet: php81-runtime-8.1-2.el9.remi.x86_64                   5/16
uavc:  op=setenforce lsm=selinux enforcing=0 res=1uavc:  op=load_policy lsm=seli  Installing       : php81-php-common-8.1.14-1.el9.remi.x86_64             6/16
  Installing       : php81-php-cli-8.1.14-1.el9.remi.x86_64                7/16
  Installing       : php81-php-fpm-8.1.14-1.el9.remi.x86_64                8/16
  Running scriptlet: php81-php-fpm-8.1.14-1.el9.remi.x86_64                8/16
  Installing       : php81-php-opcache-8.1.14-1.el9.remi.x86_64            9/16
  Installing       : php81-php-pdo-8.1.14-1.el9.remi.x86_64               10/16
  Installing       : php81-php-xml-8.1.14-1.el9.remi.x86_64               11/16
  Installing       : oniguruma5php-6.9.8-1.el9.remi.x86_64                12/16
  Installing       : php81-php-mbstring-8.1.14-1.el9.remi.x86_64          13/16
  Installing       : libsodium-1.0.18-8.el9.x86_64                        14/16
  Installing       : php81-php-sodium-8.1.14-1.el9.remi.x86_64            15/16
  Installing       : php81-php-8.1.14-1.el9.remi.x86_64                   16/16
  Running scriptlet: php81-php-8.1.14-1.el9.remi.x86_64                   16/16
  Verifying        : libsodium-1.0.18-8.el9.x86_64                         1/16
  Verifying        : oniguruma5php-6.9.8-1.el9.remi.x86_64                 2/16
  Verifying        : php81-php-8.1.14-1.el9.remi.x86_64                    3/16
  Verifying        : php81-php-cli-8.1.14-1.el9.remi.x86_64                4/16
  Verifying        : php81-php-common-8.1.14-1.el9.remi.x86_64             5/16
  Verifying        : php81-php-fpm-8.1.14-1.el9.remi.x86_64                6/16
  Verifying        : php81-php-mbstring-8.1.14-1.el9.remi.x86_64           7/16
  Verifying        : php81-php-opcache-8.1.14-1.el9.remi.x86_64            8/16
  Verifying        : php81-php-pdo-8.1.14-1.el9.remi.x86_64                9/16
  Verifying        : php81-php-sodium-8.1.14-1.el9.remi.x86_64            10/16
  Verifying        : php81-php-xml-8.1.14-1.el9.remi.x86_64               11/16
  Verifying        : php81-runtime-8.1-2.el9.remi.x86_64                  12/16
  Verifying        : environment-modules-5.0.1-1.el9.x86_64               13/16
  Verifying        : tcl-1:8.6.10-7.el9.x86_64                            14/16
  Verifying        : libxslt-1.1.34-9.el9.x86_64                          15/16
  Verifying        : scl-utils-1:2.0.3-2.el9.x86_64                       16/16

Installed:
  environment-modules-5.0.1-1.el9.x86_64
  libsodium-1.0.18-8.el9.x86_64
  libxslt-1.1.34-9.el9.x86_64
  oniguruma5php-6.9.8-1.el9.remi.x86_64
  php81-php-8.1.14-1.el9.remi.x86_64
  php81-php-cli-8.1.14-1.el9.remi.x86_64
  php81-php-common-8.1.14-1.el9.remi.x86_64
  php81-php-fpm-8.1.14-1.el9.remi.x86_64
  php81-php-mbstring-8.1.14-1.el9.remi.x86_64
  php81-php-opcache-8.1.14-1.el9.remi.x86_64
  php81-php-pdo-8.1.14-1.el9.remi.x86_64
  php81-php-sodium-8.1.14-1.el9.remi.x86_64
  php81-php-xml-8.1.14-1.el9.remi.x86_64
  php81-runtime-8.1-2.el9.remi.x86_64
  scl-utils-1:2.0.3-2.el9.x86_64
  tcl-1:8.6.10-7.el9.x86_64

Complete!
```

🌞 Install de tous les modules PHP nécessaires pour NextCloud

# eeeeet euuuh boom. Là non plus j'ai pas pondu ça, c'est la doc :
$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp

```
[ranvin@router conf]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Last metadata expiration check: 0:04:21 ago on Tue 31 Jan 2023 03:42:44 PM CET.
Package libxml2-2.9.13-1.el9_0.1.x86_64 is already installed.
Package openssl-1:3.0.1-41.el9_0.x86_64 is already installed.
Package php81-php-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-mbstring-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-xml-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-common-8.1.14-1.el9.remi.x86_64 is already installed.
Package php81-php-pdo-8.1.14-1.el9.remi.x86_64 is already installed.
Dependencies resolved.

Upgraded:
  libxml2-2.9.13-3.el9_1.x86_64                                     openssl-1:3.0.1-43.el9_0.x86_64                                     openssl-libs-1:3.0.1-43.el9_0.x86_64
Installed:
  fontconfig-2.14.0-2.el9_1.x86_64                     fribidi-1.0.10-6.el9.2.x86_64                       gd3php-2.3.3-9.el9.remi.x86_64                   gdk-pixbuf2-2.42.6-2.el9.x86_64
  highway-1.0.2-1.el9.x86_64                           jbigkit-libs-2.1-23.el9.x86_64                      jxl-pixbuf-loader-0.7.0-1.el9.x86_64             libX11-1.7.0-7.el9.x86_64
  libX11-common-1.7.0-7.el9.noarch                     libXau-1.0.9-8.el9.x86_64                           libXpm-3.5.13-8.el9_1.x86_64                     libaom-3.5.0-2.el9.x86_64
  libavif-0.11.1-4.el9.x86_64                          libdav1d-1.0.0-2.el9.x86_64                         libicu71-71.1-2.el9.remi.x86_64                  libimagequant-2.17.0-1.el9.x86_64
  libjpeg-turbo-2.0.90-5.el9.x86_64                    libjxl-0.7.0-1.el9.x86_64                           libraqm-0.8.0-1.el9.x86_64                       libtiff-4.4.0-5.el9_1.x86_64
  libvmaf-2.3.0-2.el9.x86_64                           libwebp-1.2.0-3.el9.x86_64                          libxcb-1.13.1-9.el9.x86_64                       php81-php-bcmath-8.1.14-1.el9.remi.x86_64
  php81-php-gd-8.1.14-1.el9.remi.x86_64                php81-php-gmp-8.1.14-1.el9.remi.x86_64              php81-php-intl-8.1.14-1.el9.remi.x86_64          php81-php-mysqlnd-8.1.14-1.el9.remi.x86_64
  php81-php-pecl-zip-1.21.1-1.el9.remi.x86_64          php81-php-process-8.1.14-1.el9.remi.x86_64          rav1e-libs-0.5.1-5.el9.x86_64                    remi-libzip-1.9.2-3.el9.remi.x86_64
  shared-mime-info-2.1-4.el9.x86_64                    svt-av1-libs-0.9.0-1.el9.x86_64                     xml-common-0.6.3-58.el9.noarch

Complete!
```

🌞 Récupérer NextCloud

créez le dossier /var/www/tp5_nextcloud/

ce sera notre racine web (ou webroot)
l'endroit où le site est stocké quoi, on y trouvera un index.html et un tas d'autres marde, tout ce qui constitue NextCloud :D


récupérer le fichier suivant avec une commande curl ou wget : https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip

```
[ranvin@router tp5_nextcloud]$ sudo curl -O https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
```

extrayez tout son contenu dans le dossier /var/www/tp5_nextcloud/ en utilisant la commande unzip

```
[ranvin@router tp5_nextcloud]$ sudo dnf install unzip
[sudo] password for ranvin:
Rocky Linux 9 - Extras                          6.7 kB/s | 2.9 kB     00:00
Rocky Linux 9 - Extras                           17 kB/s | 8.5 kB     00:00
Dependencies resolved.
================================================================================
 Package         Architecture     Version                Repository        Size
================================================================================
Installing:
 unzip           x86_64           6.0-56.el9             baseos           180 k

Transaction Summary
```

installez la commande unzip si nécessaire
vous pouvez extraire puis déplacer ensuite, vous prenez pas la tête
contrôlez que le fichier /var/www/tp5_nextcloud/index.html existe pour vérifier que tout est en place

```
[ranvin@router tp5_nextcloud]$ sudo unzip nextcloud-25.0.0rc3.zip
```


assurez-vous que le dossier /var/www/tp5_nextcloud/ et tout son contenu appartient à l'utilisateur qui exécute le service Apache

utilisez une commande chown si nécessaire

```
[ranvin@router www]$ sudo chown -R apache:apache tp
tp2_linux/     tp5_nextcloud/
[ranvin@router www]$ sudo chown -R apache:apache tp5_nextcloud/
[sudo] password for ranvin:
[ranvin@router www]$ ls -al
total 4
drwxr-xr-x.  6 root   root     71 Jan 31 16:27 .
drwxr-xr-x. 20 root   root   4096 Jan  2 20:59 ..
drwxr-xr-x.  2 root   root      6 Nov 16 08:11 cgi-bin
drwxr-xr-x.  2 root   root      6 Nov 16 08:11 html
drwxr-xr-x.  2 root   root     24 Jan  2 21:12 tp2_linux
drwxr-xr-x.  3 apache apache   54 Jan 31 17:12 tp5_nextcloud
```
```
[ranvin@router tp5_nextcloud]$ ls -al
total 172216
drwxr-xr-x.  3 apache apache        54 Jan 31 17:12 .
drwxr-xr-x.  6 root   root          71 Jan 31 16:27 ..
drwxr-xr-x. 14 apache apache      4096 Oct  6 14:47 nextcloud
-rw-r--r--.  1 apache apache 176341139 Jan 31 16:45 nextcloud-25.0.0rc3.zip
```


A chaque fois que vous faites ce genre de trucs, assurez-vous que c'est bien ok. Par exemple, vérifiez avec un ls -al que tout appartient bien à l'utilisateur qui exécute Apache.

🌞 Adapter la configuration d'Apache

regardez la dernière ligne du fichier de conf d'Apache pour constater qu'il existe une ligne qui inclut d'autres fichiers de conf
créez en conséquence un fichier de configuration qui porte un nom clair et qui contient la configuration suivante :


<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>

```
[ranvin@router httpd]$ sudo cat conf/httpd.conf | tail -1
IncludeOptional conf.d/*.conf
[ranvin@router httpd]$
```




🌞 Redémarrer le service Apache pour qu'il prenne en compte le nouveau fichier de conf

```
[ranvin@router conf.d]$ sudo systemctl restart httpd
```

3. Finaliser l'installation de NextCloud
➜ Sur votre PC

modifiez votre fichier hosts (oui, celui de votre PC, de votre hôte)

pour pouvoir joindre l'IP de la VM en utilisant le nom web.tp5.linux



avec un navigateur, visitez NextCloud à l'URL http://web.tp5.linux

c'est possible grâce à la modification de votre fichier hosts



on va vous demander un utilisateur et un mot de passe pour créer un compte admin

ne saisissez rien pour le moment


cliquez sur "Storage & Database" juste en dessous

choisissez "MySQL/MariaDB"
saisissez les informations pour que NextCloud puisse se connecter avec votre base


saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 C'est chez vous ici, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)
🌞 Exploration de la base de données

connectez vous en ligne de commande à la base de données après l'installation terminée
déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation


bonus points si la réponse à cette question est automatiquement donnée par une requête SQL



➜ NextCloud est tout bo, en place, vous pouvez aller sur la partie 4.
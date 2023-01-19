Partie 3 : Serveur web


Partie 3 : Serveur web

1. Intro NGINX
2. Install
3. Analyse
4. Visite du service web
5. Modif de la conf du serveur web
6. Deux sites web sur un seul serveur




1. Intro NGINX

NGINX (prononcé "engine-X") est un serveur web. C'est un outil de référence aujourd'hui, il est réputé pour ses performances et sa robustesse.
Un serveur web, c'est un programme qui écoute sur un port et qui attend des requêtes HTTP. Quand il reçoit une requête de la part d'un client, il renvoie une réponse HTTP qui contient le plus souvent de l'HTML, du CSS et du JS.

Une requête HTTP c'est par exemple GET /index.html qui veut dire "donne moi le fichier index.html qui est stocké sur le serveur". Le serveur renverra alors le contenu de ce fichier index.html.

Ici on va pas DU TOUT s'attarder sur la partie dév web étou, une simple page HTML fera l'affaire.
Une fois le serveur web NGINX installé (grâce à un paquet), sont créés sur la machine :


un service (un fichier .service)

on pourra interagir avec le service à l'aide de systemctl




des fichiers de conf

comme d'hab c'est dans /etc/ la conf
comme d'hab c'est bien rangé, donc la conf de NGINX c'est dans /etc/nginx/

question de simplicité en terme de nommage, le fichier de conf principal c'est /etc/nginx/nginx.conf




une racine web

c'est un dossier dans lequel un site est stocké
c'est à dire là où se trouvent tous les fichiers PHP, HTML, CSS, JS, etc du site
ce dossier et tout son contenu doivent appartenir à l'utilisateur qui lance le service



des logs

tant que le service a pas trop tourné c'est empty
les fichiers de logs sont dans /var/log/

comme d'hab c'est bien rangé donc c'est dans /var/log/nginx/

on peut aussi consulter certains logs avec sudo journalctl -xe -u nginx





Chaque log est à sa place, on ne trouve pas la même chose dans chaque fichier ou la commande journalctl. La commande journalctl vous permettra de repérer les erreurs que vous glisser dans les fichiers de conf et qui empêche le démarrage correct de NGINX.


2. Install
🖥️ VM web.tp4.linux
🌞 Installez NGINX

``` sudo dnf install nginx```

installez juste NGINX (avec un dnf install) et passez à la suite
référez-vous à des docs en ligne si besoin


3. Analyse
Avant de config des truks 2 ouf étou, on va lancer à l'aveugle et inspecter ce qu'il se passe, inspecter avec les outils qu'on connaît ce que fait NGINX à notre OS.
Commencez donc par démarrer le service NGINX :

$ sudo systemctl start nginx
$ sudo systemctl status nginx

```
[ranvin@router ~]$ sudo systemctl start nginx
[ranvin@router ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 17:33:42 CET; 6s ago
    Process: 11493 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 11494 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 11495 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 11496 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 24ms
     CGroup: /system.slice/nginx.service
             ├─11496 "nginx: master process /usr/sbin/nginx"
             └─11497 "nginx: worker process"

Jan 16 17:33:42 client systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 17:33:42 client nginx[11494]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 17:33:42 client nginx[11494]: nginx: configuration file /etc/nginx/nginx.conf test is successf>
Jan 16 17:33:42 client systemd[1]: Started The nginx HTTP and reverse proxy server.
```

🌞 Analysez le service NGINX

avec une commande ps, déterminer sous quel utilisateur tourne le processus du service NGINX

utilisez un | grep pour isoler les lignes intéressantes

```
[ranvin@router ~]$ ps -ef | grep nginx
root       11496       1  0 17:33 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      11497   11496  0 17:33 ?        00:00:00 nginx: worker process
ranvin     11504     885  0 17:35 pts/0    00:00:00 grep --color=auto nginx
```

avec une commande ss, déterminer derrière quel port écoute actuellement le serveur web

utilisez un | grep pour isoler les lignes intéressantes

```
[ranvin@router ~]$ sudo ss -np | grep nginx
u_str ESTAB  0      0                                * 37242             * 37241 users:(("nginx",pid=11497,fd=8),("nginx",pid=11496,fd=8))

u_str ESTAB  0      0                                * 37241             * 37242 users:(("nginx",pid=11496,fd=3))
```


en regardant la conf, déterminer dans quel dossier se trouve la racine web

utilisez un | grep pour isoler les lignes intéressantes

```
[ranvin@router /]$ sudo cat etc/nginx/nginx.conf | grep root | head -1
        root         /usr/share/nginx/html;
```

inspectez les fichiers de la racine web, et vérifier qu'ils sont bien accessibles en lecture par l'utilisateur qui lance le processus

ça va se faire avec un ls et les options appropriées

```
[ranvin@router nginx]$ ls -al | grep html
drwxr-xr-x.  3 root root  143 Jan 16 17:31 html
```


4. Visite du service web
Et ça serait bien d'accéder au service non ? Genre c'est un serveur web. On veut voir un site web !
🌞 Configurez le firewall pour autoriser le trafic vers le service NGINX
```
[ranvin@router nginx]$ sudo firewall-cmd --add-port=8080/tcp --permanent
[sudo] password for ranvin:
success
[ranvin@router nginx]$ sudo firewall-cmd --reload
success
[ranvin@router nginx]$
vous avez reperé avec ss dans la partie d'avant le port à ouvrir
```

🌞 Accéder au site web

avec votre navigateur sur VOTRE PC

ouvrez le navigateur vers l'URL : http://<IP_VM>:<PORT>



vous pouvez aussi effectuer des requêtes HTTP depuis le terminal, plutôt qu'avec un navigateur

ça se fait avec la commande curl

et c'est ça que je veux dans le compte-rendu, pas de screen du navigateur :)




Si le port c'est 80, alors c'est la convention pour HTTP. Ainsi, il est inutile de le préciser dans l'URL, le navigateur le fait de lui-même. On peut juste saisir http://<IP_VM>.

```
[ranvin@client ~]$ sudo curl http://192.168.250.6:8080 | head -10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
100  7620  100  7620    0     0   620k      0 --:--:-- --:--:-- --:--:--  676k
curl: (23) Failed writing body
```

🌞 Vérifier les logs d'accès

trouvez le fichier qui contient les logs d'accès, dans le dossier /var/log

les logs d'accès, c'est votre serveur web qui enregistre chaque requête qu'il a reçu
c'est juste un fichier texte
affichez les 3 dernières lignes des logs d'accès dans le contenu rendu, avec une commande tail

```
���cpts/0192.168.250.2[ranvin@client log]$ sudo cat tallylog
[ranvin@client log]$ sudo cat nginx/access.log | tail -3
192.168.250.2 - - [16/Jan/2023:18:51:24 +0100] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" "-"
192.168.250.6 - - [16/Jan/2023:18:51:29 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
192.168.250.6 - - [16/Jan/2023:18:52:58 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
[ranvin@client log]$
```

5. Modif de la conf du serveur web
🌞 Changer le port d'écoute

une simple ligne à modifier, vous me la montrerez dans le compte rendu

faites écouter NGINX sur le port 8080
```
[ranvin@client /]$ sudo cat /etc/nginx/nginx.conf | grep listen | head -2
        listen       8080;
        listen       [::]:8080;
```
redémarrer le service pour que le changement prenne effet

```
[ranvin@client /]$ sudo systemctl restart nginx
```

sudo systemctl restart nginx
vérifiez qu'il tourne toujours avec un ptit systemctl status nginx
```
[ranvin@client /]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-16 19:14:17 CET; 40s ago
    Process: 1051 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 1052 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1053 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1054 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 14ms
     CGroup: /system.slice/nginx.service
             ├─1054 "nginx: master process /usr/sbin/nginx"
             └─1055 "nginx: worker process"

Jan 16 19:14:17 client systemd[1]: nginx.service: Deactivated successfully.
Jan 16 19:14:17 client systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Jan 16 19:14:17 client systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 19:14:17 client nginx[1052]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 16 19:14:17 client nginx[1052]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 16 19:14:17 client systemd[1]: Started The nginx HTTP and reverse proxy server.
```

prouvez-moi que le changement a pris effet avec une commande ss

utilisez un | grep pour isoler les lignes intéressantes

```
[ranvin@client /]$ sudo ss -np | grep nginx
u_str ESTAB  0      0                                * 23862             * 23861 users:(("nginx",pid=1055,fd=8),("nginx",pid=1054,fd=8))

u_str ESTAB  0      0                                * 23861             * 23862 users:(("nginx",pid=1054,fd=3))

```

n'oubliez pas de fermer l'ancien port dans le firewall, et d'ouvrir le nouveau
prouvez avec une commande curl sur votre machine que vous pouvez désormais visiter le port 8080


Là c'est pas le port par convention, alors obligé de préciser le port quand on fait la requête avec le navigateur ou curl : http://<IP_VM>:8080.

```
[ranvin@client ~]$ sudo curl http://192.168.250.6:8080 | head -10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
100  7620  100  7620    0     0   620k      0 --:--:-- --:--:-- --:--:--  676k
curl: (23) Failed writing body
```

🌞 Changer l'utilisateur qui lance le service

pour ça, vous créerez vous-même un nouvel utilisateur sur le système : web

référez-vous au mémo des commandes pour la création d'utilisateur
l'utilisateur devra avoir un mot de passe, et un homedir défini explicitement à /home/web

modifiez la conf de NGINX pour qu'il soit lancé avec votre nouvel utilisateur

utilisez grep pour me montrer dans le fichier de conf la ligne que vous avez modifié

```
[ranvin@client home]$ getent passwd toto | cut -d: -f6
/home/web
```

```[ranvin@client /]$ sudo cat /etc/nginx/nginx.conf | grep user | head -1
user toto1;
```

n'oubliez pas de redémarrer le service pour que le changement prenne effet
vous prouverez avec une commande ps que le service tourne bien sous ce nouveau utilisateur

```
[ranvin@client /]$ sudo systemctl start nginx
```

utilisez un | grep pour isoler les lignes intéressantes

```
[ranvin@client nginx]$ ps -ef | grep nginx
root         982       1  0 17:41 ?        00:00:00 nginx: master process /usr/sbin/nginx
toto1       1129     982  0 17:49 ?        00:00:00 nginx: worker process
ranvin      1131     939  0 17:49 pts/0    00:00:00 grep --color=auto nginx
```



Il est temps d'utiliser ce qu'on a fait à la partie 2 !
🌞 Changer l'emplacement de la racine Web

configurez NGINX pour qu'il utilise une autre racine web que celle par défaut

avec un nano ou vim, créez un fichiez /var/www/site_web_1/index.html avec un contenu texte bidon
dans la conf de NGINX, configurez la racine Web sur /var/www/site_web_1/

vous me montrerez la conf effectuée dans le compte-rendu, avec un grep

```
[ranvin@router site_web_1]$ ls
index.html
```

```
[ranvin@client nginx]$ sudo cat nginx.conf | grep root | head -1
        root         /var/nfs/general/site_web_1;
```


n'oubliez pas de redémarrer le service pour que le changement prenne effet
prouvez avec un curl depuis votre hôte que vous accédez bien au nouveau site

```
[toto1@client /]$ curl http://192.168.250.6:8080
<h1> Yo </h1>
```

Normalement le dossier /var/www/site_web_1/ est un dossier créé à la Partie 2 du TP, et qui se trouve en réalité sur le serveur storage.tp4.linux, notre serveur NFS.



6. Deux sites web sur un seul serveur
Dans la conf NGINX, vous avez du repérer un bloc server { } (si c'est pas le cas, allez le repérer, la ligne qui définit la racine web est contenu dans le bloc server { }).
Un bloc server { } permet d'indiquer à NGINX de servir un site web donné.
Si on veut héberger plusieurs sites web, il faut donc déclarer plusieurs blocs server { }.
Pour éviter que ce soit le GROS BORDEL dans le fichier de conf, et se retrouver avec un fichier de 150000 lignes, on met chaque bloc server dans un fichier de conf dédié.
Et le fichier de conf principal contient une ligne qui inclut tous les fichiers de confs additionnels.
🌞 Repérez dans le fichier de conf

la ligne qui inclut des fichiers additionels contenus dans un dossier nommé conf.d

vous la mettrez en évidence avec un grep

```
[ranvin@client nginx]$ sudo cat nginx.conf | grep include | grep conf.d
    include /etc/nginx/conf.d/*.conf;
```


On trouve souvent ce mécanisme dans la conf sous Linux : un dossier qui porte un nom finissant par .d qui contient des fichiers de conf additionnels pour pas foutre le bordel dans le fichier de conf principal. On appelle ce dossier un dossier de drop-in.

🌞 Créez le fichier de configuration pour le premier site

```
[ranvin@client conf.d]$ sudo cat site_web_1.conf
  server {
        listen       8080;
        listen       [::]:8080;
        server_name  _;
        root         /nfs/general/site_web_1;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

le bloc server du fichier de conf principal, vous le sortez
et vous le mettez dans un fichier dédié
ce fichier dédié doit se trouver dans le dossier conf.d

ce fichier dédié doit porter un nom adéquat : site_web_1.conf

 
🌞 Créez le fichier de configuration pour le deuxième site

un nouveau fichier dans le dossier conf.d

il doit porter un nom adéquat : site_web_2.conf

copiez-collez le bloc server { } de l'autre fichier de conf
changez la racine web vers /var/www/site_web_2/

et changez le port d'écoute pour 8888

```
[ranvin@client conf.d]$ sudo cat site_web_2.conf
 server {
        listen       8888;
        listen       [::]:8888;
        server_name  _;
        root         /nfs/general/site_web2;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

N'oubliez pas d'ouvrir le port 8888 dans le firewall. Vous pouvez constater si vous le souhaitez avec un ss que NGINX écoute bien sur ce nouveau port.

```
[ranvin@client conf.d]$ sudo firewall-cmd --add-port=8888/tcp --permanent
Warning: ALREADY_ENABLED: 8888:tcp
success

[ranvin@client conf.d]$ sudo firewall-cmd --reload
success

```

🌞 Prouvez que les deux sites sont disponibles

depuis votre PC, deux commandes curl

pour choisir quel site visitez, vous choisissez un port spécifique

```
[toto1@client /]$ curl http://192.168.250.6:8080
<h1> Yo </h1>
```

```
[toto1@client /]$ curl http://192.168.250.6:8888
<h1> Yo </h1>
```

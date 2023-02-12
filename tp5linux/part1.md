Partie 1 : Mise en place et maîtrise du serveur Web
Dans cette partie on va installer le serveur web, et prendre un peu la maîtrise dessus, en regardant où il stocke sa conf, ses logs, etc. Et en manipulant un peu tout ça bien sûr.
On va installer un serveur Web très très trèèès utilisé autour du monde : le serveur Web Apache.


Partie 1 : Mise en place et maîtrise du serveur Web

1. Installation
2. Avancer vers la maîtrise du service





1. Installation
🖥️ VM web.tp5.linux
N'oubliez pas de dérouler la 📝checklist📝.



Machine
IP
Service




web.tp5.linux
10.105.1.11
Serveur Web



🌞 Installer le serveur Apache

paquet httpd

la conf se trouve dans /etc/httpd/

le fichier de conf principal est /etc/httpd/conf/httpd.conf

je vous conseille vivement de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair

avec vim vous pouvez tout virer avec :g/^ *#.*/d

```
[ranvin@router ~]$ sudo dnf install httpd
```





Ce que j'entends au-dessus par "fichier de conf principal" c'est que c'est LE SEUL fichier de conf lu par Apache quand il démarre. C'est souvent comme ça : un service ne lit qu'un unique fichier de conf pour démarrer. Cherchez pas, on va toujours au plus simple. Un seul fichier, c'est simple.
En revanche ce serait le bordel si on mettait toute la conf dans un seul fichier pour pas mal de services.
Donc, le principe, c'est que ce "fichier de conf principal" définit généralement deux choses. D'une part la conf globale. D'autre part, il inclut d'autres fichiers de confs plus spécifiques.
On a le meilleur des deux mondes : simplicité (un seul fichier lu au démarrage) et la propreté (éclater la conf dans plusieurs fichiers).

🌞 Démarrer le service Apache

le service s'appelle httpd (raccourci pour httpd.service en réalité)

démarrez-le
faites en sorte qu'Apache démarre automatiquement au démarrage de la machine

```
[ranvin@router conf]$ sudo systemctl start httpd
[sudo] password for ranvin:
```

```
[ranvin@router conf]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[ranvin@router conf]$ sudo systemctl is-enable httpd
Unknown command verb is-enable.
```

ça se fait avec une commande systemctl référez-vous au mémo


ouvrez le port firewall nécessaire

utiliser une commande ss pour savoir sur quel port tourne actuellement Apache
une portion du mémo commandes est dédiée à ss

```
[ranvin@router conf]$ sudo ss -altnp | grep httpd
LISTEN 0      511                *:80               *:*    users:(("httpd",pid=1277,fd=4),("httpd",pid=1276,fd=4),("httpd",pid=1275,fd=4),("httpd",pid=1273,fd=4))


[ranvin@router conf]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[ranvin@router conf]$ sudo firewall-cmd --reload
success
```




En cas de problème (IN CASE OF FIIIIRE) vous pouvez check les logs d'Apache :

# Demander à systemd les logs relatifs au service httpd
$ sudo journalctl -xe -u httpd

# Consulter le fichier de logs d'erreur d'Apache
$ sudo cat /var/log/httpd/error_log

# Il existe aussi un fichier de log qui enregistre toutes les requêtes effectuées sur votre serveur
$ sudo cat /var/log/httpd/access_log


🌞 TEST

vérifier que le service est démarré
vérifier qu'il est configuré pour démarrer automatiquement
vérifier avec une commande curl localhost que vous joignez votre serveur web localement
vérifier depuis votre PC que vous accéder à la page par défaut

avec votre navigateur (sur votre PC)
avec une commande curl depuis un terminal de votre PC (je veux ça dans le compte-rendu, pas de screen)

```
[ranvin@router conf]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disa>
     Active: active (running) since Tue 2023-01-17 10:52:01 CET; 3min 12s ago
       Docs: man:httpd.service(8)
   Main PID: 1273 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/se>
      Tasks: 213 (limit: 5905)
     Memory: 23.1M
        CPU: 341ms
     CGroup: /system.slice/httpd.service
             ├─1273 /usr/sbin/httpd -DFOREGROUND
             ├─1274 /usr/sbin/httpd -DFOREGROUND
             ├─1275 /usr/sbin/httpd -DFOREGROUND
             ├─1276 /usr/sbin/httpd -DFOREGROUND
             └─1277 /usr/sbin/httpd -DFOREGROUND

Jan 17 10:52:01 web systemd[1]: Starting The Apache HTTP Server...
Jan 17 10:52:01 web httpd[1273]: AH00558: httpd: Could not reliably determine the server'>
Jan 17 10:52:01 web systemd[1]: Started The Apache HTTP Server.
Jan 17 10:52:01 web httpd[1273]: Server configured, listening on: port 80
```

```
[ranvin@router conf]$ sudo systemctl is-enabled httpd
enabled
```

```
[ranvin@router conf]$ curl http://10.105.1.11 | head -10
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
100  7620  100  7620    0     0   437k      0 --:--:-- --:--:-- --:--:--  465k
curl: (23) Failed writing body

```

```
PS C:\Users\Ranvin> curl 10.105.1.11
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it has been installed on a Rocky Linux system.
If you can read this page, it means that the software is working correctly.
Just visiting?
```


2. Avancer vers la maîtrise du service
🌞 Le service Apache...

affichez le contenu du fichier httpd.service qui contient la définition du service Apache

```
[ranvin@router system]$ sudo cat httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
[ranvin@router system]$
```

🌞 Déterminer sous quel utilisateur tourne le processus Apache

mettez en évidence la ligne dans le fichier de conf principal d'Apache (httpd.conf) qui définit quel user est utilisé
utilisez la commande ps -ef pour visualiser les processus en cours d'exécution et confirmer que apache tourne bien sous l'utilisateur mentionné dans le fichier de conf

filtrez les infos importantes avec un | grep



la page d'accueil d'Apache se trouve dans /usr/share/testpage/

vérifiez avec un ls -al que tout son contenu est accessible en lecture à l'utilisateur mentionné dans le fichier de conf

```
[ranvin@router conf]$ ps -ef | grep httpd
root        1273       1  0 10:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1274    1273  0 10:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1275    1273  0 10:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1276    1273  0 10:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1277    1273  0 10:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
ranvin      1601     876  0 11:26 pts/0    00:00:00 grep --color=auto httpd
```
```
[ranvin@router system]$ ps -ef | grep httpd | grep root
root        1273       1  0 10:52 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

🌞 Changer l'utilisateur utilisé par Apache

créez un nouvel utilisateur

pour les options de création, inspirez-vous de l'utilisateur Apache existant

le fichier /etc/passwd contient les informations relatives aux utilisateurs existants sur la machine
servez-vous en pour voir la config actuelle de l'utilisateur Apache par défaut (son homedir et son shell en particulier)
```
[ranvin@router conf]$ sudo useradd toto
[sudo] password for ranvin:
```
```
[ranvin@router etc]$ sudo passwd toto
```


modifiez la configuration d'Apache pour qu'il utilise ce nouvel utilisateur


montrez la ligne de conf dans le compte rendu, avec un grep pour ne montrer que la ligne importante

```
[ranvin@router conf]$ sudo cat httpd.conf | grep User | head -1
User toto
```

redémarrez Apache
utilisez une commande ps pour vérifier que le changement a pris effet

vous devriez voir un processus au moins qui tourne sous l'identité de votre nouvel utilisateur

```
[ranvin@router conf]$ sudo systemctl restart httpd
```

```
[ranvin@router conf]$ ps -ef | grep httpd
root        1735       1  0 12:36 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1737    1735  0 12:36 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1738    1735  0 12:36 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1739    1735  0 12:36 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        1740    1735  0 12:36 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
ranvin      1965     876  0 12:38 pts/0    00:00:00 grep --color=auto httpd
```


🌞 Faites en sorte que Apache tourne sur un autre port

modifiez la configuration d'Apache pour lui demander d'écouter sur un autre port de votre choix


montrez la ligne de conf dans le compte rendu, avec un grep pour ne montrer que la ligne importante

```
[ranvin@router conf]$ sudo cat httpd.conf | grep Listen
Listen 85
```

ouvrez ce nouveau port dans le firewall, et fermez l'ancien
redémarrez Apache


prouvez avec une commande ss que Apache tourne bien sur le nouveau port choisi

```
[ranvin@router ~]$ sudo ss -altnp | grep httpd
[sudo] password for ranvin:
LISTEN 0      511                *:85               *:*    users:(("httpd",pid=719,fd=4),("httpd",pid=718,fd=4),("httpd",pid=717,fd=4),("httpd",pid=689,fd=4))
[ranvin@router ~]$
```

vérifiez avec curl en local que vous pouvez joindre Apache sur le nouveau port

```
[ranvin@router ~]$ curl http://10.105.1.11:85 | head -5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
100  7620  100  7620    0     0   930k      0 --:--:-- --:--:-- --:--:--  930k
curl: (23) Failed writing body
[ranvin@router ~]$
```

vérifiez avec votre navigateur que vous pouvez joindre le serveur sur le nouveau port
```
PS C:\Users\Ranvin> curl 10.105.1.11:85
curl : HTTP Server Test Page
This page is used to test the proper operation of an HTTP server after it has been installed on a Rocky Linux system.
If you can read this page, it means that the software is working correctly.
Just visiting?
```

📁 Fichier /etc/httpd/conf/httpd.conf
➜ Si c'est tout bon vous pouvez passer à la partie 2.
Module 1 : Reverse Proxy
Un reverse proxy est donc une machine que l'on place devant un autre service afin d'accueillir les clients et servir d'intermédiaire entre le client et le service.
Dans notre cas, on va là encore utiliser un outil libre : NGINX (et oui, il peut faire ça aussi, c'est même sa fonction première).

L'utilisation d'un reverse proxy peut apporter de nombreux bénéfices :

décharger le service HTTP de devoir effectuer le chiffrement HTTPS (coûteux en performances)
répartir la charge entre plusieurs services
effectuer de la mise en cache
fournir un rempart solide entre un hacker potentiel et le service et les données importantes
servir de point d'entrée unique pour accéder à plusieurs sites web


Sommaire


Module 1 : Reverse Proxy

Sommaire


I. Setup
II. HTTPS


I. Setup
🖥️ VM proxy.tp6.linux
N'oubliez pas de dérouler la 📝checklist📝.
🌞 On utilisera NGINX comme reverse proxy

installer le paquet nginx

démarrer le service nginx

utiliser la commande ss pour repérer le port sur lequel NGINX écoute
ouvrir un port dans le firewall pour autoriser le trafic vers NGINX
utiliser une commande ps -ef pour déterminer sous quel utilisateur tourne NGINX
vérifier que le page d'accueil NGINX est disponible en faisant une requête HTTP sur le port 80 de la machine

🌞 Configurer NGINX

nous ce qu'on veut, c'pas une page d'accueil moche, c'est que NGINX agisse comme un reverse proxy entre les clients et notre serveur Web
deux choses à faire :

créer un fichier de configuration NGINX

la conf est dans /etc/nginx

procédez comme pour Apache : repérez les fichiers inclus par le fichier de conf principal, et créez votre fichier de conf en conséquence


NextCloud est un peu exigeant, et il demande à être informé si on le met derrière un reverse proxy

y'a donc un fichier de conf NextCloud à modifier
c'est un fichier appelé config.php

la clause à modifier dans ce fichier est trusted_domains






Référez-vous à monsieur Google pour tout ça :)
Exemple de fichier de configuration minimal NGINX.:

server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://<IP_DE_NEXTCLOUD>:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}


➜ Modifier votre fichier hosts de VOTRE PC

pour que le service soit joignable avec le nom www.nextcloud.tp6

c'est à dire que www.nextcloud.tp6 doit pointer vers l'IP de proxy.tp6.linux

autrement dit, pour votre PC :


www.nextcloud.tp6 pointe vers l'IP du reverse proxy

proxy.tp6.linux ne pointe vers rien
taper http://www.nextcloud.tp6 permet d'accéder au site (en passant de façon transparente par l'IP du proxy)




Oui vous ne rêvez pas : le nom d'une machine donnée pointe vers l'IP d'une autre ! Ici, on fait juste en sorte qu'un certain nom permette d'accéder au service, sans se soucier de qui porte réellement ce nom.

🌞 Faites en sorte de

rendre le serveur web.tp6.linux injoignable
sauf depuis l'IP du reverse proxy
en effet, les clients ne doivent pas joindre en direct le serveur web : notre reverse proxy est là pour servir de serveur frontal

comment ? Je vous laisser là encore chercher un peu par vous-mêmes (hint : firewall)

🌞 Une fois que c'est en place

faire un ping manuel vers l'IP de proxy.tp6.linux fonctionne
faire un ping manuel vers l'IP de web.tp6.linux ne fonctionne pas



II. HTTPS
Le but de cette section est de permettre une connexion chiffrée lorsqu'un client se connecte. Avoir le ptit HTTPS :)
Le principe :

on génère une paire de clés sur le serveur proxy.tp6.linux

une des deux clés sera la clé privée : elle restera sur le serveur et ne bougera jamais
l'autre est la clé publique : elle sera stockée dans un fichier appelé certificat

le certificat est donné à chaque client qui se connecte au site




on ajuste la conf NGINX

on lui indique le chemin vers le certificat et la clé privée afin qu'il puisse les utiliser pour chiffrer le trafic
on lui demande d'écouter sur le port convetionnel pour HTTPS : 443 en TCP



Je vous laisse Google vous-mêmes "nginx reverse proxy nextcloud" ou ce genre de chose :)
🌞 Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP
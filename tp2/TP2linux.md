TP2 : Appréhender l'environnement Linux
Dans ce TP, on va aborder plusieurs sujets, dans le but principal de se familiariser un peu plus avec l'environnement GNU/Linux.

Pour rappel, nous étudions et utilisons GNU/Linux de l'angle de l'administrateur, qui gère des serveurs. Nous n'allons que très peu travailler avec des distributions orientées client. Rocky Linux est parfaitement adapté à cet usage.

Ce que vous faites dans ce TP deviendra peu à peu naturel au fil des cours et de votre utilsation de GNU/Linux.
Comme d'hab rien à savoir par coeur, jouez le jeu, et la plasticité de votre cerveau fera le reste.
Une seule VM Rocky suffit pour ce TP. N'oubliez pas d'ouvrir les ports firewall quand c'est nécessaire. De façon volontaire, je ne le précise pas à chaque fois.
Ca doit devenir naturel : vous lancez un programme pour écouter sur un port, alors il faut ouvrir ce port.

Sommaire

TP2 : Appréhender l'environnement Linux

Sommaire

Checklist



I. Service SSH

1. Analyse du service
2. Modification du service



II. Service HTTP

1. Mise en place
2. Analyser la conf de NGINX
3. Déployer un nouveau site web



III. Your own services

1. Au cas où vous auriez oublié
2. Analyse des services existants
3. Création de service




Checklist

Habituez-vous à voir cette petite checklist, elle figurera dans tous les TPs.

A chaque machine déployée, vous DEVREZ vérifier la 📝checklist📝 :


 IP locale, statique ou dynamique

 hostname défini

 firewall actif, qui ne laisse passer que le strict nécessaire

 SSH fonctionnel

 accès Internet (une route par défaut, une carte NAT c'est très bien)

 résolution de nom

 SELinux en mode "permissive" (vérifiez avec sestatus, voir mémo install VM tout en bas)

Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.


I. Service SSH
Le service SSH est déjà installé sur la machine, et il est aussi déjà démarré par défaut, c'est Rocky qui fait ça nativement.

1. Analyse du service
On va, dans cette première partie, analyser le service SSH qui est en cours d'exécution.
🌞 S'assurer que le service sshd est démarré
```[ranvin@router ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor >
     Active: active (running) since Fri 2022-12-09 15:35:49 CET; 11min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 684 (sshd)
      Tasks: 1 (limit: 5905)
     Memory: 5.6M
        CPU: 48ms
     CGroup: /system.slice/sshd.service
             └─684 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 09 15:35:49 marcel systemd[1]: Starting OpenSSH server daemon...
Dec 09 15:35:49 marcel sshd[684]: Server listening on 0.0.0.0 port 22.
Dec 09 15:35:49 marcel sshd[684]: Server listening on :: port 22.
Dec 09 15:35:49 marcel systemd[1]: Started OpenSSH server daemon.
Dec 09 15:37:26 marcel sshd[841]: Accepted password for ranvin from 10.3.2.>
Dec 09 15:37:26 marcel sshd[841]: pam_unix(sshd:session): session opened fo>
lines 1-18/18 (END) 
```

avec une commande systemctl status


🌞 Analyser les processus liés au service SSH

afficher les processus liés au service sshd
```
[ranvin@router ~]$ ps -el | grep sshd
4 S     0     687       1  0  80   0 -  4029 -      ?        00:00:00 sshd
4 S     0     867     687  0  80   0 -  4823 -      ?        00:00:00 sshd
5 S  1000     871     867  0  80   0 -  4823 -      ?        00:00:00 sshd
```

vous pouvez afficher la liste des processus en cours d'exécution avec une commande ps

pour le compte-rendu, vous devez filtrer la sortie de la commande en ajoutant | grep <TEXTE_RECHERCHE> après une commande

exemple :






# Exemple de manipulation de | grep

# admettons un fichier texte appelé "fichier_demo"
# on peut afficher son contenu avec la commande cat :
$ cat fichier_demo
bob a un chapeau rouge
emma surfe avec un dinosaure
eve a pas toute sa tête

# il est possible de filtrer la sortie de la commande cat pour afficher uniquement certaines lignes
$ cat fichier_demo | grep emma
emma surfe avec un dinosaure

$ cat fichier_demo | grep bob
bob a un chapeau rouge


🌞 Déterminer le port sur lequel écoute le service SSH

avec une commande ss
le port est 22
```
[ranvin@router ~]$ sudo ss -ltunp | grep sshd
tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=687,fd=3))
tcp   LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=687,fd=4))

```
isolez les lignes intéressantes avec un | grep <TEXTE>


🌞 Consulter les logs du service SSH

les logs du service sont consultables avec une commande journalctl

un fichier de log qui répertorie toutes les tentatives de connexion SSH existe

il est dans le dossier /var/log

utilisez une commande tail pour visualiser les 10 dernière lignes de ce fichier
```
[ranvin@router log]$ journalctl
Dec 09 16:40:51 localhost kernel: Linux version 5.14.0-70.26.1.el9_0.x86_64>
Dec 09 16:40:51 localhost kernel: The list of certified hardware and cloud >
Dec 09 16:40:51 localhost kernel: Command line: BOOT_IMAGE=(hd0,msdos1)/vml>
Dec 09 16:40:51 localhost kernel: x86/fpu: Supporting XSAVE feature 0x001: >
Dec 09 16:40:51 localhost kernel: x86/fpu: Supporting XSAVE feature 0x002: >
Dec 09 16:40:51 localhost kernel: x86/fpu: Supporting XSAVE feature 0x004: >
Dec 09 16:40:51 localhost kernel: x86/fpu: xstate_offset[2]:  576, xstate_s>
Dec 09 16:40:51 localhost kernel: x86/fpu: Enabled xstate features 0x7, con>
Dec 09 16:40:51 localhost kernel: signal: max sigframe size: 1776
Dec 09 16:40:51 localhost kernel: BIOS-provided physical RAM map:
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x0000000000000000-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x000000000009fc00-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x00000000000f0000-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x0000000000100000-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x000000003fff0000-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x00000000fec00000-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x00000000fee00000-0x0000>
Dec 09 16:40:51 localhost kernel: BIOS-e820: [mem 0x00000000fffc0000-0x0000>
Dec 09 16:40:51 localhost kernel: NX (Execute Disable) protection: active
Dec 09 16:40:51 localhost kernel: SMBIOS 2.5 present.
Dec 09 16:40:51 localhost kernel: DMI: innotek GmbH VirtualBox/VirtualBox, >
Dec 09 16:40:51 localhost kernel: Hypervisor detected: KVM
Dec 09 16:40:51 localhost kernel: kvm-clock: Using msrs 4b564d01 and 4b564d>
Dec 09 16:40:51 localhost kernel: kvm-clock: cpu 0, msr 1de01001, primary c>
Dec 09 16:40:51 localhost kernel: kvm-clock: using sched offset of 12010937>
Dec 09 16:40:51 localhost kernel: clocksource: kvm-clock: mask: 0xfffffffff>
Dec 09 16:40:51 localhost kernel: tsc: Detected 2687.998 MHz processor
Dec 09 16:40:51 localhost kernel: e820: update [mem 0x00000000-0x00000fff] >
Dec 09 16:40:51 localhost kernel: e820: remove [mem 0x000a0000-0x000fffff] >
Dec 09 16:40:51 localhost kernel: last_pfn = 0x3fff0 max_arch_pfn = 0x40000>
Dec 09 16:40:51 localhost kernel: Disabled
Dec 09 16:40:51 localhost kernel: x86/PAT: MTRRs disabled, skipping PAT ini>
Dec 09 16:40:51 localhost kernel: CPU MTRRs all blank - virtualized system.
Dec 09 16:40:51 localhost kernel: x86/PAT: Configuration [0-7]: WB  WT  UC->
Dec 09 16:40:51 localhost kernel: found SMP MP-table at [mem 0x0009fff0-0x0>
Dec 09 16:40:51 localhost kernel: RAMDISK: [mem 0x343a2000-0x361c8fff]
Dec 09 16:40:51 localhost kernel: ACPI: Early table checksum verification d>
Dec 09 16:40:51 localhost kernel: ACPI: RSDP 0x00000000000E0000 000024 (v02>
lines 1-38
```


```
[ranvin@router log]$ sudo tail -n 10 /var/log/secure
[sudo] password for ranvin:
Dec  9 16:34:41 router systemd[835]: pam_unix(systemd-user:session): session opened for user ranvin(uid=1000) by (uid=0)
Dec  9 16:34:41 router login[698]: pam_unix(login:session): session opened for user ranvin(uid=1000) by (uid=0)
Dec  9 16:34:41 router login[698]: LOGIN ON tty1 BY ranvin
Dec  9 16:40:56 router sshd[687]: Server listening on 0.0.0.0 port 22.
Dec  9 16:40:56 router sshd[687]: Server listening on :: port 22.
Dec  9 16:41:06 router systemd[834]: pam_unix(systemd-user:session): session opened for user ranvin(uid=1000) by (uid=0)
Dec  9 16:41:06 router login[700]: pam_unix(login:session): session opened for user ranvin(uid=1000) by (uid=0)
Dec  9 16:41:06 router login[700]: LOGIN ON tty1 BY ranvin
Dec  9 16:46:15 router sshd[867]: Accepted password for ranvin from 10.4.1.1 port 54413 ssh2
Dec  9 16:46:15 router sshd[867]: pam_unix(sshd:session): session opened for user ranvin(uid=1000) by (uid=0)
```


2. Modification du service
Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.
Comme tout fichier de configuration, celui de SSH se trouve dans le dossier /etc/.
Plus précisément, il existe un sous-dossier /etc/ssh/ qui contient toute la configuration relative au protocole SSH
🌞 Identifier le fichier de configuration du serveur SSH

```[ranvin@router ssh]$ ls
moduli        sshd_config.d           ssh_host_ed25519_key.pub
ssh_config    ssh_host_ecdsa_key      ssh_host_rsa_key
ssh_config.d  ssh_host_ecdsa_key.pub  ssh_host_rsa_key.pub
sshd_config   ssh_host_ed25519_key
```
```
[ranvin@router ssh]$ cat sshd_config
cat: sshd_config: Permission denied
[ranvin@router ssh]$ sudo !!
sudo cat sshd_config
[sudo] password for ranvin:
#       $OpenBSD: sshd_config,v 1.104 2021/07/02 05:11:21 dtucker Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

# To modify the system-wide sshd configuration, create a  *.conf  file under
#  /etc/ssh/sshd_config.d/  which will be automatically included below
Include /etc/ssh/sshd_config.d/*.conf

# If you want to change the port on a SELinux system, you have to tell
# SELinux about this change.
# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
#
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile      .ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no

# Change to no to disable s/key passwords
#KbdInteractiveAuthentication yes

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no
#KerberosUseKuserok yes

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no
#GSSAPIEnablek5users no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
# WARNING: 'UsePAM no' is not supported in Fedora and may cause several
# problems.
#UsePAM no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# override default of no subsystems
Subsystem       sftp    /usr/libexec/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server

```

🌞 Modifier le fichier de conf

exécutez un echo $RANDOM pour demander à votre shell de vous fournir un nombre aléatoire
```
[ranvin@router ~]$ echo $RANDOM
27099
```

simplement pour vous montrer la petite astuce et vous faire manipuler le shell :)


changez le port d'écoute du serveur SSH pour qu'il écoute sur ce numéro de port

dans le compte-rendu je veux un cat du fichier de conf
filtré par un | grep pour mettre en évidence la ligne que vous avez modifié

```
[ranvin@router ssh]$ sudo cat sshd_config | grep Port
Port 27099
#GatewayPorts no
```

gérer le firewall


fermer l'ancien port
```

ouvrir le nouveau port

```
[ranvin@router ssh]$ sudo nano sshd_config
[ranvin@router ssh]$ sudo firewall-cmd --add-port=27099/tcp --permanent
success
[ranvin@router ssh]$ sudo systemctl restart

```
vérifier avec un firewall-cmd --list-all que le port est bien ouvert

vous filtrerez la sortie de la commande avec un | grep TEXTE
```
[ranvin@router ssh]$ sudo firewall-cmd --list-all | grep 27099
  ports: 27099/tcp
```




🌞 Redémarrer le service

avec une commande systemctl restart
```
[ranvin@router ssh]$ sudo systemctl restart sshd

```

🌞 Effectuer une connexion SSH sur le nouveau port

depuis votre PC
il faudra utiliser une option à la commande ssh pour vous connecter à la VM
```
$ ssh ranvin@192.168.250.1 -p27099
```

Je vous conseille de remettre le port par défaut une fois que cette partie est terminée.

✨ Bonus : affiner la conf du serveur SSH

faites vos plus belles recherches internet pour améliorer la conf de SSH
par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées



II. Service HTTP
Dans cette partie, on ne va pas se limiter à un service déjà présent sur la machine : on va ajouter un service à la machine.
On va faire dans le clasico et installer un serveur HTTP très réputé : NGINX.
Un serveur HTTP permet d'héberger des sites web.
Un serveur HTTP (ou "serveur Web") c'est :

un programme qui écoute sur un port (ouais ça change pas ça)
il permet d'héberger des sites web

un site web c'est un tas de pages html, js, css
un site web c'est aussi parfois du code php, python ou autres, qui indiquent comment le site doit se comporter


il permet à des clients de visiter les sites web hébergés

pour ça, il faut un client HTTP (par exemple, un navigateur web)
le client peut alors se connecter au port du serveur (connu à l'avance)
une fois le tunnel de communication établi, le client effectuera des requêtes HTTP
le serveur répondra à l'aide du protocole HTTP




Une requête HTTP c'est "donne moi tel fichier HTML". Une réponse c'est "voici tel fichier HTML" + le fichier HTML en question.

Ok bon on y va ?

1. Mise en place

🌞 Installer le serveur NGINX

```
[ranvin@router ssh]$ sudo dnf install nginx
```

je vous laisse faire votre recherche internet
n'oubliez pas de préciser que c'est pour "Rocky 9"

🌞 Démarrer le service NGINX
```
[ranvin@router ssh]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
```
```
[ranvin@router ssh]$ sudo systemctl start nginx
```
```
[ranvin@router ssh]$ sudo firewall-cmd --permanent --add-service=http
success
```
[ranvin@router ssh]$ sudo firewall-cmd --permanent --list-all
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 22/tcp
  protocols:
  forward: yes
  masquerade: yes
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
```
[ranvin@router ssh]$ sudo firewall-cmd --reload
success
```
```
[ranvin@router ssh]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor pre>
     Active: active (running) since Mon 2023-01-02 17:55:32 CET; 6min ago
    Process: 11216 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, sta>
    Process: 11217 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCE>
    Process: 11218 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 11219 (nginx)
      Tasks: 2 (limit: 5905)
     Memory: 1.9M
        CPU: 13ms
     CGroup: /system.slice/nginx.service
             ├─11219 "nginx: master process /usr/sbin/nginx"
             └─11220 "nginx: worker process"

Jan 02 17:55:32 router.tp4.b1 systemd[1]: Starting The nginx HTTP and reverse p>
Jan 02 17:55:32 router.tp4.b1 nginx[11217]: nginx: the configuration file /etc/>
Jan 02 17:55:32 router.tp4.b1 nginx[11217]: nginx: configuration file /etc/ngin>
Jan 02 17:55:32 router.tp4.b1 systemd[1]: Started The nginx HTTP and reverse pr>
lines 1-18/18 (END)
```


🌞 Déterminer sur quel port tourne NGINX

vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées
ouvrez le port concerné dans le firewall

NB : c'est la dernière fois que je signale explicitement la nécessité d'ouvrir un port dans le firewall. Vous devrez vous-mêmes y penser lorsque nécessaire. Toutes les commandes liées au firewall doivent malgré tout figurer dans le compte-rendu.

```
[root@router ssh]# sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11220,fd=6),("nginx",pid=11219,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11220,fd=7),("nginx",pid=11219,fd=7))
```

🌞 Déterminer les processus liés à l'exécution de NGINX
```
[ranvin@router ssh]$ sudo ps -ef | grep nginx
root       11219       1  0 17:55 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      11220   11219  0 17:55 ?        00:00:00 nginx: worker process
ranvin     11313    1081  0 18:18 pts/0    00:00:00 grep --color=auto nginx
```

vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées

🌞 Euh wait

y'a un serveur Web qui tourne là ?
bah... visitez le site web ?

ouvrez votre navigateur (sur votre PC) et visitez http://<IP_VM>:<PORT>

vous pouvez aussi (toujours sur votre PC) utiliser la commande curl depuis un terminal pour faire une requête HTTP


dans le compte-rendu, je veux le curl (pas un screen de navigateur)

utilisez Git Bash si vous êtes sous Windows (obligatoire)
vous utiliserez | head après le curl pour afficher que certaines des premières lignes
vous utiliserez une option à cette commande head pour afficher les 7 premières lignes de la sortie du curl

```
[ranvin@router ssh]$ curl http://192.168.250.1:80 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
100  7620  100  7620    0     0   676k      0 --:--:-- --:--:-- --:--:--  676k
curl: (23) Failed writing body
```


2. Analyser la conf de NGINX
🌞 Déterminer le path du fichier de configuration de NGINX

faites un ls -al <PATH_VERS_LE_FICHIER> pour le compte-rendu
```
[ranvin@router /]$ ls -al etc/nginx/conf.d
total 4
drwxr-xr-x. 2 root root    6 Oct 31 16:37 .
drwxr-xr-x. 4 root root 4096 Jan  2 17:50 ..
```

🌞 Trouver dans le fichier de conf

les lignes qui permettent de faire tourner un site web d'accueil (la page moche que vous avez vu avec votre navigateur)

ce que vous cherchez, c'est un bloc server { } dans le fichier de conf
vous ferez un cat <FICHIER> | grep <TEXTE> -A X pour me montrer les lignes concernées dans le compte-rendu

l'option -A X permet d'afficher aussi les X lignes après chaque ligne trouvée par grep

```
[ranvin@router nginx]$ cat nginx.conf | grep server -A 10
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

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


une ligne qui parle d'inclure d'autres fichiers de conf

encore un cat <FICHIER> | grep <TEXTE>

bah ouais, on stocke pas toute la conf dans un seul fichier, sinon ça serait le bordel

```
[ranvin@router nginx]$ cat nginx.conf | grep -A 15 server | grep include | head -1
        include /etc/nginx/default.d/*.conf;
```


3. Déployer un nouveau site web
🌞 Créer un site web

bon on est pas en cours de design ici, alors on va faire simplissime
créer un sous-dossier dans /var/www/

par convention, on stocke les sites web dans /var/www/

votre dossier doit porter le nom tp2_linux
```
[ranvin@router /]$ cd var/

[ranvin@router var]$ mkdir www/

[ranvin@router www]$ mkdir tp2_linux

[ranvin@router tp2_linux]$ sudo nano index.html




```
dans ce dossier /var/www/tp2_linux, créez un fichier index.html

il doit contenir <h1>MEOW mon premier serveur web</h1>




🌞 Adapter la conf NGINX

dans le fichier de conf principal

vous supprimerez le bloc server {} repéré plus tôt pour que NGINX ne serve plus le site par défaut
redémarrez NGINX pour que les changements prennent effet
```
[ranvin@router nginx]$ sudo nano nginx.conf



[ranvin@router nginx]$ sudo systemctl restart nginx

[ranvin@router nginx]$ cat nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;



# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}
```


créez un nouveau fichier de conf

il doit être nommé correctement
il doit être placé dans le bon dossier
c'est quoi un "nom correct" et "le bon dossier" ?

bah vous avez repéré dans la partie d'avant les fichiers qui sont inclus par le fichier de conf principal non ?
créez votre fichier en conséquence


redémarrez NGINX pour que les changements prennent effet
le contenu doit être le suivant :



server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen <PORT>;
```
[ranvin@router conf.d]$ echo $RANDOM
26848

[ranvin@router conf.d]$ sudo nano tp.conf


[ranvin@router conf.d]$ sudo cat tp.conf
[ranvin@router conf.d]$ sudo cat tp.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
        listen 26848;
        listen [::]:26848;

        root /var/www/tp2_linux;
        index index.html index.htm index.nginx-debian.html;

        server_name tp2_linux www.tp2_linux;

        location / {
                try_files $uri $uri/ =404;
        }
}

```

```
[ranvin@router conf.d]$ sudo firewall-cmd --add-port=26848/tcp --permanent
success
[ranvin@router conf.d]$ sudo firewall-cmd --reload
success
```


🌞 Visitez votre super site web

toujours avec une commande curl depuis votre PC (ou un navigateur)

```
[ranvin@router conf.d]$ curl http://192.168.250.1:26848 | head -n 5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    41  100    41    0     0   4555      0 --:--:-- --:--:-- --:--:--  4555
<h1> MEOW mon premier serveur web </h1>
```

III. Your own services
Dans cette partie, on va créer notre propre service :)
HE ! Vous vous souvenez de netcat ou nc ? Le ptit machin de notre premier cours de réseau ? C'EST L'HEURE DE LE RESORTIR DES PLACARDS.

1. Au cas où vous auriez oublié
Au cas où vous auriez oublié, une petite partie qui ne doit pas figurer dans le compte-rendu, pour vous remettre nc en main.
➜ Dans la VM


nc -l 8888

lance netcat en mode listen
il écoute sur le port 8888
sans rien préciser de plus, c'est le port 8888 TCP qui est utilisé



➜ Allumez une autre VM vite fait

nc <IP_PREMIERE_VM> 8888
vérifiez que vous pouvez envoyer des messages dans les deux sens


Oubliez pas d'ouvrir le port 8888/tcp de la première VM bien sûr :)


2. Analyse des services existants
Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.
Il est défini dans un simple fichier texte, qui contient une info primordiale : la commande exécutée quand on "start" le service.
Il est possible de définir beaucoup d'autres paramètres optionnels afin que notre service s'exécute dans de bonnes conditions.
🌞 Afficher le fichier de service SSH

vous pouvez obtenir son chemin avec un systemctl status <SERVICE>
```
[ranvin@router ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor pres>
     Active: active (running) since Mon 2023-01-02 22:43:00 CET; 13min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 687 (sshd)
      Tasks: 1 (limit: 5905)
     Memory: 5.6M
        CPU: 52ms
     CGroup: /system.slice/sshd.service
             └─687 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```

mettez en évidence la ligne qui commence par ExecStart=

encore un cat <FICHIER> | grep <TEXTE>
```
[ranvin@router /]$ cat usr/lib/systemd/system/sshd.service | grep ExecStart
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

c'est la ligne qui définit la commande lancée lorsqu'on "start" le service

taper systemctl start <SERVICE> ou exécuter cette commande à la main, c'est (presque) pareil

```
[ranvin@router /]$ sudo !!
sudo /usr/sbin/sshd -D $OPTIONS
```


🌞 Afficher le fichier de service NGINX

mettez en évidence la ligne qui commence par ExecStart=

```
[ranvin@router nginx]$ systemctl status nginx | head -2
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
```

```
[ranvin@router nginx]$ sudo cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
[sudo] password for ranvin:
ExecStart=/usr/sbin/nginx
```

3. Création de service

Bon ! On va créer un petit service qui lance un nc. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la min.
Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un nc dans un service n_n
🌞 Créez le fichier /etc/systemd/system/tp2_nc.service

son contenu doit être le suivant (nice & easy)


[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l <PORT>



Vous remplacerez <PORT> par un numéro de port random obtenu avec la même méthode que précédemment.

```
[ranvin@router system]$ echo $RANDOM
26993

[ranvin@router system]$ sudo nano tp2_nc.service


[ranvin@router system]$ cat tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 26993
```

🌞 Indiquer au système qu'on a modifié les fichiers de service

la commande c'est sudo systemctl daemon-reload

```
[ranvin@router system]$ sudo systemctl daemon-reload
```

🌞 Démarrer notre service de ouf

avec une commande systemctl start
```
[ranvin@router system]$ sudo firewall-cmd --add-port=26993/tcp --permanent
success
[ranvin@router system]$ sudo firewall-cmd --reload
success
```

```
[ranvin@router system]$ sudo systemctl start tp2_nc.service
```

🌞 Vérifier que ça fonctionne

vérifier que le service tourne avec un systemctl status <SERVICE>

vérifier que nc écoute bien derrière un port avec un ss

vous filtrerez avec un | grep la sortie de la commande pour n'afficher que les lignes intéressantes


vérifer que juste ça marche en vous connectant au service depuis une autre VM

allumez une autre VM vite fait et vous tapez une commande nc pour vous connecter à la première

``` 
systemctl status tp2_nc.service | head -3
```


Normalement, dans ce TP, vous vous connectez depuis votre PC avec un nc vers la VM, mais bon. Vos supers OS Windows/MacOS chient un peu sur les conventions de réseau, et ça marche pas super super en utilisant un nc directement sur votre machine. Donc voilà, allons au plus simple : allumez vite fait une deuxième qui servira de client pour tester la connexion à votre service tp2_nc.

➜ Si vous vous connectez avec le client, que vous envoyez éventuellement des messages, et que vous quittez nc avec un CTRL+C, alors vous pourrez constater que le service s'est stoppé

bah oui, c'est le comportement de nc ça !
le client se connecte, et quand il se tire, ça ferme nc côté serveur aussi
faut le relancer si vous voulez retester !

🌞 Les logs de votre service

mais euh, ça s'affiche où les messages envoyés par le client ? Dans les logs !

sudo journalctl -xe -u tp2_nc pour visualiser les logs de votre service

sudo journalctl -xe -u tp2_nc -f  pour visualiser en temps réel les logs de votre service


-f comme follow (on "suit" l'arrivée des logs en temps réel)


dans le compte-rendu je veux

une commande journalctl filtrée avec grep qui affiche la ligne qui indique le démarrage du service
une commande journalctl filtrée avec grep qui affiche un message reçu qui a été envoyé par le client
une commande journalctl filtrée avec grep qui affiche la ligne qui indique l'arrêt du service



🌞 Affiner la définition du service

faire en sorte que le service redémarre automatiquement s'il se termine

comme ça, quand un client se co, puis se tire, le service se relancera tout seul
ajoutez Restart=always dans la section [Service] de votre service
n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service :)
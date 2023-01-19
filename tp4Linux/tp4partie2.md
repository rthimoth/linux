Partie 2 : Serveur de partage de fichiers
Dans cette partie, le but sera de monter un serveur de stockage. Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.
Ce dossier sera hébergé sur la partition dédiée sur la machine storage.tp4.linux.
Afin de partager le dossier, nous allons mettre en place un serveur NFS (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.
Le serveur NFS sera storage.tp4.linux et le client NFS sera web.tp4.linux.
L'objectif :

avoir deux dossiers sur storage.tp4.linux partagés

/storage/site_web_1/
/storage/site_web_2/


la machine web.tp4.linux monte ces deux dossiers à travers le réseau

le dossier /storage/site_web_1/ est monté dans /var/www/site_web_1/

le dossier /storage/site_web_2/ est monté dans /var/www/site_web_2/




🌞 Donnez les commandes réalisées sur le serveur NFS storage.tp4.linux

contenu du fichier /etc/exports dans le compte-rendu notamment

🌞 Donnez les commandes réalisées sur le client NFS web.tp4.linux

contenu du fichier /etc/fstab dans le compte-rendu notamment


Je vous laisse vous inspirer de docs sur internet comme celle-ci pour mettre en place un serveur NFS.

Ok, on a fini avec la partie 2, let's head to the part 3.

step1 
```
[ranvin@router ~]$ sudo dnf install nfs-utils
```
step2
```
[ranvin@router ~]$ sudo mkdir /var/nfs/general -p
[ranvin@router ~]$ ls -dl /var/nfs/general
drwxr-xr-x. 2 root root 6 Jan 16 15:33 /var/nfs/general
[ranvin@router ~]$ sudo chown nobody /var/nfs/general
```
step3
```
[ranvin@router ~]$ sudo nano /etc/exports
[ranvin@router ~]$ sudo cat /etc/exports
[sudo] password for ranvin:
/var/nfs/general 192.168.250.6(rw,sync,no_subtree_check)
/home 192.168.250.6(rw,sync,no_root_squash,no_subtree_check)

[ranvin@router ~]$ sudo systemctl enable nfs-server
[ranvin@router ~]$ sudo systemctl start nfs-server
[ranvin@router ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2023-01-16 15:49:37 CET; 10s ago
    Process: 1092 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 1093 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 1110 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=ex>
   Main PID: 1110 (code=exited, status=0/SUCCESS)
        CPU: 19ms

Jan 16 15:49:37 router.tp4.b1 systemd[1]: Starting NFS server and services...
Jan 16 15:49:37 router.tp4.b1 systemd[1]: Finished NFS server and services.
```
step4
```
[ranvin@router ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client ssh

```
```
[ranvin@router storage]$ sudo firewall-cmd --permanent --add-service=nfs
success
[ranvin@router storage]$ sudo firewall-cmd --permanent --add-service=mountd
success
[ranvin@router storage]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[ranvin@router storage]$ sudo firewall-cmd --reload
success
[ranvin@router ~]$ sudo firewall-cmd --permanent --list-all | grep services
[sudo] password for ranvin:
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```
step5
```
[ranvin@router ~]$ sudo mkdir -p /nfs/general
[ranvin@router ~]$ sudo mkdir -p /nfs/home
[ranvin@router ~]$ sudo mount 192.168.250.5:/var/nfs/general /nfs/general
[ranvin@router ~]$ sudo mount 192.168.250.5:/home /nfs/home

[ranvin@router etc]$ df -h
Filesystem                      Size  Used Avail Use% Mounted on
devtmpfs                        462M     0  462M   0% /dev
tmpfs                           481M     0  481M   0% /dev/shm
tmpfs                           193M  3.0M  190M   2% /run
/dev/mapper/rl-root             6.2G  1.2G  5.1G  19% /
/dev/sda1                      1014M  210M  805M  21% /boot
tmpfs                            97M     0   97M   0% /run/user/1000
192.168.250.5:/var/nfs/general  6.2G  1.2G  5.1G  19% /nfs/general
192.168.250.5:/home             6.2G  1.2G  5.1G  19% /nfs/home
[ranvin@router etc]$
```


Step 6
```
[ranvin@router etc]$ sudo touch /nfs/general/general.test
[sudo] password for ranvin:
[ranvin@router etc]$ ls -l /nfs/general/general.test
-rw-r--r--. 1 nobody nobody 0 Jan 16 17:07 /nfs/general/general.test

[ranvin@router etc]$ sudo touch /nfs/home/home.test
[ranvin@router etc]$ ls -l /nfs/home/home.test
-rw-r--r--. 1 root root 0 Jan 16 17:09 /nfs/home/home.test
```

Step 7
```
[ranvin@router etc]$ sudo nano /etc/fstab
[ranvin@router etc]$ sudo cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Oct 13 09:03:33 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=003db131-6536-4853-b9a6-223b50570f1e /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
192.168.250.5:/var/nfs/general    /nfs/general   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
192.168.250.5:/home               /nfs/home      nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

Step 8 
```
[ranvin@router etc]$ cd ~
[ranvin@router ~]$ sudo umount /nfs/home

[ranvin@router ~]$ sudo umount /nfs/general

[ranvin@router ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             462M     0  462M   0% /dev
tmpfs                481M     0  481M   0% /dev/shm
tmpfs                193M  3.0M  190M   2% /run
/dev/mapper/rl-root  6.2G  1.2G  5.1G  19% /
/dev/sda1           1014M  210M  805M  21% /boot
tmpfs                 97M     0   97M   0% /run/user/1000
```

```
[ranvin@router storage]$ sudo mkdir site_web_1
[ranvin@router storage]$ sudo mkdir site_web_2
```

```
[ranvin@router storage]$ sudo chown nobody:nobody site_web_1
[ranvin@router storage]$ sudo chown nobody:nobody site_web_2
```



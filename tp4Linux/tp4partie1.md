Partie 1 : Partitionnement du serveur de stockage

Cette partie est à réaliser sur 🖥️ VM storage.tp4.linux.

On va ajouter un disque dur à la VM, puis le partitionner, afin de créer un espace dédié qui accueillera nos sites web.
➜ Ajouter un disque dur de 2G à la VM

cela se fait via l'interface graphique de virtualbox
il faut éteindre la VM pour ce faire


Référez-vous au mémo LVM pour réaliser le reste de cette partie.

Le partitionnement est obligatoire pour que le disque soit utilisable. Ici on va rester simple : une seule partition, qui prend toute la place offerte par le disque.
Comme vu en cours, le partitionnement dans les systèmes GNU/Linux s'effectue généralement à l'aide de LVM.
Allons !

🌞 Partitionner le disque à l'aide de LVM

créer un physical volume (PV) : le nouveau disque ajouté à la VM
créer un nouveau volume group (VG)

il devra s'appeler storage

il doit contenir le PV créé à l'étape précédente


créer un nouveau logical volume (LV) : ce sera la partition utilisable

elle doit être dans le VG storage

elle doit occuper tout l'espace libre


```
[ranvin@router ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0    8G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0    7G  0 part
  ├─rl-root 253:0    0  6.2G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
sdb           8:16   0    2G  0 disk
sr0          11:0    1 1024M  0 rom
sr1          11:1    1 1024M  0 rom
[ranvin@router ~]$

```
[ranvin@router ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.

```
[ranvin@router ~]$ sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc97cf492-288674dd_ PVID fgMdb8moTNSai5ZHGHezCC2sFpNhz1ts last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb      lvm2 ---  2.00g 2.00g

```

```
[ranvin@router ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
```

```
[ranvin@router ~]$ sudo vgrename data storage
  Volume group "data" successfully renamed to "storage"
```

```
[ranvin@router ~]$ sudo vgdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc97cf492-288674dd_ PVID fgMdb8moTNSai5ZHGHezCC2sFpNhz1ts last seen on /dev/sda2 not found.
  --- Volume group ---
  VG Name               storage
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       0 / 0
  Free  PE / Size       511 / <2.00 GiB
  VG UUID               30dPcK-yngW-MsFr-46RA-kUU1-YfQm-y6Yu7j
```
```
[ranvin@router ~]$ sudo lvcreate -l 100%FREE storage -n titi
  Logical volume "titi" created.
[ranvin@router ~]$
```
```
[ranvin@router ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc97cf492-288674dd_ PVID fgMdb8moTNSai5ZHGHezCC2sFpNhz1ts last seen on /dev/sda2 not found.
  LV   VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  titi storage -wi-a----- <2.00g 
  ```
```
[ranvin@router ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc97cf492-288674dd_ PVID fgMdb8moTNSai5ZHGHezCC2sFpNhz1ts last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/titi
  LV Name                titi
  VG Name                storage
  LV UUID                B1voKW-kVaw-0Nad-vRpY-75gL-yFNX-FIZndn
  LV Write Access        read/write
  LV Creation host, time router.tp4.b1, 2023-01-10 17:50:01 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```




🌞 Formater la partition

vous formaterez la partition en ext4 (avec une commande mkfs)

le chemin de la partition, vous pouvez le visualiser avec la commande lvdisplay

pour rappel un Logical Volume (LVM) C'EST une partition

```
[ranvin@router ~]$ sudo !!
sudo mkfs -t ext4 /dev/storage/titi
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 40ccf202-4af7-4af2-b869-1876f4dd8add
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

```
[ranvin@router ~]$ sudo mkdir /mnt/storage1
[ranvin@router ~]$ mount /dev/storage/titi /mnt/storage1
mount: /mnt/storage1: must be superuser to use mount.
[ranvin@router ~]$ sudo mount /dev/storage/titi /mnt/storage1
[ranvin@router ~]$ df -h
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  462M     0  462M   0% /dev
tmpfs                     481M     0  481M   0% /dev/shm
tmpfs                     193M  3.0M  190M   2% /run
/dev/mapper/rl-root       6.2G  1.2G  5.1G  18% /
/dev/sda1                1014M  210M  805M  21% /boot
tmpfs                      97M     0   97M   0% /run/user/1000
/dev/mapper/storage-titi  2.0G   24K  1.9G   1% /mnt/storage1
[ranvin@router ~]$ ^C
[ranvin@router ~]$
```



🌞 Monter la partition

montage de la partition (avec la commande mount)

la partition doit être montée dans le dossier /storage

preuve avec une commande df -h que la partition est bien montée

utilisez un | grep pour isoler les lignes intéressantes


prouvez que vous pouvez lire et écrire des données sur cette partition


définir un montage automatique de la partition (fichier /etc/fstab)

vous vérifierez que votre fichier /etc/fstab fonctionne correctement

```
[ranvin@router ~]$ mount /dev/storage/titi /mnt/storage1
mount: /mnt/storage1: must be superuser to use mount.
[ranvin@router ~]$ sudo mount /dev/storage/titi /mnt/storage1
[ranvin@router ~]$ df -h
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  462M     0  462M   0% /dev
tmpfs                     481M     0  481M   0% /dev/shm
tmpfs                     193M  3.0M  190M   2% /run
/dev/mapper/rl-root       6.2G  1.2G  5.1G  18% /
/dev/sda1                1014M  210M  805M  21% /boot
tmpfs                      97M     0   97M   0% /run/user/1000
/dev/mapper/storage-titi  2.0G   24K  1.9G   1% /mnt/storage1
[ranvin@router ~]$ ^C
[ranvin@router ~]$
```
```
[ranvin@router ~]$ df -h | grep storage1
/dev/mapper/storage-titi  2.0G   24K  1.9G   1% /mnt/storage1
[ranvin@router ~]$
```


```
[ranvin@router ~]$ sudo mount -av
[sudo] password for ranvin:
/                        : ignored
/boot                    : already mounted
none                     : ignored
/mnt/storage1            : already mounted
[ranvin@router ~]$
```


Ok ! Za, z'est fait. On a un espace de stockage dédié pour stocker nos sites web.
Passons à la partie 2 : installation du serveur de partage de fichiers.
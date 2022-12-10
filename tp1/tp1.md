cd boot/
sudo su
ls
sudo rm -r loader/










cd boot/
sudo su
cd loader/
cd entries/
sudo nano a63b5575c69f456097ec7663ecd1bd06-0-rescue.conf
tout supprimé dans le fichier
ctrl s 
ctrl x


sudo nano a63b5575c69f456097ec7663ecd1bd06-5.14.0-70.13.1.el9_0.x86_64.conf
tout supprimé dans le fichier
ctrl s 
ctrl x

sudo nano a63b5575c69f456097ec7663ecd1bd06-5.14.0-70.26.1.el9_0.x86_64.conf
tout supprimé dans le fichier
ctrl s 
ctrl x

reboot

machine morte









sudo su

systemctl enbale httpd

chmod +x /etc/rc.d/rc.local

vi /opt/scripts/run-script-on-boot.sh
!/bin/bash
date > /root/on-boot-output.txt
hostname > /root/on-boot-output.txt

chmod +x /opt/scripts/run-script-on-boot.sh

vi /etc/rc.d/rc.local

/opt/scripts/run-script-on-boot.sh


reboot






printf "\033[30m\033[40mThis is black text on a white background\033[40m"


export PS1=`printf "\033[30m$
tout s'affiche en noir 


kill 1







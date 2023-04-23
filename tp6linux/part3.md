Module 3 : Fail2Ban
Fail2Ban c'est un peu le cas d'école de l'admin Linux, je vous laisse Google pour le mettre en place.

C'est must-have sur n'importe quel serveur à peu de choses près. En plus d'enrayer les attaques par bruteforce, il limite aussi l'imact sur les performances de ces attaques, en bloquant complètement le trafic venant des IP considérées comme malveillantes
🌞 Faites en sorte que :

si quelqu'un se plante 3 fois de password pour une co SSH en moins de 1 minute, il est ban
vérifiez que ça fonctionne en vous faisant ban
utilisez une commande dédiée pour lister les IPs qui sont actuellement ban
afficher l'état du firewall, et trouver la ligne qui ban l'IP en question
lever le ban avec une commande liée à fail2ban


Vous pouvez vous faire ban en effectuant une connexion SSH depuis web.tp6.linux vers db.tp6.linux par exemple, comme ça vous gardez intacte la connexion de votre PC vers db.tp6.linux, et vous pouvez continuer à bosser en SSH.


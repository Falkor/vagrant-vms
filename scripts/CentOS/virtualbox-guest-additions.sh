# Installation d'une version des virtualbox guest additions compatible avec CentOS 7

VERSION=$(sed 's/[^0-9]//g' /etc/centos-release)
VERSION=${VERSION:0:1}

if [ "$VERSION" -eq "7" ]
then
# Télécharger les outils nécessaires
yum groupinstall -y "Development Tools"
yum install -y kernel-devel

# Récupérer la version des guest additions (actuellement RC1, pas release)
wget http://download.virtualbox.org/virtualbox/4.3.14_RC1/VBoxGuestAdditions_4.3.14_RC1.iso

# Monter l'iso
mkdir /media/cdrom/
mount ./VBoxGuestAdditions_4.3.14_RC1.iso /media/cdrom/

# lancer l'installation ("yes |" car au moment de l'installation on est prompt car une autre version de virtualbox est déjà installée, et on doit confirmer qu'on veut tout de même installer)
cd /media/cdrom
yes | ./VBoxLinuxAdditions.run
fi

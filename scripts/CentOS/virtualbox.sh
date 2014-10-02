# Installing the virtualbox guest additions

# bzip2 lacks for CentOS 7, we install it before installing the guest additions
VERSION=$(sed 's/[^0-9]//g' /etc/centos-release)
VERSION=${VERSION:0:1}

if [ "$VERSION" -eq "7" ]
then
   yum groupinstall -y "Development Tools"
   yum install -y kernel-devel bzip2

   VBOX_VERSION=$(cat /home/veewee/.vbox_version)   
   wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
   mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
   sh /mnt/VBoxLinuxAdditions.run
   umount /mnt
   rm -rf VBoxGuestAdditions_*.iso
#   wget http://download.virtualbox.org/virtualbox/4.3.14_RC1/VBoxGuestAdditions_4.3.14_RC1.iso
#   mkdir /media/cdrom/
#   mount ./VBoxGuestAdditions_4.3.14_RC1.iso /media/cdrom/
#   cd /media/cdrom
#   yes | ./VBoxLinuxAdditions.run 
else
   VBOX_VERSION=$(cat /home/veewee/.vbox_version)
   cd /tmp
   mount -o loop /home/veewee/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
   sh /mnt/VBoxLinuxAdditions.run
   umount /mnt
   rm -rf /home/veewee/VBoxGuestAdditions_*.iso
fi


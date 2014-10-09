# Falkor Bootstrap to install missing packages etc... 

# Install some key missed packages
apt-get -y install curl figlet vim bash-completion

# Puppet customization 
apt-get -y install facter

# environment-modules (Current version on Debian is to old for EasyBuild, so we use the one from the backport repo)
printf "\n# Backport repository\ndeb http://http.debian.net/debian wheezy-backports main\n" >> /etc/apt/sources.list
apt-get update

apt-get -t wheezy-backports -y install environment-modules


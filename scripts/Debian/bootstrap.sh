# Falkor Bootstrap to install missing packages etc... 

# Install some key missed packages
apt-get -y install curl figlet vim bash-completion

# Puppet customization 
apt-get -y install facter

# Adding testing repository to install Lmod later on (Current version on Debian is to old for EasyBuild, so we use the one from the jessie (testing) repo)
printf "\n# Testing repository - main, contrib and non-free branches\ndeb http://http.us.debian.org/debian jessie main non-free contrib\ndeb-src http://http.us.debian.org/debian jessie main non-free contrib\n" >> /etc/apt/sources.list
printf "\n\n# Testing security updates repository\ndeb http://security.debian.org/ jessie/updates main contrib non-free\ndeb-src http://security.debian.org/ jessie/updates main contrib non-free\n" >> /etc/apt/sources.list

# We set the priorities of the repositories, so that by default apt will install packages from the stable repository
printf "\nPackage: *\nPin: release a=stable\nPin-Priority: 700\n" >> /etc/apt/preferences.d/priority_preferences
printf "\n\nPackage: *\nPin: release a=jessie\nPin-Priority: 650\n" >> /etc/apt/preferences.d/priority_preferences

apt-get update


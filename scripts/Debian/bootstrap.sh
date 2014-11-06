# Falkor Bootstrap to install missing packages etc... 

# Install some key missed packages
apt-get -y install curl figlet vim bash-completion

# Puppet customization 
apt-get -y install facter

# Adding sid repository to install Lmod (Current version on Debian is too old for EasyBuild, so we use the one from the sid (rolling release) repo)
printf "\n# sid repository - main, contrib and non-free branches\ndeb http://http.us.debian.org/debian sid main non-free contrib\ndeb-src http://http.us.debian.org/debian sid main non-free contrib\n" >> /etc/apt/sources.list
printf "\n\n# Testing security updates repository\ndeb http://security.debian.org/ sid/updates main contrib non-free\ndeb-src http://security.debian.org/ sid/updates main contrib non-free\n" >> /etc/apt/sources.list

# We set the priorities of the repositories, so that by default apt will install packages from the stable repository
printf "\n\nPackage: *\nPin: release a=sid\nPin-Priority: -1\n" >> /etc/apt/preferences.d/priority_preferences

# A changer: aller vers jessie quand jessie sera freeze (ou released)
printf "APT::Default-Release "wheezy";" >> /etc/apt/apt.conf.d/99defaultrelease

apt-get update


# Sur CentOS, au cours de la creation de la box, le fichier epel.repo est supprime mais le paquet ne l'est pas, empechant l'utilisation et la reinstallation du paquet, on le supprime donc et le reinstalle
yum remove epel-release -y
yum install epel-release -y
puppet apply /etc/puppet/modules/easybuild/tests/init.pp


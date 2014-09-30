# Install Puppet

VERSION=$(awk '{print $3}' /etc/centos-release)
VERSION=${VERSION:0:1}


if [ "$VERSION" -eq "6"]
then
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
elif [ "$VERSION" -eq "7"]
then
    wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
    wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    rpm -Uvh remi-release-7*.rpm epel-release-7*.rpm
fi

yum install -y libyaml
rpm -ivh https://www.dropbox.com/s/18z5vvkpnambr1m/ruby-2.1.2-2.el6.x86_64.rpm?dl=0

gem install puppet facter ruby-shadow


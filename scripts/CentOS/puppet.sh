# Install Puppet

VERSION=$(awk '{print $3}' /etc/centos-release)
VERSION=${VERSION:0:1}

if [ "$VERSION" -eq "6"]
then
    wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    rpm -Uvh remi-release-6*.rpm 

    # Ajout du repository personnel contenant le package ruby
    echo "[personal-repo-www]" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "gpgcheck=0" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "name=Red Hat Linux $releasever - $basearch" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "baseurl=http://ec2-54-77-188-112.eu-west-1.compute.amazonaws.com/repo/el6/" >> /etc/yum.repos.d/personal-repos-www.repo
elif [ "$VERSION" -eq "7"]
then
    wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    rpm -ivh remi-release-7*.rpm 

    # Ajout du repository personnel contenant le package ruby
    echo "[personal-repo-www]" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "gpgcheck=0" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "name=Red Hat Linux $releasever - $basearch" >> /etc/yum.repos.d/personal-repos-www.repo
    echo "baseurl=http://ec2-54-77-188-112.eu-west-1.compute.amazonaws.com/repo/el7/" >> /etc/yum.repos.d/personal-repos-www.repo
fi

yum clean all
yum install -y ruby

gem install puppet facter ruby-shadow

